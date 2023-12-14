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
  type = string
  default = "6"
}

variable "ram_size" {
  type = string
  default = "8G"
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
    destination = "image-generation/"
    sources = [
      "./provision/assets",
      "./tests",
      "./software-report",
      "./helpers"
    ]
  }
  provisioner "file" {
    destination = "image-generation/software-report/"
    source = "../../helpers/software-report-base"
  }
  provisioner "file" {
    destination = "image-generation/add-certificate.swift"
    source = "./provision/configuration/add-certificate.swift"
  }
  provisioner "file" {
    destination = ".bashrc"
    source = "./provision/configuration/environment/bashrc"
  }
  provisioner "file" {
    destination = ".bash_profile"
    source = "./provision/configuration/environment/bashprofile"
  }
  provisioner "file" {
    destination = "./"
    source = "./provision/utils"
  }
  provisioner "shell" {
    inline = [
      "mkdir ~/bootstrap"
    ]
  }
  provisioner "file" {
    destination = "bootstrap"
    source = "./provision/bootstrap-provisioner/"
  }
  provisioner "file" {
    destination = "image-generation/toolset.json"
    source = "./toolsets/toolset-13.json"
  }
  provisioner "shell" {
    scripts = [
      "./provision/core/xcode-clt.sh",
      "./provision/core/homebrew.sh",
      "./provision/core/rosetta.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./provision/configuration/configure-tccdb-macos.sh",
      "./provision/configuration/disable-auto-updates.sh",
      "./provision/configuration/ntpconf.sh",
      "./provision/configuration/shell-change.sh"
    ]
    environment_vars = [
      "PASSWORD=${var.vm_password}",
      "USERNAME=${var.vm_username}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./provision/configuration/preimagedata.sh",
      "./provision/configuration/configure-ssh.sh",
      "./provision/configuration/configure-machine.sh"
    ]
    environment_vars = [
      "IMAGE_VERSION=${var.build_id}",
      "IMAGE_OS=${var.image_os}",
      "PASSWORD=${var.vm_password}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    script  = "./provision/core/reboot.sh"
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
  }
  provisioner "shell" {
    pause_before = "30s"
    scripts = [
      "./provision/core/open_windows_check.sh",
      "./provision/core/powershell.sh",
      "./provision/core/mono.sh",
      "./provision/core/dotnet.sh",
      "./provision/core/azcopy.sh",
      "./provision/core/openssl.sh",
      "./provision/core/ruby.sh",
      "./provision/core/rubygem.sh",
      "./provision/core/git.sh",
      "./provision/core/node.sh",
      "./provision/core/commonutils.sh"
    ]
    environment_vars = [
      "API_PAT=${var.github_api_pat}",
      "USER_PASSWORD=${var.vm_password}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    inline = [
      "echo 'export PATH=/usr/local/bin/:$PATH' >> ~/.zprofile",
      "source ~/.zprofile",
      "wget --quiet https://github.com/RobotsAndPencils/xcodes/releases/latest/download/xcodes.zip",
      "unzip xcodes.zip",
      "rm xcodes.zip",
      "chmod +x xcodes",
      "sudo mkdir -p /usr/local/bin/",
      "sudo mv xcodes /usr/local/bin/xcodes",
      "xcodes version",
      "wget --quiet https://storage.googleapis.com/xcodes-cache/Xcode_${var.xcode_version}.xip",
      "xcodes install ${var.xcode_version} --experimental-unxip --path $PWD/Xcode_${var.xcode_version}.xip",
      "sudo rm -rf ~/.Trash/*",
      "xcodes select ${var.xcode_version}",
      "xcodebuild -downloadAllPlatforms",
      "xcodebuild -runFirstLaunch",
    ]
  }
  # provisioner "shell" {
  #   script = "./provision/core/xcode.ps1"
  #   environment_vars = [
  #     "XCODE_INSTALL_STORAGE_URL=${var.xcode_install_storage_url}",
  #     "XCODE_INSTALL_SAS=${var.xcode_install_sas}"
  #   ]
  #   execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} pwsh -f {{ .Path }}"
  # }
  provisioner "shell" {
    script = "./provision/core/reboot.sh"
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; sudo {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
  }
  provisioner "shell" {
    scripts = [
      "./provision/core/action-archive-cache.sh",
      "./provision/core/llvm.sh",
      "./provision/core/openjdk.sh",
      "./provision/core/rust.sh",
      "./provision/core/gcc.sh",
      "./provision/core/cocoapods.sh",
      "./provision/core/safari.sh",
      "./provision/core/chrome.sh",
      "./provision/core/bicep.sh",
      "./provision/core/codeql-bundle.sh"
    ]
    environment_vars = [
      "API_PAT=${var.github_api_pat}"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      "./provision/core/toolset.ps1",
      "./provision/core/configure-toolset.ps1"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} pwsh -f {{ .Path }}"
  }
  provisioner "shell" {
    script = "./provision/core/delete-duplicate-sims.rb"
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
      "./provision/configuration/configure-hostname.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; source $HOME/.bash_profile; {{ .Vars }} {{ .Path }}"
  }

}
