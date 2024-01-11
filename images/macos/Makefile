pre-wb:
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.prepare.pkr.hcl
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.disable-sip.pkr.hcl
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.pkr.hcl

wb:
	packer build -var-file ../../variables.pkrvars.hcl templates/warpbuild.pkr.hcl

ci-pre-wb:
	packer build \
		-var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
		templates/macOS-13.arm64.tart.prepare.pkr.hcl
	packer build \
		-var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
		templates/macOS-13.arm64.tart.disable-sip.pkr.hcl
	packer build \
		-var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
		-var "github_api_pat=${GITHUB_API_PAT}" \
		-var "xcode_install_storage_url=${XCODE_INSTALL_STORAGE_URL}" \
		templates/macOS-13.arm64.tart.pkr.hcl

ci-wb:
	packer build \
		-var-file ./variables/macos-13.arm64.tart.pkrvars.hcl \
		templates/warpbuild.pkr.hcl

ci-post-wb:
	AWS_ACCESS_KEY_ID=${PREPROD_AWS_ACCESS_KEY_ID} \
	AWS_SECRET_ACCESS_KEY=${PREPROD_AWS_SECRET_ACCESS_KEY} \
	AWS_REGION=${PREPROD_AWS_REGION} \
	aws ecr get-login-password | \
	IMAGE_URL=${PREPROD_IMAGE_URL} \
	tart login --username AWS --password-stdin ${IMAGE_URL}

	AWS_ACCESS_KEY_ID=${PROD_AWS_ACCESS_KEY_ID} \
	AWS_SECRET_ACCESS_KEY=${PROD_AWS_SECRET_ACCESS_KEY} \
	AWS_REGION=${PROD_AWS_REGION} \
	aws ecr get-login-password | \
	IMAGE_URL=${PROD_IMAGE_URL} \
	tart login --username AWS --password-stdin ${IMAGE_URL}
