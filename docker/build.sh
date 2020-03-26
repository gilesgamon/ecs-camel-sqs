#!/bin/bash

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_OpenJDK_11 -t openjdk_11
docker build ~/ecs-camel-sqs -f Dockerfile_camel_sqs_only_broker_build -t camel_sqs_only_broker_build
docker create --name tempCamel camel_sqs_only_broker_build
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks .
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar .
docker rm tempCamel
# Now use a clean container, to build a runtime (without Maven etc)
docker build . -f Dockerfile_camel_sqs_only_broker_runtime -t camel_sqs_only_broker_runtime
cd ../iac/ecr
# terraform init
# terraform apply
`aws ecr get-login --no-include-email --region eu-west-1`
docker tag camel_sqs_only_broker_runtime:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker-sqs-only:latest
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker-sqs-only:latest

cd ../iac/ecs
terraform init
terraform apply