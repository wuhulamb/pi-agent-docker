#!/bin/bash
# pi 容器统一入口：按文件名字典序执行 /etc/pi/startup.d/*.sh，
# 然后把控制权交给 CMD（默认 bash）。
#
# 镜像自带能力（shadowsocks 代理）与上层应用（如 chatecnu 的中间层）
# 都通过该目录的钩子注入，镜像入口本身不再被替换。
set -e

if [ -d /etc/pi/startup.d ]; then
    for hook in /etc/pi/startup.d/*.sh; do
        [ -e "$hook" ] || continue
        echo "[startup.d] $hook" >&2
        if [ -x "$hook" ]; then
            "$hook" || echo "[startup.d] $hook 退出码 $?" >&2
        else
            bash "$hook" || echo "[startup.d] $hook 退出码 $?" >&2
        fi
    done
fi

exec "$@"
