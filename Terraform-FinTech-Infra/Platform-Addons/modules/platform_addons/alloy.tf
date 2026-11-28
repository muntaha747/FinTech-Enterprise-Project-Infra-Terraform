# alloy.tf: Grafana Alloy receives OpenTelemetry (OTLP) data from apps and sends metrics to Prometheus.

############################ Grafana Alloy: OpenTelemetry from apps -> Prometheus ############################
# Apps send OTLP to alloy.monitoring:4317 (gRPC) or :4318 (HTTP)
resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = var.chart_versions.alloy
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    controller = {
      type         = "deployment"
      replicas     = 1
      nodeSelector = local.core_nodes
    }

    alloy = {
      extraPorts = [
        { name = "otlp-grpc", port = 4317, targetPort = 4317, protocol = "TCP" },
        { name = "otlp-http", port = 4318, targetPort = 4318, protocol = "TCP" },
      ]

      configMap = {
        content = <<-EOT
          otelcol.receiver.otlp "apps" {
            grpc { endpoint = "0.0.0.0:4317" }
            http { endpoint = "0.0.0.0:4318" }
            output { metrics = [otelcol.exporter.prometheus.to_prometheus.input] }
          }

          otelcol.exporter.prometheus "to_prometheus" {
            forward_to = [prometheus.remote_write.local.receiver]
          }

          prometheus.remote_write "local" {
            endpoint {
              url = "http://kube-prometheus-stack-prometheus.${var.namespace}.svc.cluster.local:9090/api/v1/write"
            }
          }
        EOT
      }
    }
  })]

  depends_on = [helm_release.kube_prometheus_stack]
}
