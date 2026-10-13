# 基于 pi-base 镜像构建，仅叠加 Chrome for Testing 浏览器栈相关组件。
# 构建前需先构建基础镜像: docker build -t pi:latest pi-base/
FROM pi:latest

# 基础镜像末尾切换到了 node 用户，安装系统包需先切回 root
USER root

# Chrome for Testing 运行所需的共享库（不再依赖 Debian 的 chromium 包）
RUN apt-get update && apt-get install -y --no-install-recommends \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libcairo2 \
    libcairo-gobject2 \
    libasound2 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxext6 \
    libxi6 \
    libxtst6 \
    libxss1 \
    libxrender1 \
    libxcursor1 \
    libxshmfence1 \
    libglib2.0-0 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgtk-3-0 \
    libvulkan1 \
    libu2f-udev \
    xdg-utils \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    xauth \
    dbus-x11 \
    unzip \
    && \
    rm -rf /var/lib/apt/lists/*

# 从官方 last-known-good 清单安装 Chrome for Testing（默认 Stable 通道）
# 可用 --build-arg CFT_CHANNEL=Beta/Dev/Canary 切换通道
# 下载源为 storage.googleapis.com，如构建环境访问受限请自备代理
ARG CFT_CHANNEL=Stable
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
        amd64) CFT_PLATFORM=linux64 ;; \
        arm64) CFT_PLATFORM=linux-arm64 ;; \
        *) echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" -o /tmp/cft.json; \
    CFT_URL="$(python3 -c "import json;d=json.load(open('/tmp/cft.json'));c=d['channels']['${CFT_CHANNEL}'];print([u['url'] for u in c['downloads']['chrome'] if u['platform']=='$CFT_PLATFORM'][0])")"; \
    echo "Installing Chrome for Testing: $CFT_URL"; \
    curl -fsSL "$CFT_URL" -o /tmp/cft.zip; \
    unzip -q /tmp/cft.zip -d /opt; \
    rm -rf /opt/chrome-for-testing; \
    mv "/opt/chrome-$CFT_PLATFORM" /opt/chrome-for-testing; \
    chown -R root:root /opt/chrome-for-testing; \
    chmod 4755 /opt/chrome-for-testing/chrome_sandbox; \
    ln -sf /opt/chrome-for-testing/chrome /usr/local/bin/chrome; \
    rm -f /tmp/cft.json /tmp/cft.zip; \
    /opt/chrome-for-testing/chrome --version

USER node

ENV DISPLAY=:99

RUN mkdir -p \
    /home/node/chrome-profile \
    /home/node/.vnc

COPY --chown=node:node start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080

CMD ["/usr/local/bin/start.sh"]
