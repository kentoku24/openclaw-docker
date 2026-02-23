#!/bin/bash
# OpenClaw Docker 初期化スクリプト

set -e

echo "🐾 OpenClaw Docker セットアップ"

# 環境変数ファイル作成
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env を作成しました（APIキーを設定してください）"
else
    echo "⏭️  .env は既に存在します"
fi

# データディレクトリ作成（ローカル保存モード用）
mkdir -p data/workspace
mkdir -p data/memory

# MEMORY.md 初期化
if [ ! -f data/workspace/MEMORY.md ]; then
    cat > data/workspace/MEMORY.md << 'EOF'
# Memory

このファイルはOpenClawの長期記憶として使用されます。

## User

<!-- ユーザーについての情報 -->

## Preferences

<!-- ユーザーの好み・設定 -->

## Projects

<!-- 進行中のプロジェクト -->

## Notes

<!-- その他のメモ -->
EOF
    echo "✅ MEMORY.md を作成しました"
fi

# 設定ファイル作成
if [ ! -f data/openclaw.json ]; then
    cp config/openclaw.example.json data/openclaw.json
    echo "✅ openclaw.json を作成しました"
else
    echo "⏭️  openclaw.json は既に存在します"
fi

echo ""
echo "🚀 セットアップ完了！"
echo ""
echo "次のステップ:"
echo "  1. .env を編集して ANTHROPIC_API_KEY を設定"
echo "  2. docker compose -f docker-compose.local.yml up -d"
echo ""
