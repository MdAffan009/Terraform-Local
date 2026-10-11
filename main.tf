resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.app_name
      namespace = var.argocd_namespace
    }

    spec = {
      project = "default"

      sources = [
        # 1. Helm chart source
        {
          repoURL        = "https://github.com/MdAffan009/DevOps-Project.git"
          targetRevision = var.app_revision
          path           = "chart"
          helm = {
            releaseName = var.app_name
            valueFiles  = ["$values/apps/webapp/values.yaml"]
          }
        },

        # 2. Values source
        {
          repoURL        = var.repo_url
          targetRevision = var.app_revision
          ref            = "values"
        },

        # 3. Manifests source (Sealed Secret)
        {
          repoURL        = var.repo_url
          targetRevision = var.app_revision
          path           = "apps/webapp/manifests"
        }
      ]

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.target_namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}