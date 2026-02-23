FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# Install dependencies
RUN apt-get update && apt-get install -y \
    # Desktop environment
    xfce4 \
    xfce4-goodies \
    # VNC
    tigervnc-standalone-server \
    tigervnc-common \
    # noVNC (browser access)
    novnc \
    websockify \
    # Browser
    chromium-browser \
    # Node.js
    curl \
    ca-certificates \
    gnupg \
    # Utilities
    dbus-x11 \
    sudo \
    git \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaw
RUN npm install -g openclaw

# Create user
RUN useradd -m -s /bin/bash openclaw \
    && echo "openclaw:openclaw" | chpasswd \
    && usermod -aG sudo openclaw

# VNC setup
RUN mkdir -p /home/openclaw/.vnc \
    && echo "openclaw" | vncpasswd -f > /home/openclaw/.vnc/passwd \
    && chmod 600 /home/openclaw/.vnc/passwd \
    && chown -R openclaw:openclaw /home/openclaw/.vnc

# VNC startup script
RUN echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
startxfce4 &\n\
' > /home/openclaw/.vnc/xstartup \
    && chmod +x /home/openclaw/.vnc/xstartup \
    && chown openclaw:openclaw /home/openclaw/.vnc/xstartup

# OpenClaw data directory
RUN mkdir -p /home/openclaw/.openclaw/workspace \
    && chown -R openclaw:openclaw /home/openclaw/.openclaw

# Startup script
COPY scripts/start.sh /start.sh
RUN chmod +x /start.sh

# Ports
# 5901: VNC
# 6080: noVNC (browser)
# 18790: OpenClaw Gateway
EXPOSE 5901 6080 18790

USER openclaw
WORKDIR /home/openclaw

CMD ["/start.sh"]
