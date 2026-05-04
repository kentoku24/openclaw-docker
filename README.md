# OpenAI Codex App Server WebSocket Gateway (2コンテナ構成)

このリポジトリは、OpenAI Codex App Server へ接続するための WebSocket クライアント機能を
Docker コンテナとして提供します。

- `gateway-openclaw`: openclaw 専用
- `gateway-general`: 自作 AI アプリ / Claude など汎用

## 主な機能

- WebSocket プロキシ (`/ws`)。
- サブスク認証向けの 2 ステップフロー。
  1. コンテナから認証 URL を取得 (`GET /auth/url`)
  2. ブラウザから戻ってきた URL をコンテナへ投入 (`POST /auth/callback`)
- 最低限のセキュリティ
  - Bearer API キー必須
  - Origin 許可リスト
  - コールバック URL ドメイン許可リスト
  - 機密を永続化しない (デフォルト in-memory)

## 起動

```bash
docker compose up --build
```

## 環境変数

- `GATEWAY_API_KEYS`: カンマ区切り API キー。
- `ALLOWED_ORIGINS`: 許可 Origin。
- `ALLOWED_CALLBACK_HOSTS`: 認証後 URL の許可ホスト。
- `OPENAI_APP_SERVER_WS_URL`: 接続先 WebSocket URL。
- `AUTH_START_URL_TEMPLATE`: 認証 URL テンプレート。`{state}` を含める。

## API

### `GET /auth/url`

ヘッダ: `Authorization: Bearer <key>`

state を払い出し、ユーザーがブラウザで開く認証 URL を返却します。

### `POST /auth/callback`

ヘッダ: `Authorization: Bearer <key>`

```json
{
  "return_url": "https://example.com/callback?code=...&state=..."
}
```

state を検証し、URL をメモリに保存します。

### `GET /auth/session/{state}`

ヘッダ: `Authorization: Bearer <key>`

保存された callback URL を取得します。

### `GET /ws`

ヘッダ: `Authorization: Bearer <key>`

クエリ:
- `target`: 任意で WebSocket 接続先を上書き

クライアントと上流 WebSocket を双方向中継します。
