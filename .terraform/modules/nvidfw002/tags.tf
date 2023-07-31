data "environment_variables" "current_user" {
  filter = "^GITLAB_USER_EMAIL"
}

locals {
  current_user_email = lookup(data.environment_variables.current_user.items, "GITLAB_USER_EMAIL", "")
  default_tags       = merge({ "managed-by" = "Terraform" }, local.current_user_email != "" ? { "deployed-by" = lower(local.current_user_email) } : {})
  tags               = merge(local.default_tags, var.tags)
}