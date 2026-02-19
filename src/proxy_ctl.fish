# Clash Smart Proxy Switch for Fish

# 加载用户配置（如果存在）
if test -f "$HOME/.config/proxy_ctl/config.sh"
    bash -c "source $HOME/.config/proxy_ctl/config.sh && export" | while read -l line
        set -gx (string split '=' $line[1]) $line[2]
    end
end

# 设置默认值
if not set -q PROXY_HOST
    set -gx PROXY_HOST "127.0.0.1"
end
if not set -q PROXY_PORT
    set -gx PROXY_PORT "7890"
end
if not set -q PROXY_PROTOCOL
    set -gx PROXY_PROTOCOL "http"
end

# 拼接代理 URL
set -gx PROXY_URL "$PROXY_PROTOCOL://$PROXY_HOST:$PROXY_PORT"

# 检测端口是否监听
function _proxy_port_check
    nc -z $PROXY_HOST $PROXY_PORT >/dev/null 2>&1
end

# 检测代理是否真正可访问外网
function _proxy_connection_check
    curl -s --max-time 3 --proxy $PROXY_URL https://www.google.com >/dev/null 2>&1
end

# 开启代理
function proxy_on
    if not _proxy_port_check
        echo "❌ Clash 未运行（端口 $PROXY_PORT 未监听）"
        return 1
    end

    if not _proxy_connection_check
        echo "⚠️ 端口已开启，但代理无法访问外网"
        return 1
    end

    set -gx http_proxy $PROXY_URL
    set -gx https_proxy $PROXY_URL
    set -gx all_proxy $PROXY_URL
    set -gx HTTP_PROXY $PROXY_URL
    set -gx HTTPS_PROXY $PROXY_URL
    set -gx ALL_PROXY $PROXY_URL

    echo "✅ Proxy ON -> $PROXY_URL"
end

# 关闭代理
function proxy_off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e ALL_PROXY
    echo "❌ Proxy OFF"
end

# 查看状态
function proxy_status
    if not _proxy_port_check
        echo "🔴 Clash 未运行"
        return
    end

    if _proxy_connection_check
        echo "🟢 Clash 正常运行且可访问外网"
    else
        echo "🟡 Clash 运行中，但无法访问外网"
    end

    if test -n "$http_proxy"
        echo "当前 shell 代理：ON -> $http_proxy"
    else
        echo "当前 shell 代理：OFF"
    end
end

# 一键切换
function proxy_toggle
    if test -n "$http_proxy"
        proxy_off
    else
        proxy_on
    end
end
