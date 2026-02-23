# OpenClaw Docker

[OpenClaw](https://github.com/openclaw/openclaw) を Docker で簡単にデプロイするための設定。

## クイックスタート

### 1. リポジトリをクローン

```bash
git clone https://github.com/kentoku24/openclaw-docker.git
cd openclaw-docker
```

### 2. 環境変数を設定

```bash
cp .env.example .env
# .env を編集して API キーを設定
```

### 3. 設定ファイルを作成

```bash
cp config/openclaw.example.json config/openclaw.json
# 必要に応じて config/openclaw.json を編集
```

### 4. 起動

```bash
docker compose up -d
```

### 5. ログ確認

```bash
docker compose logs -f
```

## 設定

### 必須

- `ANTHROPIC_API_KEY`: Anthropic API キー

### オプション

- `OPENAI_API_KEY`: OpenAI API キー
- `OPENROUTER_API_KEY`: OpenRouter API キー
- `BRAVE_API_KEY`: Brave Search API キー
- `DISCORD_BOT_TOKEN`: Discord Bot トークン
- `TELEGRAM_BOT_TOKEN`: Telegram Bot トークン

## ディレクトリ構成

```
openclaw-docker/
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .env                    # 作成する（gitignore）
├── config/
│   ├── openclaw.example.json
│   └── openclaw.json       # 作成する（gitignore）
└── workspace/              # ワークスペース（自動作成）
```

## ブラウザ自動化

ブラウザ自動化を使う場合、`docker-compose.yml` の以下をアンコメント:

```yaml
cap_add:
  - SYS_ADMIN
security_opt:
  - seccomp:unconfined
```

## 更新

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## トラブルシューティング

### コンテナが起動しない

```bash
docker compose logs openclaw
```

### ポートが使用中

```bash
# docker-compose.yml でポートを変更
ports:
  - "18791:18790"  # ホスト側を変更
```

## ライセンス

MIT
