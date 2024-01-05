#!/bin/bash 
################################################################################
##  File:  validate-agent.sh
##  Desc:  Validates that warpbuild agent is properly configured
################################################################################

set -e -o pipefail

source ~/utils/utils.sh

# check that the user level agent is configured correctly by list launchctl
# 

echo "Validating Warp Agent"

if ! launchctl list | grep -q com.warpbuild.warpbuild-agentd-launcher.plist; then
    echo "Warp Agent is not running"
    exit 1
fi
