module "ecr-repository" {
  source = "./ecr-repo"

  repository_name = "camel-broker-sqs-only"
  attach_lifecycle_policy = true
}
