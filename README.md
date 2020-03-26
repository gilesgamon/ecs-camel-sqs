# ecs-camel-sqs
A repo to deploy camel into ECS: then get messages from one queue and put them on another - setup/test repo

This is a standalone example of complete build of SQS to SQS camel broker/router using ECS. Things like AWS BasicSessionCredentials derived from ECS task context are used. This joins the Infrastructure as Code (IaC) to the camel build and provisioning. Quite a few 'moving parts' all joined together to isolate trouble shooting before joining back into other parts (like IBM MQ), which have their own complexities.

NOTE: the VPC (iac/ecs/variables.tf vpc_id) is for my account, you'll need to set your own. Same is true of AccountID in a number of places (filth that needs tidying up)

Usage:

WIP but - in principle load some vars (see below / source ./secrets) & aws session/credentials loaded and run './parse_params' and assuming you got that working correctly 'cd docker ; ./build.sh', should deliver back an executable (fat) jar and a server-chain.jks. Terraform to follow.

In principle - this will build a series of containers, culminating in a runtime camel containerm, that will be pushed to AWS ECR (repo created from the build.sh) and then terraform apply - building ECS instance and a task to run camel

A request queue will be monitored and anythin put on it moved directly (by camel) to teh response queue.

Test Operation:
You can use the SQS console to select a queue (new_request) and submit a test message: for example {"type":"login", "payload":{"name":"giles", "city":"Altrincham"}}
This message should be picked up by the camel to SQS new_reply.

TO DO:
Error checking in scripts
Wrapper script (to run the various scripts, check for errors etc)
Clean up of ECR

VARS required:

// Just the raw PEM text : had to write a small (messy) handler to tidy this up
export CLIENT_KEY=''
export CLIENT_CRT=''
export ROOT_PEM=''
export INTERMEDIATE_PEM=''

export CAMEL_VALUES='{"SQS_REQUEST_QUEUE_NAME": "sqs_request_1", "SQS_RESPONSE_QUEUE_NAME": "sqs_response_1", "SQS_REGION": "eu-west-1"}'

The secrets file references files I store in docker/safe which are excluded from git ('cos I don't want to share those) but they're just standard PEM files with I hope pretty self-exlainatory names!