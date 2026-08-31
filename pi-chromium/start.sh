#!/bin/bash
set -e

export DISPLAY=:99

PROFILE=/home/node/chrome-profile

rm -f \
    "$PROFILE/SingletonLock" \
    "$PROFILE/SingletonCookie" \
    "$PROFILE/SingletonSocket"

echo "Starting Xvfb..."

Xvfb :99 \
    -screen 0 1920x1080x24 \
    -ac \
    +extension GLX \
    +render \
    -noreset \
    > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!

sleep 1

echo "Starting x11vnc..."

x11vnc \
    -display :99 \
    -forever \
    -shared \
    -rfbport 5900 \
    -localhost \
    -nopw \
    > /tmp/x11vnc.log 2>&1 &
VNC_PID=$!

sleep 1

echo "Starting noVNC..."

websockify \
    --web=/usr/share/novnc \
    6080 \
    localhost:5900 \
    > /tmp/novnc.log 2>&1 &
WEBSOCK_PID=$!

echo "Starting Chromium..."

chromium \
    --user-data-dir=/home/node/chrome-profile \
    --remote-debugging-address=127.0.0.1 \
    --remote-debugging-port=9222 \
    --window-size=1920,1080 \
    --disable-gpu \
    about:blank \
    > /tmp/chromium.log 2>&1 &
CHROME_PID=$!

sleep 2

echo
echo "========================================"
echo " Browser sandbox started"
echo " noVNC: http://127.0.0.1:6080/vnc.html"
echo " CDP:   127.0.0.1:9222"
echo "========================================"
echo

exec bash
