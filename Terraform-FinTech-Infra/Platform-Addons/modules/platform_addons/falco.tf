# falco.tf: Falco watches every node for suspicious activity; Falcosidekick forwards the alerts.

############################ Falco + Falcosidekick ############################
# Falco watches every node for suspicious activity (shell in a container, reading /etc/shadow ...).
# Falcosidekick forwards those alerts (Slack, Loki, ...).
resource "helm_release" "falco" {
  name       = "falco"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  version    = var.chart_versions.falco
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    driver      = { kind = "modern_ebpf" } # no kernel module needed
    tolerations = local.every_node         # DaemonSet: one pod on every node

    falcosidekick = {
      enabled      = true
      nodeSelector = local.core_nodes
      # Add outputs here later, e.g. config = { slack = { webhookurl = "..." } }
    }
  })]
}
