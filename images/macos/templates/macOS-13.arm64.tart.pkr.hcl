packer {
  required_plugins {
    tart = {
      version = ">= 1.2.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "vm_name" {
  type = string
}

variable "build_id" {
  type = string
}

variable "vm_username" {
  type = string
  default = "admin"
  sensitive = true
}

variable "vm_password" {
  type = string
  default = "admin"
  sensitive = true
}

variable "github_api_pat" {
  type = string
  default = ""
}

variable "vcpu_count" {
  type = number
  default = 6
}

variable "ram_size" {
  type = number
  default = 8
}

variable "image_os" {
  type = string
  default = "macos13"
}

variable "xcode_version" {
  type = string
  default = "15.1"
}

source "tart-cli" "tart" {
  vm_name      = "${var.vm_name}"
  cpu_count    = var.vcpu_count
  memory_gb    = var.ram_size
  disk_size_gb = 90
  headless     = true
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
}

build {
  sources = [
    "source.tart-cli.tart"
  ]
  provisioner "shell" {
    inline = [
      "mkdir ~/image-generation"
    ]
  }
  provisioner "file" {
    destination = "~/image-generation/"
    sources = [
      "./assets/xamarin-selector",
      "./scripts/tests",
      "./scripts/docs-gen",
      "./scripts/helpers"
    ]
  }
  provisioner "file" {
    destination = "~/image-generation/docs-gen/"
    source = "../../helpers/software-report-base"
  }
  provisioner "file" {
    destination = "~/image-generation/add-certificate.swift"
    source = "./assets/add-certificate.swift"
  }
  provisioner "file" {
    destination = "~/.bashrc"
    source = "./assets/bashrc"
  }
  provisioner "file" {
    destination = "~/.bash_profile"
    source = "./assets/bashprofile"
  }
  provisioner "shell" {
    inline = [
      "mkdir ~/bootstrap"
    ]
  }
  provisioner "file" {
    destination = "~/bootstrap"
    source = "./assets/bootstrap-provisioner"
  }
  provisioner "file" {
    destination = "~/image-generation/toolset.json"
    source = "./toolsets/toolset-13.json"
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/install-xcode-clt.sh",
      "./scripts/build/install-homebrew.sh",
      "./scripts/build/install-rosetta.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/configure-tccdb-macos.sh",
      "./scripts/build/configure-auto-updates.sh",
      "./scripts/build/configure-ntpconf.sh",
      "./scripts/build/configure-shell.sh"
    ]
    environment_vars = [
      "PASSWORD=${var.vm_password}",
      "USERNAME=${var.vm_username}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/configure-preimagedata.sh",
      "./scripts/build/configure-ssh.sh",
      "./scripts/build/configure-machine.sh"
    ]
    environment_vars = [
      "IMAGE_VERSION=${var.build_id}",
      "IMAGE_OS=${var.image_os}",
      "PASSWORD=${var.vm_password}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    inline = [
      "echo 'Reboot VM'",
      "shutdown -r now"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
  }
  provisioner "shell" {
    pause_before = "30s"
    scripts = [
      "./scripts/build/configure-windows.sh",
        "./scripts/build/install-powershell.sh",
        "./scripts/build/install-mono.sh",
        "./scripts/build/install-dotnet.sh",
        "./scripts/build/install-python.sh",
        "./scripts/build/install-azcopy.sh",
        "./scripts/build/install-openssl.sh",
        "./scripts/build/install-ruby.sh",
        "./scripts/build/install-rubygems.sh",
        "./scripts/build/install-git.sh",
        # "./scripts/build/install-mongodb.sh",
        "./scripts/build/install-node.sh",
        "./scripts/build/install-common-utils.sh"
    ]
    environment_vars = [
      "API_PAT=${var.github_api_pat}",
      "USER_PASSWORD=${var.vm_password}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  # provisioner "shell" {
  #   inline = [
  #     "echo 'export PATH=/usr/local/bin/:$PATH' >> ~/.zprofile",
  #     "source ~/.zprofile",
  #     "wget --quiet https://github.com/RobotsAndPencils/xcodes/releases/latest/download/xcodes.zip",
  #     "unzip xcodes.zip",
  #     "rm xcodes.zip",
  #     "chmod +x xcodes",
  #     "sudo mkdir -p /usr/local/bin/",
  #     "sudo mv xcodes /usr/local/bin/xcodes",
  #     "xcodes version",
  #     "wget --quiet https://storage.googleapis.com/xcodes-cache/Xcode_${var.xcode_version}.xip",
  #     "xcodes install ${var.xcode_version} --experimental-unxip --path $PWD/Xcode_${var.xcode_version}.xip",
  #     "sudo rm -rf ~/.Trash/*",
  #     "xcodes select ${var.xcode_version}",
  #     "xcodebuild -downloadAllPlatforms",
  #     "xcodebuild -runFirstLaunch",
  #   ]
  # }
  provisioner "shell" {
    script = "./provision/core/xcode.ps1"
    environment_vars = [
      "XCODE_INSTALL_STORAGE_URL=${var.xcode_install_storage_url}",
      "XCODE_INSTALL_SAS=${var.xcode_install_sas}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} pwsh -f {{ .Path }}"
  }
  provisioner "shell" {
    inline = [
      "echo 'Reboot VM'",
      "shutdown -r now"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/install-actions-cache.sh",
      "./scripts/build/install-llvm.sh",
      "./scripts/build/install-openjdk.sh",
      "./scripts/build/install-rust.sh",
      "./scripts/build/install-gcc.sh",
      "./scripts/build/install-cocoapods.sh",
      "./scripts/build/install-safari.sh",
      "./scripts/build/install-chrome.sh",
      "./scripts/build/install-bicep.sh",
      "./scripts/build/install-codeql-bundle.sh"
    ]
    environment_vars = [
      "API_PAT=${var.github_api_pat}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/Install-Toolset.ps1",
      "./scripts/build/Configure-Toolset.ps1"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} pwsh -f {{ .Path }}"
  }
  provisioner "shell" {
    script = "./scripts/build/configure-xcode-simulators.rb"
    execute_command = "source $HOME/.bash_profile; ruby {{ .Path }}"
  }
  provisioner "shell" {
    inline = [
      "pwsh -File \"$HOME/image-generation/software-report/SoftwareReport.Generator.ps1\" -OutputDirectory \"$HOME/image-generation/output/software-report\" -ImageName ${var.build_id}",
      "pwsh -File \"$HOME/image-generation/tests/RunAll-Tests.ps1\""
    ]
    execute_command = "source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "file" {
    destination = "../image-output/"
    direction = "download"
    source = "./image-generation/output/"
  }
  provisioner "shell" {
    scripts = [
      "./scripts/build/configure-hostname.sh",
      "./scripts/build/configure-system.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }

}
