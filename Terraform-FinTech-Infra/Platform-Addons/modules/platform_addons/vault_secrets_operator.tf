# vault_secrets_operator.tf: copies secrets from the Vault server (Ops VPC) into Kubernetes Secrets.

############################ Vault Secrets Operator ############################
# Runs in the cluster, reads secrets from the Vault server in the Ops VPC,
# and writes them into normal Kubernetes Secrets.
resource "helm_release" "vault_secrets_operator" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.chart_versions.vault_secrets_operator
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    defaultVaultConnection = {
      enabled = true
      address = var.vault_address
    }
    controller = { nodeSelector = local.core_nodes }
  })]
}
