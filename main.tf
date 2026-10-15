# resource "helm_release" "sealed_secrets" {
#   name       = "sealed-secrets-controller"
#   repository = "https://bitnami-labs.github.io/sealed-secrets"
#   chart      = "sealed-secrets"
#   namespace  = "kube-system"
#   version    = "2.17.3"
# }

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.16.0"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.7.8"
  create_namespace = true
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
  name      = "jenkins-blueocean"
  image     = "robinparker995/jenkins-blueocean:latest"
  restart   = "on-failure"
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

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "91.7.1"
  create_namespace = true
  timeout          = 900
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = "monitoring"
  version          = "2.10.3"
  create_namespace = true

  set {
    name  = "loki.isDefault"
    value = "false"
  }
}

resource "kubectl_manifest" "argocd_application" {
  depends_on = [helm_release.argocd, kubernetes_secret.argocd_repo_creds]

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.app_name
      namespace = var.argocd_namespace
    }
    spec = {
      project = "default"
      sources = [
        {
          repoURL        = "https://github.com/MdAffan009/DevOps-Project.git"
          targetRevision = var.app_revision
          path           = "chart"
          helm = {
            releaseName = var.app_name
            valueFiles  = ["$values/apps/webapp/values.yaml"]
          }
        },
        {
          repoURL        = var.repo_url
          targetRevision = var.app_revision
          ref            = "values"
        },
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
  })
}

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "robinparker995@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  })
}

resource "kubernetes_secret" "argocd_repo_creds" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "devops-config-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/MdAffan009/devops-config.git"
    username = "MdAffan009"
    password = var.github_pat
  }
}
