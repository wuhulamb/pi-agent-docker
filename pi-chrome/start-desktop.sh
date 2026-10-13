#!/bin/bash
# 启动 Chrome 桌面栈：Xvfb + x11vnc + noVNC + Chrome for Testing。
# 作为 /etc/pi/startup.d/20-desktop.sh 钩子，由统一入口执行，启动后即返回。
set -e

export DISPLAY=:99

PROFILE=/home/node/chrome-profile

rm -f \
    "$PROFILE/SingletonLock" \
    "$PROFILE/SingletonCookie" \
    "$PROFILE/SingletonSocket"

echo "starting Xvfb..."

Xvfb :99 \
    -screen 0 1920x1080x24 \
    -ac \
    +extension GLX \
    +render \
    -noreset \
    > /tmp/xvfb.log 2>&1 &

sleep 1

echo "starting x11vnc..."

x11vnc \
    -display :99 \
    -forever \
    -shared \
    -rfbport 5900 \
    -localhost \
    -nopw \
    > /tmp/x11vnc.log 2>&1 &

sleep 1

echo "starting noVNC..."

websockify \
    --web=/usr/share/novnc \
    6080 \
    localhost:5900 \
    > /tmp/novnc.log 2>&1 &

echo "starting Chrome for Testing..."

/opt/chrome-for-testing/chrome \
    --user-data-dir="$PROFILE" \
    --remote-debugging-address=127.0.0.1 \
    --remote-debugging-port=9222 \
    --window-size=1920,1080 \
    --disable-gpu \
    --no-first-run \
    --no-default-browser-check \
    about:blank \
    > /tmp/chrome.log 2>&1 &

sleep 2

echo "========================================"
echo " Browser sandbox started"
echo " noVNC: http://127.0.0.1:6080/vnc.html"
echo " CDP:   127.0.0.1:9222"
echo "========================================"
