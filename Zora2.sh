#!/bin/bash

# 安装Docker
sudo apt-get install docker.io
sudo systemctl start docker


# 运行节点
echo "启动 Docker 容器..."
docker compose up --build

# 设置自动重启
echo "设置容器自动重启..."
docker update --restart=unless-stopped node-node-1
docker update --restart=unless-stopped node-geth-1

# 检查日志
echo "正在查看 node-node-1 的日志..."
docker logs -f node-node-1 &
echo "正在查看 node-geth-1 的日志..."
docker logs -f node-geth-1 &
