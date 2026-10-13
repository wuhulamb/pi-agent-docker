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
    file \
    xclip \
    fd-find \
    ripgrep \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    shadowsocks-libev \
    proxychains4 \
    && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent@1.2.0 && \
    echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 440 /etc/sudoers.d/node && \
    rm -rf /var/lib/apt/lists/*

# 默认 proxychains 配置：指向本地 shadowsocks 的 SOCKS5 代理
# 运行时 shadowsocks 钩子会按实际端口生成 ~/.proxychains/proxychains.conf 覆盖它
RUN printf '%s\n' \
    '# 默认指向本地 shadowsocks SOCKS5 代理，可按需修改' \
    'strict_chain' \
    'proxy_dns' \
    '[ProxyList]' \
    'socks5 127.0.0.1 1080' \
    > /etc/proxychains4.conf

# 统一入口 + 启动钩子目录。镜像自带能力（shadowsocks）也以钩子形式安装。
RUN mkdir -p /etc/pi/startup.d

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-shadowsocks.sh /etc/pi/startup.d/10-shadowsocks.sh

RUN chmod +x \
    /usr/local/bin/entrypoint.sh \
    /etc/pi/startup.d/10-shadowsocks.sh

USER node

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/node/.local/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
