#!/bin/bash

cd /runner
curl -f -L -o warpbuild-agent.tar.gz https://github.com/WarpBuilds/warpbuild-agent/releases/download/v0.1.0-alpha.2/warpbuild-agentd_Linux_x86_64.tar.gz
mkdir warpbuild-agent/
tar -xzf warpbuild-agent.tar.gz -C warpbuild-agent/
rm warpbuild-agent.tar.gz
sudo cp warpbuild-agent/warpbuild-agentd /usr/local/bin/warpbuild-agentd
sudo chmod +x /usr/local/bin/warpbuild-agentd
sudo cp warpbuild-agent/tools/systemd/warpbuild-agentd.service /etc/systemd/system/warpbuild-agentd.service
sudo systemctl daemon-reload
sudo systemctl enable warpbuild-agentd.service
sudo systemctl start warpbuild-agentd.service
