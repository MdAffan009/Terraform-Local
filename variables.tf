variable "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  type        = string
  default     = "argocd"
}

variable "app_name" {
  description = "Name of the ArgoCD application"
  type        = string
  default     = "webapp"
}

variable "repo_url" {
  description = "Git repository URL for the Helm config"
  type        = string
  default     = "https://github.com/MdAffan009/devops-config.git"
}

variable "target_namespace" {
  description = "Namespace where the app will be deployed"
  type        = string
  default     = "default"
}

variable "app_revision" {
  description = "Git branch ArgoCD will track"
  type        = string
  default     = "main"
}

variable "docker_gid" {
  description = "GID of the docker group on the host machine"
  type        = string
  default     = "127"
}

variable "github_pat" {
  description = "GitHub Personal Access Token for devops-config access"
  type        = string
  sensitive   = true
}
