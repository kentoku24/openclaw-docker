#!/bin/bash
set -e

echo "🐾 Starting OpenClaw Docker..."

# Start VNC server
echo "📺 Starting VNC server on :1 (port 5901)..."
vncserver :1 -geometry 1280x800 -depth 24

# Start noVNC
echo "🌐 Starting noVNC on port 6080..."
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080 &

# Wait for desktop to be ready
sleep 3

# Start OpenClaw gateway
echo "🚀 Starting OpenClaw Gateway on port 18790..."
cd /home/openclaw
exec openclaw gateway
