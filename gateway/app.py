import asyncio
import os
import secrets
import time
from typing import Dict, Optional
from urllib.parse import urlparse

from fastapi import FastAPI, Header, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, HttpUrl
import websockets

app = FastAPI(title="codex-app-server-gateway")

API_KEYS = {k.strip() for k in os.getenv("GATEWAY_API_KEYS", "dev-key").split(",") if k.strip()}
ALLOWED_ORIGINS = {o.strip() for o in os.getenv("ALLOWED_ORIGINS", "http://localhost").split(",") if o.strip()}
ALLOWED_CALLBACK_HOSTS = {h.strip() for h in os.getenv("ALLOWED_CALLBACK_HOSTS", "localhost").split(",") if h.strip()}
DEFAULT_UPSTREAM_WS = os.getenv("OPENAI_APP_SERVER_WS_URL", "ws://host.docker.internal:9000/ws")
AUTH_TEMPLATE = os.getenv("AUTH_START_URL_TEMPLATE", "https://example.com/auth?state={state}")
STATE_TTL_SEC = int(os.getenv("STATE_TTL_SEC", "900"))

state_store: Dict[str, float] = {}
callback_store: Dict[str, str] = {}


def _check_bearer(auth_header: Optional[str]) -> None:
    if not auth_header or not auth_header.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing bearer token")
    token = auth_header.split(" ", 1)[1]
    if token not in API_KEYS:
        raise HTTPException(status_code=403, detail="invalid api key")


def _cleanup_expired_states() -> None:
    now = time.time()
    expired = [s for s, ts in state_store.items() if now - ts > STATE_TTL_SEC]
    for s in expired:
        state_store.pop(s, None)
        callback_store.pop(s, None)


class CallbackPayload(BaseModel):
    return_url: HttpUrl


@app.get("/healthz")
async def healthz():
    return {"ok": True}


@app.get("/auth/url")
async def auth_url(authorization: Optional[str] = Header(default=None)):
    _check_bearer(authorization)
    _cleanup_expired_states()
    state = secrets.token_urlsafe(24)
    state_store[state] = time.time()
    return {"state": state, "auth_url": AUTH_TEMPLATE.format(state=state)}


@app.post("/auth/callback")
async def auth_callback(payload: CallbackPayload, authorization: Optional[str] = Header(default=None)):
    _check_bearer(authorization)
    _cleanup_expired_states()
    parsed = urlparse(str(payload.return_url))
    if parsed.hostname not in ALLOWED_CALLBACK_HOSTS:
        raise HTTPException(status_code=400, detail="callback host not allowed")

    state = parsed.query.split("state=")[-1].split("&")[0] if "state=" in parsed.query else ""
    if not state or state not in state_store:
        raise HTTPException(status_code=400, detail="invalid or expired state")

    callback_store[state] = str(payload.return_url)
    return {"stored": True, "state": state}


@app.get("/auth/session/{state}")
async def auth_session(state: str, authorization: Optional[str] = Header(default=None)):
    _check_bearer(authorization)
    _cleanup_expired_states()
    if state not in callback_store:
        raise HTTPException(status_code=404, detail="session not found")
    return {"state": state, "return_url": callback_store[state]}


@app.websocket("/ws")
async def ws_proxy(ws: WebSocket):
    auth = ws.headers.get("authorization")
    origin = ws.headers.get("origin", "")

    try:
        _check_bearer(auth)
    except HTTPException:
        await ws.close(code=4401)
        return

    if origin and origin not in ALLOWED_ORIGINS:
        await ws.close(code=4403)
        return

    target = ws.query_params.get("target") or DEFAULT_UPSTREAM_WS

    await ws.accept()

    try:
        async with websockets.connect(target, max_size=2**20) as upstream:
            async def client_to_upstream():
                while True:
                    msg = await ws.receive_text()
                    await upstream.send(msg)

            async def upstream_to_client():
                async for msg in upstream:
                    await ws.send_text(msg)

            await asyncio.gather(client_to_upstream(), upstream_to_client())
    except WebSocketDisconnect:
        pass
    except Exception:
        await ws.close(code=1011)
