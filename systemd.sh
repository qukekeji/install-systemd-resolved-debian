#!/bin/bash

# 定义 DNS 服务器
DNS_SERVERS=("8.8.8.8" "9.9.9.9" "8.8.4.4" "1.1.1.1" "1.0.0.1")

# 更新系统软件包列表
sudo apt update

# 安装 systemd-resolved
sudo apt install -y systemd-resolved

# 启动 systemd-resolved 服务
sudo systemctl start systemd-resolved.service

# 让 systemd-resolved 开机自启
sudo systemctl enable systemd-resolved.service

# 测量 DNS 服务器的延迟
echo "测量 DNS 服务器的延迟..."
declare -A DNS_LATENCY
for dns in "${DNS_SERVERS[@]}"; do
    latency=$(ping -c 3 -q "$dns" | grep -oP '(?<=min/avg/max/mdev = )[^/]+/\K[^/]+')
    DNS_LATENCY["$dns"]=$latency
    echo "DNS: $dns 延迟: ${latency}ms"
done

# 按延迟排序 DNS 服务器
sorted_dns=($(for dns in "${!DNS_LATENCY[@]}"; do echo "$dns ${DNS_LATENCY[$dns]}"; done | sort -k2 -n | awk '{print $1}'))

# 选择延迟最低的 DNS 服务器
primary_dns=${sorted_dns[0]}
secondary_dns=${sorted_dns[1]}

echo "选择的 DNS 服务器: $primary_dns (主) $secondary_dns (备用)"

# 配置 systemd-resolved 为系统默认的 DNS 解析器
sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.53" | sudo tee /etc/resolv.conf

# 编辑 /etc/systemd/resolved.conf 文件
sudo rm -f /etc/systemd/resolved.conf
sudo touch /etc/systemd/resolved.conf

echo "[Resolve]" | sudo tee -a /etc/systemd/resolved.conf
echo "DNS=$primary_dns $secondary_dns" | sudo tee -a /etc/systemd/resolved.conf
echo "FallbackDNS=${sorted_dns[@]:2}" | sudo tee -a /etc/systemd/resolved.conf

# 重启 systemd-resolved 服务
sudo systemctl restart systemd-resolved

echo "DNS 设置已完成！"
