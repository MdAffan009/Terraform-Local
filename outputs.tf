output "argocd_app_name" {
  description = "Name of the ArgoCD application created"
  value       = kubernetes_manifest.argocd_application.manifest.metadata.name
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD application is deployed"
  value       = kubernetes_manifest.argocd_application.manifest.metadata.namespace
}

output "target_namespace" {
  description = "Namespace where the app is running"
  value       = kubernetes_manifest.argocd_application.manifest.spec.destination.namespace
}

output "repo_url" {
  description = "Git repo ArgoCD is watching"
  value       = var.repo_url
}
