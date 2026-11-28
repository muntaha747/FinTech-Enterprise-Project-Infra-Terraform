# argo_rollouts.tf: Argo Rollouts does canary and blue-green releases.

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = var.chart_versions.argo_rollouts
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    controller = { nodeSelector = local.core_nodes }
    dashboard  = { enabled = true, nodeSelector = local.core_nodes }
  })]
}
