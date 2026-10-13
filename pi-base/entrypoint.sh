#!/bin/bash
# pi-base 容器入口：自动启动本地 shadowsocks 代理后执行用户命令。
set -e

if [ -x /usr/local/bin/start-shadowsocks.sh ]; then
    /usr/local/bin/start-shadowsocks.sh || true
fi

exec "$@"
