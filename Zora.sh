#!/bin/bash

# 更新组件
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential git screen jq pkg-config libssl-dev libclang-dev ca-certificates nano gnupg lsb-release -y

# 升级所有已安装的包
sudo apt upgrade -y

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "未检测到 Docker，正在安装..."
    # 安装 Docker 前的准备
    sudo apt-get install ca-certificates curl gnupg lsb-release -y
    # 添加 Docker 官方 GPG 密钥
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    # 设置 Docker 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # 授权 Docker 文件
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt-get update
    # 安装 Docker 最新版本
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
else
    echo "Docker 已安装。"
fi

# 定义版本比较函数
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# 检查 Docker Compose 是否已安装并检查其版本
if ! command -v docker-compose &> /dev/null
then
    echo "未检测到 Docker Compose，正在安装..."
    sudo apt install docker-compose -y
else
    # 获取当前 Docker Compose 的版本
    CURRENT_VER=$(docker-compose --version | sed 's/docker-compose version \(.*\),.*/\1/')
    MIN_VER="1.29.2"
    # 比较当前版本与最小要求版本
    if version_gt "$MIN_VER" "$CURRENT_VER"; then
        echo "Docker Compose 的当前版本 ($CURRENT_VER) 低于最小要求版本 ($MIN_VER)，正在升级..."
        # 移除旧版本
        sudo rm $(which docker-compose)
        # 安装新版本
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose 的当前版本为 $CURRENT_VER，满足最小要求版本 ($MIN_VER)。"
    fi
fi

# 验证 Docker Engine 安装是否成功
sudo docker run hello-world

# 下载资源
git clone https://github.com/conduitxyz/node.git
cd node
./download-config.py zora-mainnet-0
export CONDUIT_NETWORK=zora-mainnet-0
cp .env.example .env

# 输入对应L1 RPC信息
read -p "请输入对应L1ETH的RPC网址: " OP_NODE_L1_ETH_RPC

# 将用户输入的值写入.env文件
sed -i "s|OP_NODE_L1_ETH_RPC=.*|OP_NODE_L1_ETH_RPC=${OP_NODE_L1_ETH_RPC}|" .env

# Docker组建
docker-compose up --build -d
