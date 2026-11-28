# flow_logs.tf: saves a log of all network traffic in the VPC (needed for audits).

# 1. Log group: where the logs are kept
resource "aws_cloudwatch_log_group" "flow_logs" {
  # checkov:skip=CKV_AWS_158: Default CloudWatch encryption for now
  name              = "/vpc/${var.vpc_name}/flow-logs"
  retention_in_days = var.flow_log_retention_days
  tags              = merge(local.common_tags, { Name = "${var.vpc_name}-flow-logs" })
}

# 2. Role: lets the Flow Logs service write logs
resource "aws_iam_role" "flow_logs" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-flow-logs-role" })
}

# 3. Permission: write only to the log group above
resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.vpc_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
      Resource = "${aws_cloudwatch_log_group.flow_logs.arn}:*"
    }]
  })
}

# 4. Turn on flow logs for the VPC
resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = var.flow_log_traffic_type
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn    = aws_iam_role.flow_logs.arn
  tags            = merge(local.common_tags, { Name = "${var.vpc_name}-flow-log" })
}
