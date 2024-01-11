#!/bin/bash
set -e

cd images/macos

echo "Booting up new vm from ipsw base image"
packer build \
  -var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
  templates/macOS-13.arm64.tart.prepare.pkr.hcl
echo "Disabling SIP"
packer build \
  -var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
  templates/macOS-13.arm64.tart.disable-sip.pkr.hcl
echo "Setting up the runner-image"
packer build \
  -var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
  -var "github_api_pat=${GITHUB_API_PAT}" \
  -var "xcode_install_storage_url=${XCODE_INSTALL_STORAGE_URL}" \
  templates/macOS-13.arm64.tart.pkr.hcl
echo "Setting up warpbuild components"
packer build \
  -var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
  templates/warpbuild.pkr.hcl
