We have a few things defined in the old BJN_AWS_INTERNAL account. We use that AWS account as a docker registry, and we also have the Project Prioritization project that Doug requested I make in there.

# Docker Registry
We use the ECR (Elastic Container Registry) in aws to store prebuild docker images. ECR is a pretty simple service. To describe it briefly, it provides some cloud storage space that can be pushed/pulled to through the docker CLI. Once you have built a docker image locally, you can run `docker push <registry_name/imagename>` to push it to EBS. Then, anybody with the appropriate credentials can `docker pull` what you pushed and get that image on their system. See this guide for more details. https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

Currently, the only image we have in the ECR is a docker image that has the yocto cross-compiler toolchain inside it. It can be useful for developers if they don't have the yocto sdk installed, but it's mainly used by a Azure Pipeline I set up to automatically build/publish to npm when new code is committed to the `main` branch in the `hlio-rcd-applications-sdk` repository.

# Project Prioritization Project

This is a simple little web app that Doug requested I make to help keep track of projects that HCEE should be working on. The code is held in the following repository, and it is hosted/deployed to AWS in an EC2 t2.micro instance.


NOTE: Currently, the SSH key that is used to clone to the ec2 instance is under my (Jordan Koeller)'s account. This will need to change in the future, when my ssh key expires.

Repository Link: https://enovationexternal.visualstudio.com/HCEE/_git/ProjectPrioritization

EC2 Instance Link: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#InstanceDetails:instanceId=i-0464d4fd9fa4df926

App Public Url: ec2-54-204-224-55.compute-1.amazonaws.com/admin

# AWS Best practices

## 1. Don't give out root credentials ever.
If somebody needs to have credentials to aws, you should make them a new User in IAM. This will spit out credentials for that individual. Of course, you can set specific permissions for that user as well. Note that this is also appropriate for any CI/CD pipelines that need AWS access. You should make a new User with a name like "CI/CD", then configure your pipeline with that "user"'s access token.

## 2. PLEASE stick to "infrastructure as code"
AWS has come a long way in terms of documenting/automating provisioning resources. The tool you want to use is AWS CloudFormation, or AWS SAM. AWS SAM is a subset of CloudFormation specifically designed for serverless apps. These tools let you specify a yaml file that is checked into a repository that is a registry of all the infrastructure/aws config you want to spin up. This way your infrastructure can be version controlled, it's all in one place, and it's really clear what is going on. I used this pattern for the smart-pool project from the BJN days if you want an example. Or check out a personal project of mine, like this one here: https://github.com/JordanKoeller/TrinityMutualAid/blob/main/lambdas/template.yml

