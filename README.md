# ProxyCTL

终端代理快速切换工具，支持 Bash、Zsh、Fish。

## 一键安装

```bash
curl -sSL https://raw.githubusercontent.com/LittleY98/proxy-ctl/master/bin/install.sh | bash
```

或先下载再运行：

```bash
curl -sSL https://raw.githubusercontent.com/LittleY98/proxy-ctl/master/bin/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

## 本地安装

```bash
git clone https://github.com/LittleY98/proxy-ctl.git
cd proxy-ctl
./bin/install.sh
```

## 使用

```bash
proxy_on      # 开启代理
proxy_off     # 关闭代理
proxy_status  # 查看状态
proxy_toggle  # 一键切换
```

## 配置

配置文件位置：`~/.config/proxy_ctl/config.sh`

```bash
export PROXY_HOST="127.0.0.1"
export PROXY_PORT="7890"
export PROXY_PROTOCOL="http"   # http 或 socks5
```

## 卸载

```bash
curl -sSL https://raw.githubusercontent.com/LittleY98/proxy-ctl/master/bin/install.sh | bash -s -- uninstall
```
