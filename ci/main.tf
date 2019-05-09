terraform {
  required_version = "= 0.11.13"

  backend "s3" {
    region  = "us-west-1"
    key     = "ci.tfstate"
    encrypt = "true"
    acl     = "private"
  }
}

provider "aws" {
  region  = "us-west-1"
  version = "~> 2.8"
}

provider "circleci" {
  version = "~> 0.0"
}

provider "github" {
  version = "~> 2.0"
}

variable "developers" {
  description = "The github developers group that has access to repos"
}

variable "repos" {
  type        = "list"
  description = "List of repos to manage, make sure you only append to this list"
  default     = []
}

data "github_team" "developers" {
  slug = "${var.developers}"
}

resource "github_repository" "repo" {
  count = "${length(var.repos)}"

  name        = "${lookup(var.repos[count.index], "name")}"
  description = "${lookup(var.repos[count.index], "description")}"

  allow_merge_commit = true
  auto_init          = true
  allow_squash_merge = false
  allow_rebase_merge = false
  has_issues         = true
  has_wiki           = true
  has_projects       = true

  # private = true
}

resource "github_repository_project" "project" {
  count = "${length(var.repos)}"

  name       = "Development - ${element(github_repository.repo.*.name, count.index)}"
  repository = "${element(github_repository.repo.*.name, count.index)}"
  body       = "Main development board for ${element(github_repository.repo.*.name, count.index)}."
}

resource "github_project_column" "backlog" {
  count = "${length(var.repos)}"

  project_id = "${element(github_repository_project.project.*.id, count.index)}"
  name       = "Backlog"
}

resource "github_project_column" "development" {
  count = "${length(var.repos)}"

  project_id = "${element(github_repository_project.project.*.id, count.index)}"
  name       = "Ready for Development"

  depends_on = ["github_project_column.backlog"]
}

resource "github_project_column" "review" {
  count = "${length(var.repos)}"

  project_id = "${element(github_repository_project.project.*.id, count.index)}"
  name       = "In Review"

  depends_on = ["github_project_column.development"]
}

resource "github_project_column" "done" {
  count = "${length(var.repos)}"

  project_id = "${element(github_repository_project.project.*.id, count.index)}"
  name       = "Done"

  depends_on = ["github_project_column.review"]
}

resource "github_team_repository" "repo" {
  count = "${length(var.repos)}"

  team_id    = "${data.github_team.developers.id}"
  repository = "${element(github_repository.repo.*.name, count.index)}"
  permission = "push"
}

resource "github_branch_protection" "repo" {
  count = "${length(var.repos)}"

  repository     = "${element(github_repository.repo.*.name, count.index)}"
  branch         = "master"
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = ["ci/circleci"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    dismissal_teams       = ["${data.github_team.developers.slug}"]
  }
}

resource "circleci_project" "repo" {
  count = "${length(var.repos)}"

  repo = "${element(github_repository.repo.*.name, count.index)}"
}

resource "circleci_environment_variable" "aws_access_key" {
  count = "${length(var.repos)}"

  project = "${element(circleci_project.repo.*.id, count.index)}"
  name    = "AWS_ACCESS_KEY_ID"
  value   = "${aws_iam_access_key.terraform.id}"
}

resource "circleci_environment_variable" "aws_secret_key" {
  count = "${length(var.repos)}"

  project = "${element(circleci_project.repo.*.id, count.index)}"
  name    = "AWS_SECRET_ACCESS_KEY"
  value   = "${aws_iam_access_key.terraform.secret}"
}

resource "circleci_environment_variable" "aws_region" {
  count = "${length(var.repos)}"

  project = "${element(circleci_project.repo.*.id, count.index)}"
  name    = "AWS_DEFAULT_REGION"
  value   = "us-west-1"
}
