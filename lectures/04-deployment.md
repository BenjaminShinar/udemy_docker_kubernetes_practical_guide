<!--
ignore these words in spell check for this file
// cSpell:ignore dockerized simplenodeapp
-->

[Menu](../README.md)

## Deploying Docker Containers
(includes section 9)

This module will be about deploying containers, moving from development to production. we will run containers on remote machines, like the cloud.\
the focus will be on web app development, even though docker can be used for any kind of application.

we will learn to move from local development to remote deployment, both single and multi containers, use one or many machines to host the containers, we will also learn about managed and un-managed services. the examples in the course are for amazon's AWS.

#### From Development To Production

so far, we only focused on development, but containers, as their namesakes, are ideal for deployment. they protect us from having different development and production environments. the environment is inside the container. we have an isolated, standalone environment that is the same in the development stage and the deployment stage. they are reproducible, easy to share and use.\
this protects us from surprises, if we run it in a container locally, it should work the same in a container that's running in a remote machine.

- Bind Mounts shouldn't be used in production.
- Containerized apps might need a build step that happens in the deployment stage (such as React apps).
- Multi-container project might need to be split across multiple hosts/remote machine in the deployment.
- There are tradeoffs, we might have less control and less responsibility when deploying containers remotely.

#### Deployment Process & Providers

The basic first example is a standalone nodeJS application. no database, no frontend. just one container that runs one image. 
our process is simply:
> Install Docker on a remote host (e.g. via SSH), push and pull image, run container based on image on remote host.

for this, we need a remote machine, some service that can host our container and run it. the major hosting providers are
- Amazon Web Services (AWS)
- Microsoft Azure
- Google Cloud

those three can give us much more than web hosting. and they have good defaults to use. in this course we will use AWS, this requires a credit card to pay for hosting.

we will use an amazon EC2 service.

#### Getting Started With An Example

deploying a basic node application to AWS EC2.
> AWS EC2 is a service that allows you to spin up and manage your own remote machines.

we will get this example working in three steps:
> 1. Create and launch EC2 instance, VPC and security group.\
>   (VPC - virtual public cloud)
> 2. Configure security groupe to expose all required ports to WWW
> 3. Connect to instance (SSH), install docker and run container.

lets get the simple application in the folder "deployment-01-starting-setup". it's a really basic application that simply serves a static page. we can create a docker-compose file, but we won't do this right now.


```sh
cd deployment-01-starting-setup\
docker image build -t simplenodeapp .
docker container run --rm -d -p 3000:80 --name simple simplenodeapp
docker container stop simple
```

we check the browser.

#### Bind Mounts In Production

in this application, we aren't using bind mounts. 

In development, we encapsulate the runtime environment, but we are fine if the source code comes from the local machine. and it's even better if it can respond to changes in it. this makes development faster, without restarting the container or building the image again.\
For production, we want the container to have everything inside it, and not to depend on anything from inside. the image is the single source of truth. we don't look outside to get the code. this is why we use `COPY` when we build the image, and we don't use bind mounts.

we could have both the copy and the bind mount, the volumes are declared outside the dockerfile, this way we can use the same file for both development and production. had we used a docker-compose file, we might have had those bind commands inside it, but we will look at this issue later.

#### Introducing AWS & EC2

now we want to take this image and deploy it somewhere. we want the remote machine to run the image. we need an account and a credit card to sign up.

we should see something called *AWS Management Console*, where we search for EC2, we look for an option to launch a new instance.

#### Connecting to an EC2 Instance
#### Installing Docker on a Virtual Machine
#### Installing Docker on Linux in General
#### Pushing our local Image to the Cloud
#### Running & Publishing the App (on EC2)
#### Managing & Updating the Container / Image
#### Disadvantages of our Current Approach
#### From Manual Deployment to Managed Services
#### Important: AWS, Pricing and ECS
#### Deploying with AWS ECS: A Managed Docker Container Service
#### More on AWS
#### Updating Managed Containers
#### Preparing a Multi-Container App
#### Configuring the NodeJS Backend Container
#### Deploying a Second Container & A Load Balancer
#### Using a Load Balancer for a Stable Domain
#### Using EFS Volumes with ECS
#### Our Current Architecture
#### Databases & Containers: An Important Consideration
#### Moving to MongoDB Atlas
#### Using MongoDB Atlas in Production
#### Our Updated & Target Architecture
#### Understanding a Common Problem
#### Creating a "build-only" Container
#### Introducing Multi-Stage Builds
#### Building a Multi-Stage Image
#### Deploying a Standalone Frontend App
#### Development vs Production: Differences
#### Understanding Multi-Stage Build Targets
#### Beyond AWS
#### Module Summary
#### Module Resources