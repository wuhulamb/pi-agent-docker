# pi-chromium

在 `pi-base` 基础上扩展的浏览器自动化镜像：内置 Chrome for Testing、Xvfb 虚拟显示、x11vnc 与 noVNC，可通过网页远程查看容器内的浏览器，并通过 Chrome DevTools 协议（CDP）驱动页面，供 Pi 编码智能体通过 [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) 使用。

## 目录内容

| 文件 | 说明 |
| --- | --- |
| `Dockerfile` | 镜像构建定义（基于 `pi:latest`，叠加 Chrome for Testing + 远程桌面） |
| `start.sh` | 容器入口脚本：依次启动 Xvfb、x11vnc、noVNC、Chrome for Testing |
| `pi-chromium` | 宿主机的启动脚本：以当前用户身份运行容器并挂载持久化目录，进入容器后需再执行 `pi` |

## 构建镜像

`pi-chromium` 基于 `pi:latest` 构建（继承基础工具、中文字体、pi-coding-agent 与网络代理），请先构建基础镜像：

```bash
docker build -t pi:latest pi-base/
docker build -t pi-chromium:latest pi-chromium/
```

镜像在构建时从官方 last-known-good 清单下载并固定 **Chrome for Testing（Stable 通道）**。如需其它通道：

```bash
docker build --build-arg CFT_CHANNEL=Beta -t pi-chromium:latest pi-chromium/
```

> 下载源为 `storage.googleapis.com`。若构建环境访问受限，请为构建配置代理。

## 使用方法

在宿主机执行启动脚本：

```bash
./pi-chromium/pi-chromium
```

运行 `pi` 命令启动智能体

## 浏览器：Chrome for Testing

- 官方只对 **Google Chrome 与 Chrome for Testing** 提供支持，因此本镜像使用 Chrome for Testing，而不再使用 Debian 的 `chromium` 包。
- 安装位置：`/opt/chrome-for-testing/`，并提供 `/usr/local/bin/chrome` 符号链接。
- `start.sh` 以远程调试模式启动它：
  `--remote-debugging-address=127.0.0.1 --remote-debugging-port=9222`。

## 配置 Chrome DevTools MCP

本镜像内置的 Pi 已内置 MCP 支持（Pi 自 `0.99.0` 起提供，镜像使用 `1.2.0`），无需再安装扩展。**已弃用的 `@narumitw/pi-chrome-devtools` 请卸载：**

```bash
pi uninstall npm:@narumitw/pi-chrome-devtools
```

### 配置文件位置

容器内 Pi 的 agent 目录是 `/home/node/.pi/agent/`，它由启动脚本挂载到宿主机的 `~/.pi/pi-chromium/agent/`。因此 MCP 配置写入：

- 容器内：`/home/node/.pi/agent/mcp.json`
- 宿主机：`~/.pi/pi-chromium/agent/mcp.json`

### 推荐配置：连接容器内已启动的 Chrome

`start.sh` 已经把 Chrome for Testing 跑在 `127.0.0.1:9222`，因此让 MCP 通过 `--browser-url` **附加**到它即可（这样浏览器画面也能在 noVNC 里看到）。

在 `mcp.json` 中合并以下条目（保留已有服务器和其它字段）：

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--browser-url=http://127.0.0.1:9222",
        "--no-usage-statistics",
        "--no-performance-crux"
      ],
      "env": {
        "CHROME_DEVTOOLS_MCP_NO_CONFIG_DISCOVERY": "1"
      },
      "exposure": "hidden",
      "toolExposure": {
        "list_pages": "codemode",
        "select_page": "codemode",
        "new_page": "codemode",
        "navigate_page": "codemode",
        "evaluate_script": "codemode",
        "take_screenshot": "codemode"
      }
    }
  }
}
```

说明：

- `--browser-url` 连接到 `start.sh` 已启动的 Chrome，不会另开浏览器。
- `--no-usage-statistics` / `--no-performance-crux` 关闭 Google 统计与 CrUX 上报（可去掉）。
- `CHROME_DEVTOOLS_MCP_NO_CONFIG_DISCOVERY=1` 禁止读取无关的 `cd4a.config.json`，避免启动策略被静默修改。
- `exposure: hidden` + 六个工具 `codemode`：只让常用浏览工具经 codemode 可达，其余隐藏。也可整体改为 `"exposure": "codemode"` 或 `"direct"`。

也可在容器内用命令行添加（注意命令行不便设置 `exposure`/`toolExposure`）：

```bash
pi mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest \
  --browser-url=http://127.0.0.1:9222 --no-usage-statistics --no-performance-crux
```

### 验证

```bash
pi mcp list      # 连接并打印服务器状态
# 启动 pi 后使用 /mcp 查看连接、工具与暴露方式
```

> 注：Chrome 与 MCP 的 `npx` 均需联网，首次运行会下载 `chrome-devtools-mcp` 包。

## 访问浏览器

启动后在宿主机浏览器打开：

- **noVNC 界面**：<http://127.0.0.1:6080/vnc.html>
- **CDP 端点**：`127.0.0.1:9222`（默认只监听容器内 loopback，用于工具驱动）

## 数据持久化

启动脚本只把 Pi 的 agent 目录持久化到宿主机 `~/.pi/pi-chromium/agent/`，**浏览器 profile 与下载目录不再挂载**：

- 容器以 `--rm` 运行，所以**每次启动都是全新的浏览器**：cookie、网站登录态、历史记录不会保留，需重新登录。
- 浏览器下载的文件（Chrome 默认目录 `~/Downloads`）随容器退出而丢弃。

如需保留，自行在 `pi-chromium` 脚本的 `docker run` 中加回挂载，例如：

```bash
  -v "$HOME/.pi/pi-chromium/chrome-profile/":"/home/node/chrome-profile/" \
  -v "$HOME/.pi/pi-chromium/agent-downloads/":"/home/node/Downloads/" \
```

## 网络代理

`shadowsocks-libev` 继承自基础镜像 `pi:latest`。若宿主机存在 `~/Documents/programs/shadowsocks/config.json`，启动时自动挂载到容器内；文件缺失时跳过挂载。

## Git 配置

若宿主机存在 `~/.pi/.gitconfig`，启动时自动挂载为容器内的 `/home/node/.gitconfig`；文件缺失时跳过挂载。需要启用时，将 `~/.gitconfig` 复制到 `~/.pi/.gitconfig` 即可。

## 故障排查

- **Chrome 报 sandbox 错误**：镜像已将 `/opt/chrome-for-testing/chrome_sandbox` 设为 root 所有并 `4755`。若运行环境仍限制 setuid，可在 `start.sh` 的启动参数中加入 `--no-sandbox`（会降低隔离性）。
- **构建时下载 Chrome for Testing 失败**：为构建过程配置代理，或改用可访问 `storage.googleapis.com` 的网络。
- **`pi mcp list` 连不上**：确认容器内 `start.sh` 已启动（`127.0.0.1:9222` 可访问），再检查 `mcp.json` 是否正确落盘到挂载目录。
