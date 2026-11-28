# locals.tf: values used by many tools.

locals {
  common_tags = merge(var.tags, { Environment = var.environment })

  # Put pods on CORE nodes only. Both core blue and core green have this label,
  # so after a blue -> green switch the pods move to green by themselves.
  core_nodes = { role = "core" }

  # For tools that must run on EVERY node (log and security agents).
  # "Exists" with no key = accept every taint, including the ML nodes.
  every_node = [{ operator = "Exists" }]

  oidc_issuer_host = replace(var.oidc_provider_url, "https://", "")
}
