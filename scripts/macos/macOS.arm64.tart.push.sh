#!/bin/bash
set -euo pipefail

source scripts/utils.sh

# Check Prod env vars
check_env "IMAGE_HOST"
check_env "IMAGE_URI"
check_env "DOCKERHUB_LOGIN"
check_env "DOCKERHUB_PAT"
check_env "WARP_MAC_IMAGE_NAME"

echo "Logging into DockerHub for prod with host $IMAGE_HOST"

echo $DOCKERHUB_PAT | tart login --username $DOCKERHUB_LOGIN --password-stdin $IMAGE_HOST

echo "Pushing image to $IMAGE_URI"
tart push $WARP_MAC_IMAGE_NAME $IMAGE_URI
echo "Pushed image to $IMAGE_URI"
