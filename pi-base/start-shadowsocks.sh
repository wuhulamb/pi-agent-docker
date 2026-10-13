#!/bin/bash
# 容器启动时自动运行本地 shadowsocks (ss-local) SOCKS5 代理，
# 并按实际监听地址/端口生成 proxychains 配置。
# 未挂载 shadowsocks 配置时安静跳过。

set -u

SS_CONFIG="${SHADOWSOCKS_CONFIG:-/etc/shadowsocks-libev/config.json}"

if [ ! -f "$SS_CONFIG" ]; then
    echo "提示: 未找到 $SS_CONFIG，跳过 shadowsocks 启动" >&2
    exit 0
fi

if ! command -v ss-local >/dev/null 2>&1; then
    echo "提示: 未安装 ss-local，跳过 shadowsocks 启动" >&2
    exit 0
fi

# 读取监听地址/端口（默认 127.0.0.1:1080）
LOCAL_ADDRESS="127.0.0.1"
LOCAL_PORT="1080"
if command -v python3 >/dev/null 2>&1; then
    parsed="$(python3 - "$SS_CONFIG" <<'PY' 2>/dev/null
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
addr = str(d.get("local_address") or "127.0.0.1")
port = str(d.get("local_port") or 1080)
if addr in ("", "0.0.0.0", "::"):
    addr = "127.0.0.1"
print(addr, port)
PY
)"
    if [ -n "$parsed" ]; then
        read -r LOCAL_ADDRESS LOCAL_PORT <<< "$parsed"
    fi
fi

# 启动 ss-local（避免重复启动）
if pgrep -x ss-local >/dev/null 2>&1; then
    echo "shadowsocks 已在运行"
else
    ss-local -c "$SS_CONFIG" > /tmp/ss-local.log 2>&1 &
    echo "已启动 shadowsocks: SOCKS5 $LOCAL_ADDRESS:$LOCAL_PORT"
fi

# 生成用户级 proxychains 配置（优先级高于 /etc/proxychains4.conf）
PXC_DIR="${HOME:-/home/node}/.proxychains"
if mkdir -p "$PXC_DIR" 2>/dev/null; then
    cat > "$PXC_DIR/proxychains.conf" <<EOF
# 由 shadowsocks 启动钩子自动生成：指向本地 shadowsocks SOCKS5 代理
strict_chain
proxy_dns
[ProxyList]
socks5 $LOCAL_ADDRESS $LOCAL_PORT
EOF
fi

exit 0
