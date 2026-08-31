FROM node:24-bookworm-slim

WORKDIR /workspace

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    sudo \
    curl \
    python3 \
    tzdata \
    git \
    build-essential \
    strace \
    fd-find \
    ripgrep \
    chromium \
    chromium-sandbox \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    xauth \
    dbus-x11 \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.84.2 && \
    echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 440 /etc/sudoers.d/node && \
    rm -rf /var/lib/apt/lists/*

USER node

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/node/.local/bin:${PATH}"

ENV DISPLAY=:99

RUN mkdir -p \
    /home/node/chrome-profile \
    /home/node/.vnc

COPY --chown=node:node start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080

CMD ["/usr/local/bin/start.sh"]
