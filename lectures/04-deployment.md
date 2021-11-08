<!--
ignore these words in spell check for this file
// cSpell:ignore dockerized 
-->

[Menu](../README.md)

## Deploying Docker Containers
(includes section 9)

This module will be about deploying containers, moving from development to production. we will run containers on remote machines, like the cloud.\
the focus will be on web app development, even though docker can be used for any kind of application.

we will learn to move from local development to remote deployment, both single and multi containers, use one or many machines to host the containers, we will also learn about managed and un-managed services. the examples in the course are for amazon's AWS.

#### From Development To Production
#### Deployment Process & Providers
#### Getting Started With An Example
#### Bind Mounts In Production
#### Introducing AWS & EC2
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