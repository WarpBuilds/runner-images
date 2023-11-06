validate-ubuntu2204:
	packer validate -var-file=ubuntu2204.qemu.json ubuntu2204.qemu.pkr.hcl
build-ubuntu2204:
	PACKER_LOG=1 packer build -var-file=ubuntu2204.qemu.json ubuntu2204.qemu.pkr.hcl
