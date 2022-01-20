We have a few things defined in the old BJN_AWS_INTERNAL account. We use that AWS account as a docker registry, and we also have the Project Prioritization project that Doug requested I make in there.

# Docker Registry
We use the ECR (Elastic Container Registry) in aws to store prebuild docker images. ECR is a pretty simple service. To describe it briefly, it provides some cloud storage space that can be pushed/pulled to through the docker CLI. Once you have built a docker image locally, you can run `docker push <registry_name/imagename>` to push it to EBS. Then, anybody with the appropriate credentials can `docker pull` what you pushed and get that image on their system. See this guide for more details. https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

Currently, the only image we have in the ECR is a docker image that has the yocto cross-compiler toolchain inside it. It can be useful for developers if they don't have the yocto sdk installed, but it's mainly used by a Azure Pipeline I set up to automatically build/publish to npm when new code is committed to the `main` branch in the `hlio-rcd-applications-sdk` repository.

# Project Prioritization Project

This is a simple little web app that Doug requested I make to help keep track of projects that HCEE should be working on. The code is held in the following repository, and it is hosted/deployed to AWS in an EC2 t2.micro instance.

# Project Prioritization Project

In June 2021, Doug asked me to make a little app that could be used to tabulate/rank projects that HCEE might want to use. The idea being that any HCEE employee or HLIO subsidiaries could submit ideas through the portal, then Doug/whoever could see all the ideas submitted, rank them based on 5 metrics to try and quantify how much value they add to HCEE, then decide what projects to start working on. To accomplish this, I wrote a little Django web application. The link below points to its repository. The app is hosted in a t2.micro AWS EC2 instance.

Repository Link: https://enovationexternal.visualstudio.com/HCEE/_git/ProjectPrioritization

EC2 Instance Link: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#InstanceDetails:instanceId=i-0464d4fd9fa4df926

App Public Url: ec2-54-204-224-55.compute-1.amazonaws.com/admin

### Deploy Process

Deploying the project is pretty simple. Just ssh into the ec2 instance, `git clone` the repository, then run the `build-deploy.sh` script in the root directory of the repository. Under the hood, this will start up two docker containers on the ec2 instance. One that is a Postgres database for storing data, and another that is the django application, running behind an Apache server to accept http requests. The apache server in that docker image is then port-forwarded to the worldwide web, letting hcee employees connect to it.