
variable "managed_rules" {
  description = "List of AWS managed rule groups to attach"
  type = list(object({
    name     = string
    vendor   = string
    priority = number
  }))
  default = [
    { name = "AWSManagedRulesCommonRuleSet", vendor = "AWS", priority = 10 },
    { name = "AWSManagedRulesKnownBadInputsRuleSet", vendor = "AWS", priority = 20 },
    { name = "AWSManagedRulesSQLiRuleSet", vendor = "AWS", priority = 30 }
  ]
}

variable "rate_limit" {
  description = "Rate limit (requests per 5-minute period)"
  type        = number
  default     = 2000
}
