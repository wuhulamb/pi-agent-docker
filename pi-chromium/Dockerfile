# 基于 pi-base 镜像构建，仅叠加 Chromium 浏览器栈相关组件。
# 构建前需先构建基础镜像: docker build -t pi:latest pi-base/
FROM pi:latest

# 基础镜像末尾切换到了 node 用户，安装系统包需先切回 root
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    chromium-sandbox \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    xauth \
    dbus-x11 \
    && \
    rm -rf /var/lib/apt/lists/*

USER node

ENV DISPLAY=:99

RUN mkdir -p \
    /home/node/chromium-profile \
    /home/node/.vnc

COPY --chown=node:node start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080

CMD ["/usr/local/bin/start.sh"]