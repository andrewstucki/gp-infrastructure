terraform {
  required_version = "= 0.11.13"

  backend "s3" {
    region  = "us-west-1"
    key     = "base.tfstate"
    encrypt = "true"
    acl     = "private"
  }
}

provider "aws" {
  region  = "us-west-1"
  version = "~> 2.8"
}

variable "domain" {
  description = "Domain to create a Route53 zone for"
}

resource "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

output "ns" {
  value = ["${aws_route53_zone.zone.name_servers}"]
}

output "domain" {
  value = "${var.domain}"
}

output "zone" {
  value = "${aws_route53_zone.zone.zone_id}"
}
