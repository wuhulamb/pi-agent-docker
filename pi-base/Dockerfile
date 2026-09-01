FROM node:24-bookworm-slim

WORKDIR /workspace

ENV DEBIAN_FRONTEND=noninteractive

RUN cat > /etc/apt/sources.list.d/debian.sources <<'EOF'
Types: deb
URIs: http://mirrors.ustc.edu.cn/debian
Suites: bookworm bookworm-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors.ustc.edu.cn/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

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
    procps \
    xxd \
    fd-find \
    ripgrep \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    shadowsocks-libev \
    && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.84.2 && \
    echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 440 /etc/sudoers.d/node && \
    rm -rf /var/lib/apt/lists/*

USER node

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/node/.local/bin:${PATH}"

CMD ["bash"]
