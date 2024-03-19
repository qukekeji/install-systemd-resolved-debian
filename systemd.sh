#!/bin/bash

# 更新系统软件包列表
sudo apt update

# 安装 systemd-resolved
sudo apt install systemd-resolved

# 启动 systemd-resolved 服务
sudo systemctl start systemd-resolved.service

# 让 systemd-resolved 开机自启
sudo systemctl enable systemd-resolved.service

# 配置 systemd-resolved 为系统默认的 DNS 解析器
sudo rm /etc/resolv.conf
sudo echo "nameserver 127.0.0.53" | sudo tee /etc/resolv.conf

# 编辑 /etc/systemd/resolved.conf 文件
sudo rm /etc/systemd/resolved.conf
sudo echo "[Resolve]" | sudo tee /etc/systemd/resolved.conf
sudo echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf
sudo echo "FallbackDNS=1.1.1.1 8.8.8.8" | sudo tee -a /etc/systemd/resolved.conf

# 重启 systemd-resolved 服务
sudo systemctl restart systemd-resolved

echo "DNS 设置已完成！"
