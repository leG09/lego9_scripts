#!/bin/bash

# 获取域名的IP地址
ip_address=$(ping -c 1 cf1.1yy.us.kg | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ -n "$ip_address" ]; then
    # 检查hosts文件中是否已存在该域名的记录
    if grep -q "www.pttime.org" /etc/hosts; then
        # 如果存在，则更新IP地址
        # 使用临时文件来避免 "Resource busy" 错误
        sed "s/.*www.pttime.org/$ip_address www.pttime.org/" /etc/hosts > /tmp/hosts.new
        cat /tmp/hosts.new > /etc/hosts
        rm /tmp/hosts.new
    else
        # 如果不存在，则添加新记录
        echo "$ip_address www.pttime.org" >> /etc/hosts
    fi
fi

