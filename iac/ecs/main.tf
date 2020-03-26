provider "aws" {
  region = var.region
}

locals {
  name        = var.ecs_cluster_name
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

#----- ECS --------
module "ecs" {
  source = "./ecs"
  name   = local.name
}

module "ec2-profile" {
  source = "./ecs-instance-profile"
  name   = local.name
}

#----- ECS  Services--------

module "ecs-service" {
  source     = "./ecs-service"
  name       = local.name
  cluster_id = module.ecs.this_ecs_cluster_id
  image      = "272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker-sqs-only:latest"
  region     = var.region
}

#----- ECS  Resources--------

#For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_subnet_ids" "gifted_vpc" {
  vpc_id = var.vpc_id
}

data "aws_security_groups" "gifted_sgs" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
