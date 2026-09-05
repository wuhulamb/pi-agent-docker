# pi-chromium

在 `pi-base` 基础上扩展的浏览器自动化镜像：内置 Chromium、Xvfb 虚拟显示、x11vnc 与 noVNC，可通过网页远程查看容器内的浏览器，并通过 Chrome DevTools 协议（CDP）驱动页面，供 Pi 编码智能体的浏览器相关能力使用。

## 目录内容

| 文件 | 说明 |
| --- | --- |
| `Dockerfile` | 镜像构建定义（基于 `pi:latest`，叠加 Chromium + 远程桌面） |
| `start.sh` | 容器入口脚本：依次启动 Xvfb、x11vnc、noVNC、Chromium |
| `pi-chromium` | 宿主机的启动脚本：以当前用户身份运行容器并挂载持久化目录，进入容器后需再执行 `pi` |

## 构建镜像

`pi-chromium` 基于 `pi:latest` 构建（继承基础工具、中文字体、pi-coding-agent 与网络代理），请先构建基础镜像：

```bash
docker build -t pi:latest pi-base/
docker build -t pi-chromium:latest pi-chromium/
```

## 使用方法

在宿主机执行启动脚本：

```bash
./pi-chromium/pi-chromium
```

运行 `pi` 命令启动智能体

## 安装 pi-chrome-devtools 扩展

在宿主机执行：

```bash
pi install npm:@narumitw/pi-chrome-devtools
```

由于 `pi-chromium` 脚本将宿主机 `~/.pi/pi-chromium/agent/` 挂载为容器内的 `/home/node/.pi/agent/` ，扩展实际安装于**宿主机**。安装后即可通过 CDP（`9222`）控制容器内的 Chromium

## 网络代理

`shadowsocks-libev` 继承自基础镜像 `pi:latest`。配置文件位于宿主机 `~/Documents/programs/shadowsocks/config.json`，启动时自动挂载到容器内。

## 访问浏览器

启动后在宿主机浏览器打开：

- **noVNC 界面**：<http://127.0.0.1:6080/vnc.html>
- **CDP 端点**：`127.0.0.1:9222`（默认只监听容器内 loopback，用于工具驱动）
