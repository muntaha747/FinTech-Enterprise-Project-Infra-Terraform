# prometheus_grafana.tf: Prometheus + Grafana (kube-prometheus-stack).
# One chart installs: Prometheus, Grafana, Alertmanager, node-exporter, kube-state-metrics.

# Grafana admin password: generated, never written in code
resource "random_password" "grafana_admin" {
  length  = 20
  special = false
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_versions.kube_prometheus_stack
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name
  timeout    = 900

  values = [yamlencode({
    prometheus = {
      prometheusSpec = {
        nodeSelector              = local.core_nodes
        retention                 = var.prometheus_retention
        enableRemoteWriteReceiver = true # lets Grafana Alloy push metrics in

        # Pick up ServiceMonitors from every namespace (payment, ledger, ...)
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false

        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = "gp3"
              accessModes      = ["ReadWriteOnce"]
              resources        = { requests = { storage = var.prometheus_disk_size } }
            }
          }
        }
      }
    }

    grafana = {
      nodeSelector = local.core_nodes

      # Loki shows up in Grafana as a log source
      additionalDataSources = [{
        name   = "Loki"
        type   = "loki"
        access = "proxy"
        url    = "http://loki-gateway.${var.namespace}.svc.cluster.local"
      }]
    }

    alertmanager             = { alertmanagerSpec = { nodeSelector = local.core_nodes } }
    prometheusOperator       = { nodeSelector = local.core_nodes }
    kube-state-metrics       = { nodeSelector = local.core_nodes }
    prometheus-node-exporter = { tolerations = local.every_node } # runs on every node
  })]

  set_sensitive = [{
    name  = "grafana.adminPassword"
    value = random_password.grafana_admin.result
  }]

  depends_on = [kubernetes_storage_class_v1.gp3]
}
