#!/bin/bash

set -e

BIND_ADDRESS="0.0.0.0"

echo "[1/5] Updating apt packages..."
sudo apt update -y

echo "[2/5] Installing MySQL server..."
sudo apt install mysql-server -y

echo "[3/5] Configuring MySQL root user..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"

echo "[4/5] Configuring MySQL to listen on all interfaces..."
sudo sed -i "s/^bind-address\s*=.*/bind-address = ${BIND_ADDRESS}/" /etc/mysql/mysql.conf.d/mysqld.cnf

echo "[5/5] Restarting MySQL service..."
sudo systemctl restart mysql

echo ""
echo "✅ MySQL 8.0 설치 완료!"
echo "🔐 root 비밀번호: ${MYSQL_ROOT_PASSWORD}"