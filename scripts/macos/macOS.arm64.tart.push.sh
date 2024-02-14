#!/bin/bash

source scripts/utils.sh

while [ $# -gt 0 ]; do
  case "$1" in
    --warp-env=*)
      warp_env="${1#*=}"
      ;;
    --mac_version=*)
      mac_image_name="m${1#*=}"
      ;;
    *)
      printf "Error: Invalid argument.\n"
      exit 1
  esac
  shift
done


cd images/macos

# Check Preprod env vars
check_env "PREPROD_IMAGE_HOST"
check_env "PREPROD_AWS_ACCESS_KEY_ID"
check_env "PREPROD_AWS_SECRET_ACCESS_KEY"
check_env "PREPROD_AWS_REGION"
check_env "PREPROD_IMAGE_URI"

echo "Logging into ECR for preprod with host $PREPROD_IMAGE_HOST"
login_pass=$(AWS_ACCESS_KEY_ID=${PREPROD_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${PREPROD_AWS_SECRET_ACCESS_KEY} \
  AWS_REGION=${PREPROD_AWS_REGION} \
  aws ecr get-login-password)

echo $login_pass | \
  tart login --username AWS --password-stdin $PREPROD_IMAGE_HOST

echo "Pushing image to preprod to $PREPROD_IMAGE_URI"
tart push $mac_image_name $PREPROD_IMAGE_URI
echo "Pushed image to preprod"

# Check if warp_env is not prod
if [ "$warp_env" != "prod" ]; then
  echo "Warp env is not prod, skipping prod push"
  exit 0
fi

# Check Prod env vars
check_env "PROD_IMAGE_HOST"
check_env "PROD_AWS_ACCESS_KEY_ID"
check_env "PROD_AWS_SECRET_ACCESS_KEY"
check_env "PROD_AWS_REGION"
check_env "PROD_IMAGE_URI"

echo "Logging into ECR for prod with host $PROD_IMAGE_HOST"
login_pass=$(AWS_ACCESS_KEY_ID=${PROD_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${PROD_AWS_SECRET_ACCESS_KEY} \
  AWS_REGION=${PROD_AWS_REGION} \
  aws ecr get-login-password)

echo $login_pass | \
  tart login --username AWS --password-stdin $PROD_IMAGE_HOST

echo "Pushing image to prod to $PROD_IMAGE_URI"
tart push $mac_image_name $PROD_IMAGE_URI
echo "Pushed image to prod"
