# pi Docker 镜像

基于 `node:24-bookworm-slim` 的 Pi 编码智能体 Docker 镜像，包含两个版本：

| 镜像 | 目录 | 说明 |
| --- | --- | --- |
| `pi:latest` | [pi-base/](pi-base/README.md) | 基础镜像：内置常用开发/调试工具、中文字体与 pi-coding-agent |
| `pi-chromium:latest` | [pi-chromium/](pi-chromium/README.md) | 浏览器增强镜像：在基础镜像上增加 Chromium、Xvfb、noVNC，支持浏览器自动化 |

## 快速开始

```bash
# 构建镜像（pi-chromium 基于 pi:latest 构建，需先构建基础镜像）
docker build -t pi:latest pi-base/
docker build -t pi-chromium:latest pi-chromium/

# 使用
./pi-base/pi                # 基础版
./pi-chromium/pi-chromium   # 浏览器版（需使用pi安装 pi-chrome-devtools 扩展）
```

## 文档

- [pi-base/README.md](pi-base/README.md)
- [pi-chromium/README.md](pi-chromium/README.md)
