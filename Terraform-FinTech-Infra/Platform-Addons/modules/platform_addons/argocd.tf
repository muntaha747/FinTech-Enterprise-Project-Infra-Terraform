# argocd.tf: Argo CD deploys apps from Git (GitOps).

resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_versions.argo_cd
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    global = { nodeSelector = local.core_nodes } # every Argo CD pod on core nodes
  })]
}
