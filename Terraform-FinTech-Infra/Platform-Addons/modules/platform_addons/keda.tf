# keda.tf: KEDA scales pods on events (Kafka lag, SQS queue length, Prometheus queries, cron ...).
# The normal HPA can only scale on CPU and memory; KEDA adds these event-based triggers.
# Use it by creating a ScaledObject next to a Deployment.

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = var.chart_versions.keda
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    nodeSelector = local.core_nodes # KEDA operator, metrics server and webhook on core nodes
  })]
}
