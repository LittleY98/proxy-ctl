# ProxyCTL

终端代理快速切换工具，支持 Bash、Zsh、Fish。

## 安装

```bash
git clone https://github.com/yourusername/proxyctl.git
cd proxyctl
./bin/install.sh
```

安装过程会交互式配置代理信息，并自动添加到 shell 配置。

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
export PROXY_URL="http://127.0.0.1:7890"
```

## 卸载

```bash
rm -rf ~/.config/proxy_ctl
# 手动删除 shell 配置中的 source 行
```
