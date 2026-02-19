#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/proxy_ctl"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "       ProxyCTL 一键安装脚本"
echo "=========================================="
echo ""

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 交互式配置
echo "请配置代理信息（直接回车使用默认值）："
echo ""

read -p "代理 Host [$PROXY_HOST_DEFAULT]: " PROXY_HOST
PROXY_HOST=${PROXY_HOST:-$PROXY_HOST_DEFAULT}
PROXY_HOST_DEFAULT="127.0.0.1"

read -p "代理 Port [$PROXY_PORT_DEFAULT]: " PROXY_PORT
PROXY_PORT=${PROXY_PORT:-$PROXY_PORT_DEFAULT}
PROXY_PORT_DEFAULT="7890"

read -p "代理 URL [http://$PROXY_HOST:$PROXY_PORT]: " PROXY_URL
PROXY_URL=${PROXY_URL:-"http://$PROXY_HOST:$PROXY_PORT"}

# 写入配置文件
cat > "$CONFIG_DIR/config.sh" <<EOF
# ProxyCTL 配置文件
# 由 install.sh 自动生成

export PROXY_HOST="$PROXY_HOST"
export PROXY_PORT="$PROXY_PORT"
export PROXY_URL="$PROXY_URL"
EOF

echo ""
echo "✅ 配置文件已保存到: $CONFIG_DIR/config.sh"

# 检测当前 shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$FISH_VERSION" ]; then
        echo "fish"
    else
        echo "unknown"
    fi
}

# 添加到 shell 配置
add_to_shell_config() {
    local shell="$1"
    local config_file=""
    local source_line="source $CONFIG_DIR/proxy_ctl.sh"

    case "$shell" in
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                config_file="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                config_file="$HOME/.bash_profile"
            fi
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            source_line="source $CONFIG_DIR/proxy_ctl.fish"
            ;;
    esac

    if [ -z "$config_file" ] || [ ! -f "$config_file" ]; then
        echo "⚠️ 未找到 $shell 配置文件，跳过"
        return 1
    fi

    # 检查是否已添加
    if grep -q "proxy_ctl" "$config_file" 2>/dev/null; then
        echo "⏭️  $shell 配置已包含 proxy_ctl，跳过"
        return 0
    fi

    echo "" >> "$config_file"
    echo "# ProxyCTL" >> "$config_file"
    echo "$source_line" >> "$config_file"
    echo "✅ 已添加到 $config_file"
}

# 复制脚本到配置目录
cp "$SCRIPT_DIR/proxy_ctl.sh" "$CONFIG_DIR/proxy_ctl.sh"
cp "$SCRIPT_DIR/proxy_ctl.fish" "$CONFIG_DIR/proxy_ctl.fish"
cp "$SCRIPT_DIR/proxy_ctl.zsh" "$CONFIG_DIR/proxy_ctl.zsh"

echo "✅ 脚本已复制到: $CONFIG_DIR"
echo ""

# 询问是否添加到 shell 配置
read -p "是否添加到当前 shell 配置？(Y/n): " add_to_config
add_to_config=${add_to_config:-Y}

if [[ "$add_to_config" =~ ^[Yy]$ ]]; then
    current_shell=$(detect_shell)
    echo "检测到当前 shell: $current_shell"
    add_to_shell_config "$current_shell"
    
    # 同时添加到其他常用 shell 配置
    echo ""
    read -p "是否也添加到其他 shell 配置？(y/N): " add_others
    if [[ "$add_others" =~ ^[Yy]$ ]]; then
        for shell in zsh bash fish; do
            add_to_shell_config "$shell"
        done
    fi
fi

echo ""
echo "=========================================="
echo "🎉 安装完成！"
echo "=========================================="
echo ""
echo "使用方法："
echo "  proxy_on      - 开启代理"
echo "  proxy_off     - 关闭代理"
echo "  proxy_status - 查看状态"
echo "  proxy_toggle  - 一键切换"
echo ""
echo "配置文件: $CONFIG_DIR/config.sh"
echo ""
