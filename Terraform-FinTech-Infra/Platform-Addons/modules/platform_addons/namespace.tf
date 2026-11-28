# namespace.tf: ONE namespace for every platform tool, so they are easy to find and manage:
#   kubectl get pods -n platform-tools

resource "kubernetes_namespace_v1" "platform_tools" {
  metadata {
    name   = var.namespace
    labels = { purpose = "platform-tools" }
  }
}
