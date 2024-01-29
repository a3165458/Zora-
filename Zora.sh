#!/bin/bash


set -e

# 更新组件
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential git screen jq pkg-config libssl-dev libclang-dev ca-certificates gnupg lsb-release -y
sudo apt-get install docker-compose

# 下载资源
git clone https://github.com/conduitxyz/node.git
cd node
./download-config.py zora-mainnet-0
export CONDUIT_NETWORK=zora-mainnet-0
cp .env.example .env

# 修改env
# Note: This will open the nano editor, the script will pause until you exit nano
nano .env

# 启动Screen
screen -S Zora

# 运行节点
echo "启动 Docker 容器..."
docker-compose up --build

# 设置自动重启
echo "设置容器自动重启..."
docker update --restart=unless-stopped node-node-1
docker update --restart=unless-stopped node-geth-1
