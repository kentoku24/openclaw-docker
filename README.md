# OpenClaw Docker

[OpenClaw](https://github.com/openclaw/openclaw) を Docker で簡単にデプロイ。

**VNC/noVNC経由でブラウザにアクセスして、OpenAI等のブラウザ認証も可能。**

## 特徴

- 🖥️ **VNC/noVNC対応** - ブラウザから直接デスクトップにアクセス
- 🔐 **ブラウザ認証対応** - OpenAI等のブラウザベース認証が可能
- 💾 **永続化** - 再起動してもメモリ・設定・ワークスペースを保持
- 🌐 **Chromium内蔵** - ブラウザ自動化対応

## クイックスタート

```bash
git clone https://github.com/kentoku24/openclaw-docker.git
cd openclaw-docker

# 環境変数を設定
cp .env.example .env
# .env を編集して API キーを設定

# 起動
docker compose up -d
```

## アクセス方法

| サービス | URL | 用途 |
|----------|-----|------|
| **noVNC** | http://localhost:6080 | ブラウザからデスクトップにアクセス |
| **VNC** | localhost:5901 | VNCクライアントから接続 |
| **Gateway** | http://localhost:18790 | OpenClaw API |

### noVNC でブラウザ認証

1. http://localhost:6080 にアクセス
2. パスワード: `openclaw`
3. デスクトップでChromiumを開く
4. OpenAI等の認証を行う

## 初期設定

### 1. ブラウザでnoVNCにアクセス

```
http://localhost:6080
パスワード: openclaw
```

### 2. ターミナルでOpenClaw設定

デスクトップのターミナルを開いて:

```bash
openclaw init
```

### 3. プロバイダー認証

OpenAI等ブラウザ認証が必要な場合:

```bash
openclaw provider login openai
```

Chromiumが開くので認証を完了する。

## ディレクトリ構成

```
openclaw-docker/
├── Dockerfile
├── docker-compose.yml          # Docker Volume モード
├── docker-compose.local.yml    # ローカル保存モード
├── .env.example
├── .env                        # 作成する（gitignore）
├── scripts/
│   ├── init.sh                 # 初期化スクリプト
│   └── start.sh                # コンテナ起動スクリプト
└── data/                       # ローカル保存モード時のデータ
```

## 永続化されるデータ

- ✅ MEMORY.md - 長期記憶
- ✅ memory/ - 追加メモリファイル
- ✅ workspace/ - ワークスペース
- ✅ openclaw.json - 設定
- ✅ 会話履歴 - セッション履歴
- ✅ 認証情報 - プロバイダー認証

## 環境変数

### 必須

- `ANTHROPIC_API_KEY`: Anthropic API キー

### オプション

| 変数 | 説明 |
|------|------|
| `OPENAI_API_KEY` | OpenAI API キー（またはブラウザ認証） |
| `OPENROUTER_API_KEY` | OpenRouter API キー |
| `BRAVE_API_KEY` | Brave Search API キー |
| `DISCORD_BOT_TOKEN` | Discord Bot トークン |
| `TELEGRAM_BOT_TOKEN` | Telegram Bot トークン |

## コマンド

```bash
# 起動
docker compose up -d

# ログ確認
docker compose logs -f

# 停止
docker compose down

# 再起動（データは保持される）
docker compose restart

# 更新
docker compose down
docker compose build --no-cache
docker compose up -d
```

## ローカル保存モード

バックアップしやすいようにホストに直接保存:

```bash
./scripts/init.sh
docker compose -f docker-compose.local.yml up -d
```

データは `./data/` に保存される。

## バックアップ

```bash
# ローカル保存モード
tar -czvf openclaw-backup-$(date +%Y%m%d).tar.gz data/

# Docker Volume モード
docker run --rm -v openclaw-docker_openclaw-data:/data -v $(pwd):/backup \
  alpine tar -czvf /backup/openclaw-backup-$(date +%Y%m%d).tar.gz /data
```

## トラブルシューティング

### noVNCに接続できない

```bash
docker compose logs openclaw
# VNCサーバーが起動しているか確認
```

### 画面が真っ黒

デスクトップ環境の起動に時間がかかることがある。数秒待ってリロード。

### Chromiumがクラッシュする

`shm_size` が足りない可能性。docker-compose.yml で `shm_size: '4gb'` に増やす。

## VNCパスワード変更

```bash
docker exec -it openclaw vncpasswd
docker compose restart
```

## ライセンス

MIT
