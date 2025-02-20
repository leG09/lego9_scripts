#!/bin/sh

# 从新源获取 Cloudflare IPv4 地址
ips=$(curl -s https://www.wetest.vip/page/cloudflare/address_v4.html | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')

# 将 IP 列表转换为以空格分隔的字符串
ip_list=$(echo "$ips" | tr '\n' ' ')

# 尝试 IP 直到找到可用的
while [ -n "$ip_list" ]; do
    # 随机选择一个 IP
    ip_count=$(echo "$ip_list" | wc -w)
    random_index=$((RANDOM % ip_count + 1))
    latest_ip=$(echo "$ip_list" | cut -d' ' -f$random_index)
    
    # 更新 /etc/hosts 文件
    echo "尝试 Cloudflare IPv4 地址: $latest_ip"
    sed -i '/www.pttime.org/d' /etc/hosts
    echo "$latest_ip www.pttime.org" >> /etc/hosts
    
    # 更新 Docker 容器的 hosts 文件
    docker exec qinglong bash -c "grep -v 'www.pttime.org' /etc/hosts > /tmp/hosts.new && cat /tmp/hosts.new > /etc/hosts && echo '$latest_ip www.pttime.org' >> /etc/hosts && rm /tmp/hosts.new"
    
    # 测试 IP 是否可用
    if curl -s --connect-timeout 5 https://www.pttime.org > /dev/null; then
        echo "IP $latest_ip 可用"
        break
    else
        echo "IP $latest_ip 不可用，尝试下一个"
        # 从列表中移除不可用的 IP
        ip_list=$(echo "$ip_list" | sed "s/$latest_ip//" | tr -s ' ')
    fi
done

echo "已更新 /etc/hosts 文件"
