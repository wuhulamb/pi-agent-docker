# pi Docker 镜像

基于 `node:24-bookworm-slim` 的 Pi 编码智能体 Docker 镜像，包含两个版本：

| 镜像 | 目录 | 说明 |
| --- | --- | --- |
| `pi:latest` | [pi-base/](pi-base/README.md) | 基础镜像：内置常用开发/调试工具、中文字体、pi-coding-agent、shadowsocks、proxychains 与 uv 国内镜像 |
| `pi-chrome:latest` | [pi-chrome/](pi-chrome/README.md) | 浏览器镜像：在基础镜像上增加 Chrome for Testing、Xvfb、noVNC，支持浏览器自动化 |

## 快速开始

```bash
# 构建镜像（pi-chrome 基于 pi:latest 构建，需先构建基础镜像）
docker build -t pi:latest pi-base/
docker build -t pi-chrome:latest pi-chrome/

# 使用
./pi-base/pi              # 基础版
./pi-chrome/pi-chrome     # 浏览器版（内置 Chrome for Testing + noVNC）
```

## 架构约定

两个镜像共享**同一个入口脚本** `/usr/local/bin/entrypoint.sh`，它在进入 shell 前按文件名字典序执行 `/etc/pi/startup.d/*.sh`。镜像能力与上层应用都通过钩子注入：

| 钩子 | 来源 | 作用 |
| --- | --- | --- |
| `10-shadowsocks.sh` | pi-base | 启动本地 shadowsocks 代理并生成 proxychains 配置 |
| `20-desktop.sh` | pi-chrome | 启动 Xvfb / x11vnc / noVNC / Chrome for Testing |
| `50-*.sh` | 上层应用（如 chatecnu） | 启动应用自身的服务 |

上层应用（例如 chatecnu 中间层）只需把自己的启动脚本挂到 `/etc/pi/startup.d/`，无需覆盖镜像 `--entrypoint`，即可叠加在镜像之上。

## 文档

- [pi-base/README.md](pi-base/README.md)
- [pi-chrome/README.md](pi-chrome/README.md)
