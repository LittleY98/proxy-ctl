# 终端代理切换工具 (Fish)

if test -f "$HOME/.config/proxy_ctl/config.sh"
    bash -c "source $HOME/.config/proxy_ctl/config.sh && export" | while read -l line
        set -gx (string split '=' $line[1]) $line[2]
    end
end

if not set -q PROXY_HOST
    set -gx PROXY_HOST "127.0.0.1"
end
if not set -q PROXY_PORT
    set -gx PROXY_PORT "7890"
end
if not set -q PROXY_PROTOCOL
    set -gx PROXY_PROTOCOL "http"
end

set -gx PROXY_URL "$PROXY_PROTOCOL://$PROXY_HOST:$PROXY_PORT"

function _proxy_port_check
    nc -z $PROXY_HOST $PROXY_PORT >/dev/null 2>&1
end

function _proxy_connection_check
    curl -s --max-time 3 --proxy $PROXY_URL https://www.google.com >/dev/null 2>&1
end

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

function proxy_off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e ALL_PROXY
    echo "❌ Proxy OFF"
end

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

function proxy_toggle
    if test -n "$http_proxy"
        proxy_off
    else
        proxy_on
    end
end
