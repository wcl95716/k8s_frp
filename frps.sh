#!/bin/bash

# ========================== 默认配置 ==========================
FRP_VERSION="0.53.0"
FRP_PORT="7000"                # FRP 服务器端口
DASHBOARD_PORT="7500"          # FRP 面板端口
TOKEN="frp-secret"             # 通信密钥
DASHBOARD_USER="admin"         # 控制面板用户名
DASHBOARD_PASSWORD="admin123"  # 控制面板密码
INSTALL_DIR="./"         # 安装目录

# ========================== 开始安装 ==========================
set -e

# 1. 下载 FRP
echo "📥 正在下载 FRP 版本 $FRP_VERSION..."
wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz -O /tmp/frp.tar.gz
mkdir -p $INSTALL_DIR
tar -xzf /tmp/frp.tar.gz -C /tmp
cp -r /tmp/frp_${FRP_VERSION}_linux_amd64/* $INSTALL_DIR
rm -rf /tmp/frp*

# 2. 创建配置文件
cat > $INSTALL_DIR/frps.ini <<EOF
[common]
bind_port = ${FRP_PORT}
dashboard_port = ${DASHBOARD_PORT}
dashboard_user = ${DASHBOARD_USER}
dashboard_pwd = ${DASHBOARD_PASSWORD}
token = ${TOKEN}
EOF

# 3. 创建 systemd 服务
cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
ExecStart=$INSTALL_DIR/frps -c $INSTALL_DIR/frps.ini
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 4. 开放防火墙端口（如果启用 UFW）
ufw allow ${FRP_PORT}/tcp
ufw allow ${DASHBOARD_PORT}/tcp

# 5. 启动服务并设置为开机自启
systemctl daemon-reload
systemctl enable frps
systemctl restart frps

# 6. 显示状态
sleep 2
systemctl status frps --no-pager

# ========================== 安装完成 ==========================
echo ""
echo "🎉 FRP 服务器已安装并启动成功！"
echo "🌐 公网端口: $FRP_PORT"
echo "📡 控制面板地址: http://<你的服务器IP>:${DASHBOARD_PORT}"
echo "👤 用户名: ${DASHBOARD_USER}"
echo "🔒 密码: ${DASHBOARD_PASSWORD}"
echo "🔑 Token: ${TOKEN}"
