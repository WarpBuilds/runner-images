#!/bin/bash
set -e


cd images/macos

echo "Logging into ECR for preprod"
AWS_ACCESS_KEY_ID=${PREPROD_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${PREPROD_AWS_SECRET_ACCESS_KEY} \
  AWS_REGION=${PREPROD_AWS_REGION} \
  aws ecr get-login-password | \
  IMAGE_HOST=${PREPROD_IMAGE_HOST} \
  tart login --username AWS --password-stdin ${IMAGE_HOST}

echo "Pushing image to preprod"
IMAGE_URL=${PREPROD_IMAGE_HOST} \
 tart push s2 ${IMAGE_URL}
echo "Pushed image to preprod"

echo "Logging into ECR for prod"
AWS_ACCESS_KEY_ID=${PROD_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${PROD_AWS_SECRET_ACCESS_KEY} \
  AWS_REGION=${PROD_AWS_REGION} \
  aws ecr get-login-password | \
  IMAGE_HOST=${PROD_IMAGE_HOST} \
  tart login --username AWS --password-stdin ${IMAGE_HOST}

echo "Pushing image to prod"
IMAGE_URL=${PROD_IMAGE_HOST} \
  tart push s2 ${IMAGE_URL}
echo "Pushed image to prod"
