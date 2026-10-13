# pi-base

基于 `node:24-bookworm-slim` 的 Pi 编码智能体基础镜像，内置常用开发/调试工具与 unicode 字体，可直接在 Docker 中运行 [@earendil-works/pi-coding-agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent)。

## 目录内容

| 文件 | 说明 |
| --- | --- |
| `Dockerfile` | 镜像构建定义（基础系统 + 工具 + pi-coding-agent） |
| `entrypoint.sh` | 统一容器入口：执行 `/etc/pi/startup.d/*.sh` 后进入 CMD（默认 `bash`） |
| `start-shadowsocks.sh` | shadowsocks 启动钩子（安装为 `/etc/pi/startup.d/10-shadowsocks.sh`） |
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

## 容器入口与启动钩子

镜像使用统一入口 `/usr/local/bin/entrypoint.sh`：按文件名字典序执行 `/etc/pi/startup.d/*.sh`，然后 `exec` 到 CMD（默认 `bash`）。

- 镜像自带能力以钩子形式安装，例如 `10-shadowsocks.sh`。
- 上层应用可把启动脚本挂到 `/etc/pi/startup.d/`（建议用 `50-` 前缀），无需覆盖 `--entrypoint` 即可叠加自身逻辑。
- 单个钩子失败只记录日志，不影响后续钩子与进入 shell。

## 网络代理

镜像内置 `shadowsocks-libev` 与 `proxychains4`：

- 若宿主机存在 `~/Documents/programs/shadowsocks/config.json`，启动时自动挂载到容器内 `/etc/shadowsocks-libev/config.json`；文件缺失时跳过挂载。
- 启动钩子 `10-shadowsocks.sh` 会自动运行 `ss-local`，在本地提供 SOCKS5 代理，并按配置里的 `local_address`/`local_port` 生成 proxychains 配置 `~/.proxychains/proxychains.conf`。
- 让某条命令走代理：

  ```bash
  proxychains4 curl https://example.com
  ```

默认的 `/etc/proxychains4.conf` 指向 `socks5 127.0.0.1 1080`；运行时生成的 `~/.proxychains/proxychains.conf` 优先级更高，会按实际端口覆盖它。

## Git 配置

若宿主机存在 `~/.pi/.gitconfig`，启动时自动挂载为容器内的 `/home/node/.gitconfig`；文件缺失时跳过挂载。需要启用时，将 `~/.gitconfig` 复制到 `~/.pi/.gitconfig` 即可。
