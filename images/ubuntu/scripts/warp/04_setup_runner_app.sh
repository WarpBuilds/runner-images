#!/bin/bash

cd /runner
curl -f -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v2.313.0/actions-runner-linux-x64-2.313.0.tar.gz \
        && tar xzf ./runner.tar.gz \
        && rm runner.tar.gz

curl -f -L -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v0.5.1/actions-runner-hooks-k8s-0.5.1.zip \
        && unzip ./runner-container-hooks.zip -d ./k8s \
        && rm runner-container-hooks.zip

export DEBIAN_FRONTEND=noninteractive
