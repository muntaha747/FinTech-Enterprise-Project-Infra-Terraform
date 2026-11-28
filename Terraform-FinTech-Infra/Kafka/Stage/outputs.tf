# outputs.tf: values printed after apply.

output "kafka_bootstrap_url" {
  description = "Kafka address apps connect to (IAM login, port 9098). Put it in the app's ConfigMap."
  value       = module.kafka.kafka_bootstrap_url
}

output "kafka_cluster_arn" {
  description = "ARN of the Kafka cluster (used in IAM policies for the apps)"
  value       = module.kafka.kafka_cluster_arn
}
