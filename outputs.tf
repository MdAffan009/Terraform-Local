output "argocd_app_name" {
  description = "Name of the ArgoCD application created"
  value       = kubectl_manifest.argocd_application.name
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD application is deployed"
  value       = var.argocd_namespace
}

output "target_namespace" {
  description = "Namespace where the app is running"
  value       = var.target_namespace
}

output "repo_url" {
  description = "Git repo ArgoCD is watching"
  value       = var.repo_url
}