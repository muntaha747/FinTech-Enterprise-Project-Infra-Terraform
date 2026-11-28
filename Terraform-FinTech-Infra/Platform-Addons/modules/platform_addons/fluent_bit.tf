# fluent_bit.tf: Fluent Bit reads pod logs on every node and sends them to Loki.

############################ Fluent Bit: logs from every node to Loki ############################
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = var.chart_versions.fluent_bit
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    tolerations = local.every_node # DaemonSet: one pod on every node

    config = {
      outputs = <<-EOT
        [OUTPUT]
            Name                   loki
            Match                  kube.*
            Host                   loki-gateway.${var.namespace}.svc.cluster.local
            Port                   80
            Labels                 job=fluent-bit
            Auto_kubernetes_labels on
      EOT
    }
  })]

  depends_on = [helm_release.loki]
}
