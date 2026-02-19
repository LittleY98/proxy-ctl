#!/bin/bash

CONFIG_DIR="$HOME/.config/proxy_ctl"

echo "=========================================="
echo "       ProxyCTL 卸载脚本"
echo "=========================================="
echo ""

# 检测用户默认 shell
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

# 从配置文件移除 source 行
remove_from_shell_config() {
    local shell="$1"
    local config_file=""
    local marker="proxy_ctl"

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
            ;;
    esac

    if [ -z "$config_file" ] || [ ! -f "$config_file" ]; then
        echo "⏭️  未找到 $shell 配置文件"
        return 1
    fi

    # 检查是否包含 proxy_ctl
    if ! grep -q "$marker" "$config_file" 2>/dev/null; then
        echo "⏭️  $config_file 中无 proxy_ctl 配置"
        return 0
    fi

    # 移除 proxy_ctl 相关行
    local tmp_file
    tmp_file=$(mktemp)
    
    # 使用 sed 删除 proxy_ctl 相关的 3 行（空行 + 注释 + source）
    sed -i.bak "/# ProxyCTL/,/source.*proxy_ctl/d" "$config_file"
    rm -f "$config_file.bak"
    
    echo "✅ 已从 $config_file 移除 proxy_ctl"
}

# 询问确认
read -p "确认卸载 ProxyCTL？(y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 移除配置文件目录
if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "✅ 已删除配置目录: $CONFIG_DIR"
else
    echo "⏭️  配置目录不存在，跳过"
fi

# 移除 shell 配置
current_shell=$(detect_shell)
echo "检测到默认 shell: $current_shell"
remove_from_shell_config "$current_shell"

# 询问是否移除其他 shell 配置
echo ""
read -p "是否移除其他 shell 配置？(y/N): " remove_others
if [[ "$remove_others" =~ ^[Yy]$ ]]; then
    for shell in zsh bash fish; do
        [ "$shell" = "$current_shell" ] && continue
        remove_from_shell_config "$shell"
    done
fi

echo ""
echo "=========================================="
echo "🎉 卸载完成！"
echo "=========================================="
