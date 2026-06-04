# Molecule: WAFv2 Web ACL (CLOUDFRONT scope) for CloudFront distributions

module "web_acl" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-wafv2-web-acl-aws.git?ref=918046583c7de2e902385e21abd6cffabb070b07"

  context       = module.this.context
  name          = var.name
  scope         = "CLOUDFRONT"
  managed_rules = var.managed_rules
  rate_limit    = var.rate_limit
}
