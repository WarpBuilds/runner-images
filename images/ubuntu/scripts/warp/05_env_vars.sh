#!/bin/bash

source $HELPER_SCRIPTS/etc-environment.sh

# echo "RUNNER_TOOLCACHE=/opt/hostedtoolcache" | sudo tee -a /etc/environment
setEtcEnvironmentVariable "RUNNER_TOOL_CACHE" "/opt/hostedtoolcache"
