# Molecule: WAFv2 Web ACL (CLOUDFRONT scope) for CloudFront distributions

resource "aws_wafv2_web_acl" "this" {
  count = module.this.enabled ? 1 : 0

  name        = module.this.id
  description = "WAF for CloudFront distributions"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${module.this.id}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 99
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${module.this.id}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = module.this.id
    sampled_requests_enabled   = true
  }

  tags = module.this.tags
}
