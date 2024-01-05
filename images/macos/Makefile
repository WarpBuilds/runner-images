pre-wb:
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.prepare.pkr.hcl
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.disable-sip.pkr.hcl
	packer build -var-file ../../variables.pkrvars.hcl templates/macOS-13.arm64.tart.pkr.hcl
