# pi-base

基于 `node:24-bookworm-slim` 的 Pi 编码智能体基础镜像，内置常用开发/调试工具与 unicode 字体，可直接在 Docker 中运行 [@earendil-works/pi-coding-agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent)。

## 目录内容

| 文件 | 说明 |
| --- | --- |
| `Dockerfile` | 镜像构建定义（基础系统 + 工具 + pi-coding-agent） |
| `pi` | 宿主机的启动脚本：以当前用户身份运行容器并挂载当前目录，进入容器后需再执行 `pi` 启动编码智能体 |

## 构建镜像

```bash
docker build -t pi:latest pi-base/
```

## 使用方法

在宿主机执行启动脚本：

```bash
./pi-base/pi
```

运行 `pi` 命令启动智能体

## 网络代理

Dockerfile 内置 `shadowsocks-libev`，可配置网络代理。若宿主机存在 `~/Documents/programs/shadowsocks/config.json`，启动时自动挂载到容器内；文件缺失时跳过挂载。

## Git 配置

若宿主机存在 `~/.pi/.gitconfig`，启动时自动挂载为容器内的 `/home/node/.gitconfig`；文件缺失时跳过挂载。需要启用时，将 `~/.gitconfig` 复制到 `~/.pi/.gitconfig` 即可。
