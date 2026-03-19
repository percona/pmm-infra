output "rds_user_name" {
  description = "Name of the RDS user"
  value       = aws_iam_user.rds_user.name
}

output "rds_policy_arn" {
  description = "ARN of the RDS policy"
  value       = aws_iam_policy.pmmdemo-rds-policy.arn
}

output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.pmm-demo.key_name
}
