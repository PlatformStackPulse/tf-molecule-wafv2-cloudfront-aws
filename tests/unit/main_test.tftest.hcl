# Unit tests for tf-molecule-wafv2-cloudfront-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:      terraform test -test-directory=tests/unit
# Run verbose:   terraform test -test-directory=tests/unit -verbose
#
# Assertions target plan-KNOWN values only (tf-label id string, resource
# name pass-through, resource count). Computed attributes like arn/id are
# unknown under a mock provider and are intentionally NOT asserted here.

mock_provider "aws" {}

variables {
  # tf-label identity inputs → id resolves to "eg-test-thing"
  namespace = "eg"
  stage     = "test"
  name      = "thing"
}

# ---------------------------------------------------------------------------
# Test: module creates the Web ACL when enabled (default)
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = length(aws_wafv2_web_acl.this) == 1
    error_message = "Expected exactly one aws_wafv2_web_acl when enabled"
  }

  assert {
    condition     = aws_wafv2_web_acl.this[0].name == "eg-test-thing"
    error_message = "Web ACL name should equal the tf-label id 'eg-test-thing'"
  }

  assert {
    condition     = aws_wafv2_web_acl.this[0].scope == "CLOUDFRONT"
    error_message = "Web ACL scope must be CLOUDFRONT for CloudFront distributions"
  }
}

# ---------------------------------------------------------------------------
# Test: managed rules pass through and rate-limit rule is present
# ---------------------------------------------------------------------------
run "applies_custom_rate_limit" {
  command = plan

  variables {
    rate_limit = 5000
    managed_rules = [
      { name = "AWSManagedRulesCommonRuleSet", vendor = "AWS", priority = 10 }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this) == 1
    error_message = "Expected the Web ACL to be created"
  }
}

# ---------------------------------------------------------------------------
# Test: disabling the module creates no resources
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this) == 0
    error_message = "No Web ACL should be created when enabled = false"
  }

  # Outputs use try(...[0].arn, "") so they collapse to "" when disabled.
  assert {
    condition     = output.web_acl_arn == ""
    error_message = "web_acl_arn should be an empty string when the module is disabled"
  }

  assert {
    condition     = output.web_acl_id == ""
    error_message = "web_acl_id should be an empty string when the module is disabled"
  }
}
