# ===== Clash Smart Proxy Switch (Bash/Zsh) =====
# 兼容: Bash, Zsh, Dash 等 POSIX shell

# 加载用户配置（如果存在）
if [ -f "$HOME/.config/proxy_ctl/config.sh" ]; then
    . "$HOME/.config/proxy_ctl/config.sh"
else
    export PROXY_HOST="127.0.0.1"
    export PROXY_PORT="7890"
fi

# 确保 PROXY_URL 已设置
if [ -z "$PROXY_URL" ]; then
    export PROXY_URL="http://${PROXY_HOST}:${PROXY_PORT}"
fi

# 检测端口是否监听
_proxy_port_check() {
    nc -z "${PROXY_HOST}" "${PROXY_PORT}" >/dev/null 2>&1
}

# 检测代理是否真正可访问外网
_proxy_connection_check() {
    curl -s --max-time 3 --proxy "${PROXY_URL}" https://www.google.com >/dev/null 2>&1
}

# 开启代理
proxy_on() {
    if ! _proxy_port_check; then
        echo "❌ Clash 未运行（端口 ${PROXY_PORT} 未监听）"
        return 1
    fi

    if ! _proxy_connection_check; then
        echo "⚠️ 端口已开启，但代理无法访问外网"
        return 1
    fi

    export http_proxy="${PROXY_URL}"
    export https_proxy="${PROXY_URL}"
    export all_proxy="${PROXY_URL}"
    export HTTP_PROXY="${PROXY_URL}"
    export HTTPS_PROXY="${PROXY_URL}"
    export ALL_PROXY="${PROXY_URL}"

    echo "✅ Proxy ON -> $PROXY_URL"
}

# 关闭代理
proxy_off() {
    unset http_proxy https_proxy all_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
    echo "❌ Proxy OFF"
}

# 查看状态
proxy_status() {
    if ! _proxy_port_check; then
        echo "🔴 Clash 未运行"
        return
    fi

    if _proxy_connection_check; then
        echo "🟢 Clash 正常运行且可访问外网"
    else
        echo "🟡 Clash 运行中，但无法访问外网"
    fi

    if [ -n "$http_proxy" ]; then
        echo "当前 shell 代理：ON -> $http_proxy"
    else
        echo "当前 shell 代理：OFF"
    fi
}

# 一键切换
proxy_toggle() {
    if [ -n "$http_proxy" ]; then
        proxy_off
    else
        proxy_on
    fi
}
