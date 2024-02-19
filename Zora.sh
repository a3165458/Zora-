#!/bin/bash

# 更新组件
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential git screen jq pkg-config libssl-dev libclang-dev ca-certificates nano gnupg lsb-release -y

# 升级所有已安装的包
sudo apt upgrade -y


# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    # 如果 Docker 未安装，则进行安装
    echo "未检测到 Docker，正在安装..."
    sudo apt-get install ca-certificates curl gnupg lsb-release

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

# 检查 Docker Compose 是否已安装
if ! command -v docker compose &> /dev/null
then
    echo "未检测到 Docker Compose，正在安装..."
    sudo apt install docker compose -y
else
    echo "Docker Compose 已安装。"
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
docker compose up --build -d
