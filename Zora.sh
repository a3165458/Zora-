#!/bin/bash

# Stop the script if any command fails
set -e

# 1. Update and install packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential git screen jq pkg-config libssl-dev libclang-dev ca-certificates gnupg lsb-release -y

# 2. Download Source
git clone https://github.com/conduitxyz/node.git
cd node
./download-config.py zora-mainnet-0
export CONDUIT_NETWORK=zora-mainnet-0
cp .env.example .env

# 3. Edit .env
# Note: This will open the nano editor, the script will pause until you exit nano
nano .env
