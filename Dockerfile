FROM node:22-alpine

# Install dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set Chromium path for Puppeteer/browser automation
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

# Create app directory
WORKDIR /app

# Install OpenClaw globally
RUN npm install -g openclaw

# Create openclaw data directory
RUN mkdir -p /root/.openclaw

# Expose gateway port
EXPOSE 18790

# Default command
CMD ["openclaw", "gateway"]
