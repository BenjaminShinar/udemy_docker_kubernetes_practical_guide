<!--
ignore these words in spell check for this file
// cSpell:ignore dockerized simplenodeapp FARGATE
-->

[Menu](../README.md)

## Deploying Docker Containers
(includes section 9,10)

This module will be about deploying containers, moving from development to production. we will run containers on remote machines, like the cloud.\
the focus will be on web app development, even though docker can be used for any kind of application.

we will learn to move from local development to remote deployment, both single and multi containers, use one or many machines to host the containers, we will also learn about managed and un-managed services.

### Un-managed Manual Approach

<details>
<summary>
Manually deploying a simple application to the cloud.
</summary>

A basic, simple, hands-on process of getting an application to run on a remote machine. we do everything manually, from setting the machine, opening the ports, getting the image and running it.

the examples in the course are for amazon's AWS.\
**(Note: i used the docker labs playground instead of AWS)**

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

we should now see a wizard to select which instance we get. e should take an x86 linux system, and be sure we take the three instance and choose something with simple memory requirement, in the example, it's t2.micro. we then need to make sure there is a VPC network configured.

now we get a screen to get a key-pair, which is something that allows us to connect to the machine with SSH. we can't lose this key, as it's only possible to get it once. we shouldn't share this key. this file is *.pem* extension, a base64-encoded certificate.

we should now launch the instance and see that it's running.\
we will now connect to it with ssh (secure shell). in linux we get this out of the box, in windows we either use **WSL2** or a ssh client such as **putty**.\
we click on the 'connect' button to get the commands to ssh into the machine.


in linux, we might need to use the command to give our permissions, then we run the shell command with the *-i* (identity_file) flag to connect to it.
```sh
chmod 400 key.pem
ssh -i "key.pem" machine@somewhere.region.provider.com
``` 
this will change how our shell prompt looks.


note: we can configure the security groups after we connect to the instance.

#### Installing Docker on a Virtual Machine

when we are inside the remote machine, we need to install docker. we will use the yum package manager for this. we will also use some amazon provided stuff

```sh
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
```

now we got docker installed and running, and we can try typing in some commands to see that it behaves like we expect it to.

if we were using something else other than amazon EC2, we would need to install docker differently, as described in the documentation for [installing docker](https://docs.docker.com/engine/install/).

#### Pushing our local Image to the Cloud

now that we have docker running, we need to bring the image to the remote machine.
we can either bring the source code to the remote machine and build the image there, or build the image locally and then get it from the remote machine.

obviously, docker is all about the later option. we don't want to do all the work on the remote machine, it's just repeated work.

we can do this with docker hub, we publish our image to it, and then pull it from the remote machine. we login to our docker-hub example, create a new repository (public). and now we need to push our image to it. lets have a .dockerignore file inside, we want to ignore node_modules, dockerfile and any .pem files.


```sh
docker image build -t node-dep-example .
docker image tag node-dep-example repo/node-example-1
docker image tag node-dep-example repo/node-example-2
docker image ls -a
#remove tagged and check that it's gone
docker image rm repo/node-example-2
docker image ls -a
#login into docker hub, with username and password
docker login 
docker image push repo/node-example-2
```

#### Running & Publishing the App (on EC2)

now we go back to the remote machine with our ssh connection. we can get the image from the dockerhub repository and run it as we always do.

```sh
docker container run --rm -d --name simple -p 80:80 academind/node-example-1
docker container ls -a
```

in aws we might get a permission issues, for now we simply add the `sudo` to bypass this. it isn't the right thing to do in real world situations.

we go back to the AWS dashboard and look at our instances, we will see public ip. when we enter it in the browser we don't get anything. this isn't a bug, it's a security group issue. we can find it and click on the security to see which traffic is allowed in and out of the instance. all outbound traffic is allowed, which is why we could get the image from docker hub. but only one port is allowed for inbound traffic, this is port 22, which is how the ssh protocol works (together with the key).

we want to allow incoming HTTP access. sw we need to edit the rules and allow http (source: anywhere). and now we can try entering the public ip4 address in our browser and see the static page.

we could also run a docker-compose file on a remote machine, we would need to make adjustments to avoid building images and just take them from the hub.

#### Managing & Updating the Container / Image

there are more advanced ways to deploy applications on the cloud, such as using a custom domain, having multiple containers, etc...

if we updated the code and wanted to push the changes to the remote machine, we would need to rebuild the image, push it again into the repository, and then stop the container, get the image again and run again.\
We need to make sure we are using the updated version. we can either pull the image manually or add a flag to indicate that it should always pull the images again.

```sh
docker image pull academind/node-example-1
# or
docker container run --rm -d --name simple --pull "always" -p 80:80 academind/node-example-1
```

to shut everything down, we can stop the running container, but we can also shut the EC2 instance entirely and choose to terminate it. this will remove it entirely, we can also stop it from running without deleting all the settings.

#### Disadvantages of our Current Approach

we saw how to deploy a simple application on a remote machine, the only thing we needed to install was the docker program. this approach was simple, but it was manual and required us to setup everything.
we are fully responsible for this machine, the configuration and the security of it. we managed the network, the firewall and the security groups, the hardware and the OS. and everything must be done via ssh.

we really want a workflow that can do everything for us. this is what we call a 'Managed' approach. and that will be the next part.

</details>

### Managed Cloud Approach

<details>
<summary>
Using Managed services on Amazon ECS
</summary>

Important: the AWS free tier doesn't include Amazon ECS, so following the course examples will cost us. we also need to be sure we remove all of our resources to avoid paying for them. these resources also include load balancers and NAT gateways.

#### From Manual Deployment to Managed Services

the manual approach gives us total control, but also more responsibility, we have more options, but we also need to take care of more things. we can try and go for a more managed approach, where we don't create the remote machine on our own, but we use a managed machine instead.

Amazon ECS (Elastic Container Service) is a managed machine, other cloud providers also have this option. the cloud provider takes care of creating, managing, updating, monitoring and scaling our application. we now also need to use their tools to orchestrate (manage) the containers, we won't be using `docker container` commands anymore. each service has different commands.

#### Deploying with AWS ECS: A Managed Docker Container Service

we go back to amazon, and get an instance of ECS (this a paid service). we would see a ECS wizard.

There are four layers to ECS:
- Clusters
- Services
- Tasks
- Containers

we already know about containers, so we click to edit our custom container, we give it a name and the image, the ports and any memory limitations. this screen is like the `docker container run` command. we only specify the internal port, the external port is the same. we can add environment arguments or overwrite the starting command and the working directory.

there is also health check, timeouts, network settings, storage and logging (we can use AWS CloudWatch logs).

the next layer is the tasks, a task is blue print for the application, how the machine should be created. we will use **FARGATE** by default, which is a 'serverless' method that is very cost effective, we could also use ECS2, but that will cost more.

the third layer is the service, where we can add a load balancer.

the final layer is the cluster, the overall network of machine in which our services run.

once this starts up, we can start viewing the details of each layer, and eventually we see the public ip.

#### More on AWS

if we want to learn more about AWS, we can look at the martials in the [academind](https://academind.com/tutorials/aws-the-basics) website.

FARGATE is an aws specific thing, it only creates the server when it's needed (a request is made), so it costs less.

we also set up the task memory and CPU, which we can ask AWS to automatically scale up if it encounters high loads of requests.

#### Updating Managed Containers

what if we want to update our image? how will we get this reflected on the ECS service?

as before, we push the new image to the cloud, and we find the tasks tab in the AWS dashboard and click 'create new revision', don't change anything, and click 'create', and then 'Actions->Update Service". once the new task is up, we can go to the new public ip and see the updated version. it will be a different ip address then before. we could use custom domain names to ensure it has the same address.

#### Preparing a Multi-Container App

we will also try a multi container applications. one container with mongoDB and one with our backend service.

we should delete all the resources: services and clusters.

we won't use docker-compose for deployment. it's good for development on one local machine, but less for deployment on remote multiple machines. each cloud vendor has different requirements for how to specify stuff. the compose file is still useful as a reminder to what we want to do.

in AWS ECS we can't use the nice way to find the address of the other containers. in local development, when we use docker-compose, everything goes into the same network. but on the cloud the containers won't necessarily run on the same machine.\
however, if the containers are running in the same task, then they are guaranteed to run on the same machine, in this case, we can use localhost address again. so let's store this as environment variable and build our image again, then push it into dockerhub.

speaking of which, we need to feed in the environment variables.

#### Configuring the NodeJS Backend Container

we click of cluster, "create cluster", "networking only", provide a name check "create VPC" and use the default. the cluster is just the surrounding network, this might take a few minutes. we need to create tasks and services. we create a new "task definition", and assign it to FARGATE.\
it's important that the task role is **ecsTakExecutionRole**.\
we now add the container, choose the image, open port 80.

in the development stage, we used nodemon to have live updates of the code, but it won't matter in production, so we change the "command" field to run node, rather than the npm start to run a script. for the environment variables, we can't use a file, we must enter the key:value pairs. we did this to have 'localhost' as an environment variable.

we don't have storage and volumes because we aren't using bind mounts in production.

#### Deploying a Second Container & A Load Balancer

now we want another container, it will run in the same task (to ensure it runs in the same machine), we map the port 27017 as mongo expects, and we pass the environment variables for user name and password.

this a database, so we eventually will fill in the storage and logging part. but later.

we then create the task, and now we create the service with the task we just created. we need to select the created VPC, use the two subnets and enable "auto assign public ip".

we will also create and "Application Load Balancer", if one isn't found, we follow along the interface to create one on the same vpc. and we select the security group, and choose the routing and registering targets. follow the screens and eventually create the server.

we can use postman to send http requests with a goal to the backend and then see the updated list.

#### Using a Load Balancer for a Stable Domain

every time we deploy an updated image, the public ip is changed. we don't want this.

we can fix it with the load balancer. currently, the load balancer does healthcheck-s to the services, but we didn't set it up correctly, because it tries accessing a url which we didn't define in the application. we also didn't set the correct security group.

if we fix everything, then the DNS name should be the correct address, rather than the changing IP address.

#### Using EFS Volumes with ECS

we update our image, and force re-deployment, the old task keeps running until the new on is running properly, it is then removed after few minute.

now we try to get the goals again, but the old data is lost. we don't have data persistency. once we update a service, we lose the containers and the data stored inside them.

in the local development, we solved this with using volumes, we should do the same in the production deployment.

we go to the task definition, "add volume" and choose EFS (elastic file system). we need to create a file system with amazon, and make it use the vpc we are using. we now click 'customize' and change the network access, we need to change the security group - we create a new one under the vpc, and choose inbound rules with NFS type. we follow the instructions and set the file system as a volume.

we now edit the mongodb configuration a click 'mount point' and set the container path (like what we had in the docker run command),  we also need to choose platform version 1.4.0 and above (latest didn't work in the video).

now the service restarts the task and containers and we will have persistent data, even if we later restart the tasks again (update, "[x]force new deployment")

we have many stopped tasks, which we can see the reasons for failing, in mongoDB this bites us in the ass. the new task tries to get the lock, but it's already held by the previous one task.

we won't bother solving this problem for now, as we are planning to replace the mongoDB with something else later. we simply remove the task manually instead of having a rolling update.

#### Our Current Architecture

we currently have a backend container and a mongodb container, both resting inside the same task, we also have a volume with AWS EFS Storage that gives us data persistency. we also have a load balancer that gives us a consistent ip address.

#### Databases & Containers: An Important Consideration

we can manage our own Database containers,just like how we do it locally, but there are some issues.
- scaling and managing availability can be challenging, we might need multiple instances that have to be synched.
- performance when there is a traffic spike
- backups and security

these are things that are mostly unique to deployment situations, they don't matter much in development.

therefore, we should consider moving our self-managed database outside, and use  managed database service, such as AWS RDS (relational database service), MongoDB Atlas, or others.

this is another form of tradeoff, we can manage the database on our own, but we can also use a generic solution. mongoDB atlas is a cloud based version of mongoDB, which makes scaling and synchronizing easier.

#### Moving to MongoDB Atlas

we can use MongoDB atlas for free for now, we log-in into the mongoDB atlas website, and create a cluster, we choose the shared-cluster (which is free), we choose a cloud provider (doesn't matter which), we choose the free tier and follow the instructions. this will give us cloud mongoDB to which we can connect. we replace the connection string to point to the new storage.

we now need to choose if we use the cloud option during development, or if we continue using the local version for development to avoid eating up our data quota. this might mean we have different versions of mongo db, so we need to align the mongo version of the container with that of the cloud version (which usually lags behind the desktop version).

if we decide to use the cloud service in both cases, we can choose which database we use in the code with environment variables, to avoid contaminations.


```js
mongoose.connect(
  `mongodb+srv://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_URL}/${process.env.MONGODB_NAME}?retryWrites=true&w=majority`,
);
```

we can now get rid of the mongodb container, this also means we don't need the named volume, and so on, we also should remove the "depends_on:" key. this fails because of mongoDB atlas has it's own security, and we didn't configure them yet, we need to allow connections from IPs (whitelist), add and configure users with proper roles and privileges (read & write, admin).

now things should work from the local development environment.

#### Using MongoDB Atlas in Production

we switched over to MongoDB Atlas because we wanted to use it in production, we enter the task definition configuration, and delete the container for DB, we also remove the file system resource which is no longer needed, and we can also delete the security group.

we now change the URL from localhost and use the new credentials, and use the production environment. and we update the task again, which will now use the external mongoDB atlas service.

</details>

### Multi-Stage Build

<details>
<summary>
multi stage build processes. Special issues concerning deployment of frontend code.
</summary>

we are still missing the frontend part of the application. we want our React SPA (single page application) deployed as part of the cluster. while this seems easy, there is a specific issue.  most front end applications have a build step, which we usually ignore during development.

#### Understanding a Common Problem

some apps and projects have a build step, in web development, this means an optimization script that runs after development but before deployment. the development and the production setup isn't the same.

This happens in react, angular, vue and other, they all have code that isn't executable by the browser, but is compiled/transpiled into code that can run in the browser. this is the work of the bundler (such as parcel). other stuff that happen is code optimization and minification. the development stage also has a way to serve the files (with `npm start`). this development server isn't suited for use in production, it's too resource intensive.

all these frameworks have a build script, such as 'react-script build' that produces production ready code, which can then be served by any webserver. but this isn't enough, even if we tell our container to run the build command, it won't create a suitable server.

so this is our problem, we need a production ready code and something to serve it.

#### Creating a "build-only" Container

when we develop a ReactJS app, we get live-reloading (when source code changes), development servers, and it uses un-optimized javascript code and features that aren't supported by all browsers.\
when we deploy th app, we want optimized code that will work with all browsers, and without that attached server.

we need our reactApp to be different for development and production. we actually don't need the *node* image, because the nodeJs is used to give us the server, not for the code itself.


we tackle this issue by adding another dockerfile, this one called "Dockerfile.prod". we will also need a server to serve them.

#### Introducing Multi-Stage Builds

Multistage build allow us one docker file, but with multiple steps, that can use the results from one result (copy files and folder that were created earlier). we can then run all the step or just some of them. we can also switch between base images once we finished with the earlier.

We use the `as` keyword to label steps, we can then copy from those steps with `--from=<step name>`, so we can grab the files from the build folder that was created in the build step. we use the nginx image as the server for our website.
we can have an extra stage for testing if we want.

```dockerfile
# FROM node
FROM node:14-alpine as build

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

#EXPOSE 3000

#CMD ["npm", "start"]

RUN npm run build

FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx","-g", "daemon off;"]
```

#### Building a Multi-Stage Image

we need to check if our code has things that need to change, such as "localhost", which was ok in development (it runs on the browser), but in the real world, it runs on the user browser, so it needs to be changed. the correct domain depends on where it's deployed, so if we deploy it on the same task as the backend, we can eliminate the domain entirely, switch "http://localhost/goals" to  "/goals".
if we use a different service we need to specify that domain.

now we want to build the image for production. we specify the file and the context again.

```sh
docker image build -f frontend/dockerfile.prod -t academind/goals-react ./frontend
docker image push academind/goals-react
```

#### Deploying a Standalone Frontend App

we want to deploy that image on the AWS cluster, we click on the "task definition" and "add container" with the correct image, we also change the startup dependency ordering to ensure the frontend only start after the backend has.\
but we have two containers mapped to the same port in the same task. this isn't allowed. and we can't create this container in this task yet. so we need a new task, so we create another task, which requires us to change the domain in the code again, the solution of omitting the domain doesn't work anymore.

we can't use environment variables directly, because of how react build works, but node gives us something.
```js
const loadBalancerURL = 'http://ecs-lb-something.elb.amazonaws.com';
const backendURL= process.env.NODE_ENV === 'development' ? 'http://localhost:80' : loadBalancerURL;
```

we need a new load balancer, give it a name, make it internet facing, on the same vpc as the tother, have a new target group type ip. now we have a different path for each stage, this is determined by how the image is built. "npm start" is development, and "npm run build" is production.

eventually, we will have two services in the cluster, each running one task with a load balancer that provides a constant ip address. this should work now.


#### Development vs Production: Differences

we have different dockerfiles for development and production, there is no way around it. having different url doesn't mean we have different environments, we use the same source code, just with different configuration. the code is still locked into the image.

#### Understanding Multi-Stage Build Targets

one last note on multi stage build targets, we can build parts of the build with the *--target* flag to specify up to which part we want to build. this can help with images that can also run the test or not

#### Beyond AWS

AWS isn't the only cloud provider. but no matter which one we choose, we usually will have some kind of tradeoff between managing everything and delegating tasks to the cloud provider and to other services.

#### Module Summary

this module was about deploying containers on a remote machine, either directly or by using a managed service. looked at differences between development and production in terms of volumes, database, urls.
we also explored multi-stage build files and how to use them to create image that have a build stage.

we talked about AWS -clusters, service, tasks and containers, and we looked at other cloud services such as file-systems and the mongoDB atlas cloud database.

</details>

### Docker And Containers Summary

<details>
<summary>
Summary of what we did so far
</summary>

Summary of the docker core concepts, development and deployment.

#### Images & Containers

containers are isolated boxes with a runtime environment, a file system and source code.a container is 'stateless', it doesn't retain data after it's removed, unless it uses a volume for data.

images are blueprints for containers, they are stored in registries like dockerhub, the are the readonly layers on which the containers are built. they are composed of layers which can be shared between versions of images.

#### Key Commands

- `docker image build` - build image
  - *--tag, -t* - tag image
  - *--file,-f* - dockerfile
- `docker container run` - run container
  - *--name* - container name
  - *--rm* - remove when stopped
  - *--detach,-d* - run in the background
  - *--publish, -p* - open ports
- `docker image pull` - get image from repository
- `docker image push` - push image to repository

#### Data, Volumes & Networking

having persistent data for container, 
- anonymous volumes - mostly used together with other stuff
- named volumes - reuseable volume
- bind mounts - mirror data from the local machine into the container

communication
- container to the outside world - works immediately
- container to container - use the same network to make this possible
  
#### Docker Compose

a configuration file that allows us to spin together several containers with the respective flags and arguments. also can build images. great for multi-container projects.

`docker compose up`,`docker compose down`.

#### Local vs Remote

>"isolated, encapsulated reproducible environments"

we can run docker application either locally or on remote machine (one or more). containers are perfect even if just use them locally.

#### Deployment

when we deploy our containerized application to a remote machine, we don't use bind-mounts (we use `COPY` or volumes), multiple containers might need multiple machines.

multistage build can also help us, especially with applications that have a build step.

tradeoff between Control vs Ease-Of-Use, security also matters here.

#### Module Resources

</details>
