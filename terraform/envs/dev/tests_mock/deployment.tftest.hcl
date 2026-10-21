# Run from terraform/envs/dev with Terraform >= 1.7:
# terraform test -test-directory=tests_mock
# Every AWS resource/data source is mocked. No AWS credentials or API calls.
# Mock apply is intentional: computed prefix-list IDs are known after apply.
mock_provider "aws" {
  # Keep computed ARNs valid when the next plan validates downstream inputs.
  # Random mock strings would otherwise fail the real provider's ARN checks.
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/mock-ecs-role" }
  }

  mock_resource "aws_lb" {
    defaults = { arn = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:loadbalancer/app/mock-alb/0123456789abcdef" }
  }

  mock_resource "aws_lb_target_group" {
    defaults = { arn = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:targetgroup/mock-target/0123456789abcdef" }
  }

  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }

  mock_resource "aws_db_instance" {
    defaults = {
      master_user_secret = [{
        secret_arn    = "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:mock-master"
        kms_key_id    = "mock-key"
        secret_status = "active"
      }]
    }
  }
}

run "bootstrap_wiring" {
  command = apply

  variables {
    amplify_github_access_token = "not-a-real-token-test-only"
    api_desired_count           = 0
  }

  assert {
    condition     = aws_amplify_app.frontend.access_token == var.amplify_github_access_token
    error_message = "A new Amplify app must receive the supplied GitHub token."
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.ecs_to_s3_https.security_group_id == aws_security_group.ecs.id
    error_message = "S3 egress must be attached to the ECS task security group."
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.ecs_to_s3_https.prefix_list_id == aws_vpc_endpoint.s3.prefix_list_id
    error_message = "S3 egress must reference the gateway endpoint's regional prefix list."
  }

  assert {
    condition = (
      aws_vpc_security_group_egress_rule.ecs_to_s3_https.ip_protocol == "tcp" &&
      aws_vpc_security_group_egress_rule.ecs_to_s3_https.from_port == 443 &&
      aws_vpc_security_group_egress_rule.ecs_to_s3_https.to_port == 443 &&
      aws_vpc_security_group_egress_rule.ecs_to_s3_https.cidr_ipv4 == null &&
      aws_vpc_security_group_egress_rule.ecs_to_s3_https.cidr_ipv6 == null
    )
    error_message = "S3 egress must allow only HTTPS to the prefix list, not a broad CIDR."
  }

  assert {
    condition = (
      aws_vpc_endpoint.s3.vpc_endpoint_type == "Gateway" &&
      contains(aws_vpc_endpoint.s3.route_table_ids, aws_route_table.private.id)
    )
    error_message = "The S3 gateway must remain associated with the private route table."
  }

  assert {
    condition = (
      aws_ecs_service.api.desired_count == 0 &&
      contains(aws_ecs_service.api.network_configuration[0].security_groups, aws_security_group.ecs.id) &&
      aws_ecs_service.api.network_configuration[0].assign_public_ip == false
    )
    error_message = "Bootstrap must support zero API tasks using the private ECS security group."
  }
}

run "omit_setup_token_after_connection" {
  command = plan

  variables {
    amplify_github_access_token = null
    api_desired_count           = 0
  }

  # Reuses the preceding mock state, so this checks an existing app, not a
  # token-free new deployment. ignore_changes keeps setup-only auth stable.
  assert {
    condition     = aws_amplify_app.frontend.access_token == "not-a-real-token-test-only"
    error_message = "Removing the setup token must not send an empty token to an existing app."
  }
}

run "reject_empty_setup_token" {
  command = plan

  variables {
    amplify_github_access_token = "   "
  }

  expect_failures = [var.amplify_github_access_token]
}
