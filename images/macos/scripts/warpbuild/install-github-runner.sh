#!/bin/bash -e -o pipefail
################################################################################
##  File:  install-github-runner.sh
##  Desc:  Installs and configures github runner
################################################################################

source ~/utils/utils.sh

echo "Creating warpbuild directories ..."
mkdir -p ~/.warpbuild/github-runner
BASE_DIR=~/.warpbuild/github-runner

export TARGETARCH=${TARGETARCH:-arm64}
export TARGETOS=${TARGETOS:-osx}
export RUNNER_VERSION=${RUNNER_VERSION:-2.311.0}
export RUNNER_CONTAINER_HOOKS_VERSION=${RUNNER_CONTAINER_HOOKS_VERSION:-0.3.2}
export RUNNER_ARCH=$TARGETARCH \
	&& if [ "$RUNNER_ARCH" = "amd64" ]; then export RUNNER_ARCH=x64 ; fi \
	&& curl -f -L -o $BASE_DIR/runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${TARGETOS}-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz \
	&& tar xzf $BASE_DIR/runner.tar.gz \
	&& rm $BASE_DIR/runner.tar.gz

curl -f -L -o $BASE_DIR/runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip \
	&& unzip $BASE_DIR/runner-container-hooks.zip -d ./k8s \
	&& rm $BASE_DIR/runner-container-hooks.zip

echo "Runner download complete ..."
