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

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}

resource "docker_container" "jenkins" {
  name    = "jenkins-blueocean"
  image   = "robinparker995/jenkins-blueocean:latest"
  restart = "on-failure"
  group_add = [var.docker_gid]

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }

  volumes {
    volume_name    = "jenkins-data"
    container_path = "/var/jenkins_home"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}