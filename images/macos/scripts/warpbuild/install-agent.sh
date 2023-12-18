#!/bin/bash -e -o pipefail
################################################################################
##  File:  install-agent.sh
##  Desc:  Installs and configures warpbuild agent
################################################################################

source ~/utils/utils.sh

echo "Creating warpbuild directories ..."
mkdir -p ~/.warpbuild/agent

BASE_DIR=$(echo ~/.warpbuild/agent)
VERSION=v0.2.0-alpha.1
USERNAME=$(whoami)

echo "Downloading warpbuild-agentd $VERSION..."
curl -f -L -o $BASE_DIR/warpbuild-agentd.tar.gz https://github.com/WarpBuilds/warpbuild-agent/releases/download/$VERSION/warpbuild-agentd_Darwin_arm64.tar.gz
mkdir -p $BASE_DIR/warpbuild-agentd
tar -xzf $BASE_DIR/warpbuild-agentd.tar.gz -C $BASE_DIR/warpbuild-agentd
rm $BASE_DIR/warpbuild-agentd.tar.gz
sudo mkdir -p /usr/local/bin
sudo mv $BASE_DIR/warpbuild-agentd/warpbuild-agentd /usr/local/bin/warpbuild-agentd
sudo chmod +x /usr/local/bin/warpbuild-agentd

echo "Configuring agent ..."

cat << EOF > $BASE_DIR/com.warpbuild.warpbuild-agentd.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.warpbuild.warpbuild-agentd</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/warpbuild-agentd</string>
        <string>--settings=$BASE_DIR/settings.json</string>
    </array>
    <key>UserName</key>
    <string>$USERNAME</string>
    <key>WorkingDirectory</key>
    <string>/</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$BASE_DIR/log/warpbuild-agentd.error.log</string>
    <key>StandardOutPath</key>
    <string>$BASE_DIR/log/warpbuild-agentd.out.log</string>
    <key>ThrottleInterval</key>
    <integer>5</integer>
</dict>
</plist>
EOF

echo "Adding agent to launchd ..."
sudo mv $BASE_DIR/com.warpbuild.warpbuild-agentd.plist /Library/LaunchDaemons/com.warpbuild.warpbuild-agentd.plist
echo "Setting agent permissions ..."
sudo chown root:wheel /Library/LaunchDaemons/com.warpbuild.warpbuild-agentd.plist
echo "Loading agent ..."
sudo launchctl load /Library/LaunchDaemons/com.warpbuild.warpbuild-agentd.plist
echo "Starting agent ..."
sudo launchctl start com.warpbuild.warpbuild-agentd

echo "Agent setup complete."
