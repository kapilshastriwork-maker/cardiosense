terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "coder" {}

data "coder_parameter" "repo_url" {
  name         = "repo_url"
  display_name = "CardioSense Repository"
  description  = "GitHub repository URL for CardioSense"
  type         = "string"
  default      = "https://github.com/kapilshastriwork-maker/cardiosense"
  order        = 1
}

data "coder_parameter" "python_version" {
  name         = "python_version"
  display_name = "Python Version"
  description  = "Select Python version for the workspace"
  type         = "string"
  default      = "3.11"
  order        = 2

  option {
    name  = "Python 3.11"
    value = "3.11"
  }
  option {
    name  = "Python 3.10"
    value = "3.10"
  }
}

data "coder_parameter" "enable_gpu" {
  name         = "enable_gpu"
  display_name = "Enable GPU Support?"
  description  = "Enable GPU acceleration for model training"
  type         = "bool"
  default      = false
  order        = 3
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch = "amd64"
  os   = "linux"

  startup_script = <<-EOT
    #!/bin/bash
    git clone ${data.coder_parameter.repo_url.value} /home/coder/cardiosense
    cd /home/coder/cardiosense
    pip install -r requirements.txt
    echo "CardioSense environment ready!"
    jupyter notebook --no-browser --port=8888 &
  EOT
}

resource "coder_app" "jupyter" {
  agent_id     = coder_agent.main.id
  slug         = "jupyter"
  display_name = "CardioSense Jupyter"
  url          = "http://localhost:8888"
  icon         = "/icon/jupyter.svg"
  share        = "owner"
}