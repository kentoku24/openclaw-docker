# OpenClaw Docker

[OpenClaw](https://github.com/openclaw/openclaw) を Docker で簡単にデプロイするための設定。

**再起動してもメモリ・ワークスペース・設定が永続化されます。**

## クイックスタート

### 方法1: Docker Volume（推奨）

```bash
git clone https://github.com/kentoku24/openclaw-docker.git
cd openclaw-docker

# 環境変数を設定
cp .env.example .env
# .env を編集して API キーを設定

# 設定ファイルを作成
cp config/openclaw.example.json config/openclaw.json

# 起動
docker compose up -d
```

### 方法2: ローカル保存（バックアップしやすい）

```bash
git clone https://github.com/kentoku24/openclaw-docker.git
cd openclaw-docker

# 初期化スクリプト実行
./scripts/init.sh

# .env を編集して API キーを設定

# 起動（ローカル保存モード）
docker compose -f docker-compose.local.yml up -d
```

## 永続化されるデータ

| データ | 説明 |
|--------|------|
| `MEMORY.md` | 長期記憶（ユーザー情報、好み、プロジェクト） |
| `memory/` | 追加のメモリファイル |
| `workspace/` | ワークスペースファイル |
| `openclaw.json` | 設定ファイル |
| 会話履歴 | セッション履歴 |

## ディレクトリ構成

```
openclaw-docker/
├── Dockerfile
├── docker-compose.yml          # Docker Volume モード
├── docker-compose.local.yml    # ローカル保存モード
├── .env.example
├── .env                        # 作成する（gitignore）
├── config/
│   ├── openclaw.example.json
│   └── openclaw.json           # 作成する
├── scripts/
│   └── init.sh                 # 初期化スクリプト
└── data/                       # ローカル保存モード時のデータ
    ├── workspace/
    │   └── MEMORY.md
    ├── memory/
    └── openclaw.json
```

## 設定

### 必須

- `ANTHROPIC_API_KEY`: Anthropic API キー

### オプション

| 変数 | 説明 |
|------|------|
| `OPENAI_API_KEY` | OpenAI API キー |
| `OPENROUTER_API_KEY` | OpenRouter API キー |
| `BRAVE_API_KEY` | Brave Search API キー（Web検索用） |
| `DISCORD_BOT_TOKEN` | Discord Bot トークン |
| `TELEGRAM_BOT_TOKEN` | Telegram Bot トークン |

## ブラウザ自動化

ブラウザ自動化を使う場合、docker-compose.yml の以下をアンコメント:

```yaml
cap_add:
  - SYS_ADMIN
security_opt:
  - seccomp:unconfined
```

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

## バックアップ

### ローカル保存モードの場合

```bash
# data/ フォルダをバックアップ
tar -czvf openclaw-backup-$(date +%Y%m%d).tar.gz data/
```

### Docker Volume モードの場合

```bash
# ボリュームをエクスポート
docker run --rm -v openclaw-docker_openclaw-data:/data -v $(pwd):/backup \
  alpine tar -czvf /backup/openclaw-backup-$(date +%Y%m%d).tar.gz /data
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

### メモリがリセットされる

- `docker compose down -v` を使うとボリュームも削除されるので注意
- データを保持したい場合は `docker compose down` のみ使用

## ライセンス

MIT
