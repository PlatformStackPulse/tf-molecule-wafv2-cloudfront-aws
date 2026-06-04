output "web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL (use in CloudFront distribution web_acl_id)"
  value       = try(aws_wafv2_web_acl.this[0].arn, "")
}

output "web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = try(aws_wafv2_web_acl.this[0].id, "")
}
