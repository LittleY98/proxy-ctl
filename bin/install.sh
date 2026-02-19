#!/bin/bash
set -e

ACTION="${1:-install}"
CONFIG_DIR="$HOME/.config/proxy_ctl"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$SCRIPT_DIR/../src" ]; then
    IS_LOCAL=true
    GITHUB_RAW=""
else
    IS_LOCAL=false
    GITHUB_RAW="https://raw.githubusercontent.com/LittleY98/proxy-ctl/master"
fi

echo "=========================================="
echo "       ProxyCTL 安装/卸载脚本"
echo "=========================================="
echo ""

if [ "$ACTION" = "uninstall" ]; then
    echo "🔽 卸载模式"
    echo ""

    detect_shell() {
        local shell_path="${SHELL:-/bin/bash}"
        local shell_name
        shell_name=$(basename "$shell_path")
        case "$shell_name" in
            zsh)    echo "zsh" ;;
            bash)   echo "bash" ;;
            fish)   echo "fish" ;;
            *)      echo "bash" ;;
        esac
    }

    remove_from_shell_config() {
        local shell="$1"
        local config_file=""
        case "$shell" in
            zsh)    config_file="$HOME/.zshrc" ;;
            bash)
                [ -f "$HOME/.bashrc" ] && config_file="$HOME/.bashrc"
                [ -f "$HOME/.bash_profile" ] && config_file="$HOME/.bash_profile"
                ;;
            fish)   config_file="$HOME/.config/fish/config.fish" ;;
        esac

        [ -z "$config_file" ] || [ ! -f "$config_file" ] && return
        grep -q "proxy_ctl" "$config_file" 2>/dev/null || return

        sed -i.bak "/# ProxyCTL/,/proxy_ctl/d" "$config_file"
        rm -f "$config_file.bak"
        echo "✅ 已从 $config_file 移除"
    }

    read -p "确认卸载 ProxyCTL？(y/N): " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && echo "已取消" && exit 0

    [ -d "$CONFIG_DIR" ] && rm -rf "$CONFIG_DIR" && echo "✅ 已删除配置目录"

    current_shell=$(detect_shell)
    remove_from_shell_config "$current_shell"

    echo ""
    echo "🎉 卸载完成！"
    exit 0
fi

echo "🔽 安装模式"
echo ""

mkdir -p "$CONFIG_DIR"

echo "请配置代理信息（直接回车使用默认值）："
echo ""

PROXY_HOST_DEFAULT="127.0.0.1"
PROXY_PORT_DEFAULT="7890"

read -p "代理 Host [$PROXY_HOST_DEFAULT]: " PROXY_HOST
PROXY_HOST=${PROXY_HOST:-$PROXY_HOST_DEFAULT}

read -p "代理 Port [$PROXY_PORT_DEFAULT]: " PROXY_PORT
PROXY_PORT=${PROXY_PORT:-$PROXY_PORT_DEFAULT}

echo "代理协议："
echo "  1) HTTP (默认)"
echo "  2) SOCKS5"
read -p "请选择 [1]: " PROXY_TYPE
case "$PROXY_TYPE" in
    2|socks5|SOCKS5) PROXY_PROTOCOL="socks5" ;;
    *) PROXY_PROTOCOL="http" ;;
esac

cat > "$CONFIG_DIR/config.sh" <<EOF
export PROXY_HOST="$PROXY_HOST"
export PROXY_PORT="$PROXY_PORT"
export PROXY_PROTOCOL="$PROXY_PROTOCOL"
EOF
echo "✅ 配置文件已保存"

if [ "$IS_LOCAL" = "true" ]; then
    cp "$SCRIPT_DIR/../src/proxy_ctl.sh" "$CONFIG_DIR/proxy_ctl.sh"
    cp "$SCRIPT_DIR/../src/proxy_ctl.zsh" "$CONFIG_DIR/proxy_ctl.zsh"
    cp "$SCRIPT_DIR/../src/proxy_ctl.fish" "$CONFIG_DIR/proxy_ctl.fish"
else
    echo "下载脚本..."
    curl -sSL "$GITHUB_RAW/src/proxy_ctl.sh" -o "$CONFIG_DIR/proxy_ctl.sh"
    curl -sSL "$GITHUB_RAW/src/proxy_ctl.zsh" -o "$CONFIG_DIR/proxy_ctl.zsh"
    curl -sSL "$GITHUB_RAW/src/proxy_ctl.fish" -o "$CONFIG_DIR/proxy_ctl.fish"
fi
echo "✅ 脚本已就绪"

detect_shell() {
    local shell_path="${SHELL:-/bin/bash}"
    local shell_name
    shell_name=$(basename "$shell_path")
    case "$shell_name" in
        zsh)    echo "zsh" ;;
        bash)   echo "bash" ;;
        fish)   echo "fish" ;;
        *)      echo "bash" ;;
    esac
}

add_to_shell_config() {
    local shell="$1"
    local config_file=""
    local source_line="source $CONFIG_DIR/proxy_ctl.sh"

    case "$shell" in
        zsh)
            config_file="$HOME/.zshrc"
            source_line="source $CONFIG_DIR/proxy_ctl.zsh"
            ;;
        bash)
            [ -f "$HOME/.bashrc" ] && config_file="$HOME/.bashrc"
            [ -f "$HOME/.bash_profile" ] && config_file="$HOME/.bash_profile"
            [ -z "$config_file" ] && return
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            source_line="source $CONFIG_DIR/proxy_ctl.fish"
            ;;
    esac

    [ -z "$config_file" ] || [ ! -f "$config_file" ] && echo "⚠️ 未找到 $shell 配置文件" && return
    grep -q "proxy_ctl" "$config_file" 2>/dev/null && echo "⏭️  $shell 配置已包含" && return

    echo "" >> "$config_file"
    echo "# ProxyCTL" >> "$config_file"
    echo "$source_line" >> "$config_file"
    echo "✅ 已添加到 $config_file"
}

echo ""
read -p "是否添加到当前 shell 配置？(Y/n): " add_to_config
add_to_config=${add_to_config:-Y}

if [[ "$add_to_config" =~ ^[Yy]$ ]]; then
    current_shell=$(detect_shell)
    echo "检测到默认 shell: $current_shell"
    add_to_shell_config "$current_shell"
fi

echo ""
echo "=========================================="
echo "🎉 安装完成！"
echo "=========================================="
echo ""
echo "使用方法："
echo "  proxy_on      - 开启代理"
echo "  proxy_off     - 关闭代理"
echo "  proxy_status  - 查看状态"
echo "  proxy_toggle  - 一键切换"
echo ""
echo "卸载命令："
echo "  curl -sSL https://raw.githubusercontent.com/LittleY98/proxy-ctl/refs/heads/master/bin/install.sh | bash -s -- uninstall"
echo ""
