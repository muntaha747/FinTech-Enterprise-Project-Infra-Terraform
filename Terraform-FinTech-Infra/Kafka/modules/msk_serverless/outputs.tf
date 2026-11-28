# outputs.tf: values this module hands back to the root.

output "kafka_bootstrap_url" {
  description = "Kafka address apps connect to (IAM login, port 9098)"
  value       = aws_msk_serverless_cluster.kafka.bootstrap_brokers_sasl_iam
}

output "kafka_cluster_arn" {
  description = "ARN of the Kafka cluster (used in IAM policies)"
  value       = aws_msk_serverless_cluster.kafka.arn
}

output "kafka_security_group_id" {
  description = "Security group of the Kafka cluster"
  value       = aws_security_group.kafka.id
}
