<!--
ignore these words in spell check for this file
// cSpell:ignore udemy println beny
-->

# Docker & Kubernetes: The Practical Guide

based on the udemy course [Docker & Kubernetes: The Practical Guide](https://www.udemy.com/course/docker-kubernetes-the-practical-guide/) or the [CheckPoint Version](https://checkpoint.udemy.com/course/docker-kubernetes-the-practical-guide) of the same course. 

## Introduction

(includes section 1)

> "Docker is a container technology: a tool for creating and managing containers."
> 
> Container: 
> - A standardized unit of software. 
> - A Package of code and dependencies to run that code.
>
> like having NodeJS code and the NodeJS runtime bundled together.

the same container always has the same behavior and results, no surprises.

an analogy of a picnic basket, it has both the food and the dishes needed. a standardized container isolates the contents inside it and can work with any shipping facility (ship, truck, etc...) that knows to work with containers.

containers are built-in into most modern operating systems, and Docker makes it easier to do.

### Getting Started

#### Why Docker and Containers?

the advantages of using containers:

>"Why would we want independent, standardized 'application management'?"

we have different development and production environments, and we want to build, run and test the application when we develop it in the exact same conditions (environment,state) as we will ship it to our customers later on.

an example of nodeJs code that uses *await* from version 14.3. even if our local environment has that version, maybe the machine that should run the code doesn't. 
we "lock" a specific version into the container, so now our application always runs the same.

this also helps us to have the same environment across all members of the team, and avoid the problem of having clashing versions of dependencies between projects that require different versions. this would limit productivity and be a source of bugs. with containers, each container has the everything it needs.

**Standardized, Independent, Self contained and moveable**

#### Virtual Machines vs Docker Containers

the same problems that containers solve are also solved by virtual machines and virtual operating systems.

virtual machine stack:

1. Host operating machine
2. Virtual os (one or more)
3. Libraries,dependencies, tools
4. Application (one or more for each virtual OS)

the problem is the this is a bit heavy, multiple virtual OS are costly to create and setup. if we keep to the rule of one virtual machine for each application, we have lots of repetition in terms of tools.

> Advantages:
> - Separated environments.
> - Environment specific configurations are possible.
> - Environments configurations cn be shared and reproduced reliably.
>
> Disadvantages:
> - Redundant duplication, waste of space.
> - Performance can be slow, boot times can be long.
> - Reproducing is possible, but tricky to do consistently. are we going to run a virtual machine in the production environment?

containers solve the same problem, but in a different way:

1. Host operating machine
2. OS Built-in (or emulated) container Support
3. Docker Engine
4. Containers
   - the libraries, dependencies, tools
   - the app itself

we skip the overhead of the virtual OS, even if some containers have an operating system, it's usually a lightweight one.

the configuration is limited to one file, and we can also package it into something called an __Image__.

action | Docker Containers | Virtual Machine
------------|---------|---------
OS impact | low, fast to run | bigger Impact, slower to start
Disk usage | minimal | larger
Sharing and distribution| easy | can be challenging
Encapsulation | encapsulate applications with their environments and dependencies | encapsulate entire OS, extra baggage

#### Docker Setup

before working with docker, we need to install it, the installation depends on our OS, the docker Desktop creates a virtual machine to run docker as if it was a linux machine.

we might need to do something with hyper-v.

now we can write `docker` in the command line and we will see stuff.

#### An Overview of the Docker Tools

in windows the docker-desktop is using a small virtual machine to run the docker engine.

there is also docker-hun, an online repository for images, and a tool called **docker compose**, which helps with deployment. **Kubernetes** is a separate tool that has an entire section later on.

#### Getting Our Hands Dirty

let's start with a short example, we will need a code editor, like vscode.

we take a small nodeJs code. which would run a small site with nodejs 14.0 code.

if we would have wanted to run this locally, we would have needed to install node, the dependencies and the *express* package.

to run this app on a container, we first need an image. we can create an image with a *docker-file*.

`FROM` - base image
`WORKDIR` - change folder
`COPY` - copy files
`RUN` - run shell commands
`EXPOSE` - expose ports to the outside world
`CMD` - what to execute when image starts.


to build the image, we go the directory and run the docker `image build command`, we can then run the image on a container. we can then visit localhost:3000 and see the html.

lets see the folder *first-demo-starting-setup*
```sh
cd first-demo-starting-setup
docker image build .
docker container run --detach --publish 3000:3000 be3
#grab the name
docker container ls 
docker container stop #<name>
docker container ls -a
docker container rm #<name>
docker container ls -a
```

#### The Next steps

Foundations: 
- we will look at what images and containers are and how to use them.
- Data and Volumes in containers
- Containers and networking, how containers communicate with one another

Real Life Examples
- Multi Container Projects
- Using Docker-Compose
- "Utility Containers"
- Deploying Docker Containers

Kubernetes
- Introductions and basics
- Data and Volumes in Kubernetes
- Networking
- Deploying a Kubernetes cluster.

## Foundations

(includes sections 2,3,4)

### Docker Images & Containers: The Core Building Blocks

The core concepts of docker: Images and Containers.

pre-built and custom images.
create, run and manage docker containers.

docker has images and containers. images are templates for the containers, they contain the code and required dependencies. we can run the same container based on one image several time. the container is running application, a concrete object that is created from the image.

#### Using & Running External (Pre-Built) Images

there are two ways of getting an image, one way is to use a pre-built image, something that a co-worker created and shared with us, or an official image from a docker repository, such as [DockerHub](https://hub.docker.com/).

we can use DockerHub immediately, without logging it. it's the default behavior of docker.

running `docker container run node` will download the latest official node image from DockerHub, and run it locally for us, getting us into the node interactive shell (REPL - Read, Evaluate,Print, Loop). getting an image from a hub is called "pulling".

we can see the containers with the `docker container ls -a` command.

let's try to get the node terminal
`docker container run -it node`, and now we can play with node directly, like checking the version with `node -v`. we exit it with `.exit`, which is a node js command.

we can have many containers running with the same image.

#### Our Goal: A NodeJS App

we usually want our container to do something, we use an image and build up on it, like have it execute a certain code for us.

we have another js example, in the folder
*nodejs-app-starting-setup*, which is a node webserver we can work with. had we wanted to run it locally, we would need node on our machine, to install the dependencies with `npm install` (which creates node_modules), and then run `node server.js` to start the server on local host (we would then visit port 80).

##### Building our own Image with a Dockerfile

now we will create a docker-file to containerize the server. this file contains the instruction to build the image.

we start with the `FROM` stanza, which tells us which image to use as a base image or an OS.\
The next command is to `COPY` file from the folder into the image. every container has it's own internal files system. the folder is created if needed.\
Now we want to get all the dependencies, so we want to call the same node command, we use the `RUN` stanza.\
but before that, we need to move ourselves into the correct Folder, with `WORKDIR`. we can change the folder before copying, we just need to be sure our paths match.\
To start the server, we want a command to happen when the container itself starts, this is done with `CMD`, which takes a shell command.\
The final thing we are missing is the Ports, the container is running in isolation, so we need to make a port visible to the host machine, this is done with `EXPOSE`


```dockerfile
FROM node

#copy everything from the folder into the image at app folder. 
COPY . /app

# move to working directory
WORKDIR /app

# expose port
EXPOSE 80

# run commands when the image is created
RUN npm install

# run this when the container starts
CMD [ "node", "server.js" ]
```

#### Running a Container based on our own Image

now we want to turn the docker file into an image. for now we won't give the image a name.
we still are missing something! while we exposed the port internally, we haven't connected it to our host machine. but actually, the port exposed in the image doesn't do much.

```sh
cd nodejs-app-starting-setup
docker image build .
docker image ls
docker container run -d --rm -p 3000:80 #image name
docker container run --detach --rm --publish 3001:80 #image name
```

in this example, have two running instances of the same image, two containers that run independently from one another.

#### Images Are Read-Only!

once the image is created, it's done. it won't reflect any changes, even if it copies something. what we write inside the docker file happens when the image is built. it's a snapshot of the source code.

There are ways to avoid re-building the image, but in the core, images don't contain about the changes that happened after it was created. \
When we create a new image with the `docker image build` command, we will have two images.

#### Understanding Image Layers

Images are layered based, when we change an image, only the parts that changed and the parts afterwards need to be re-built. if the dockerfile and the source files didn't change, then the layers can be cached. each instruction stanza is a layer.

a containers uses the same layers and adds it's own 'file-system' layer.

docker can't do deep analysis, so once a layer is changed, all subsequent layers also need to be re-created.

let's fix our dockerfile, so we won't have to get the dependencies after each change to the site layout. now we should be getting some speedups. because the results of `npm install` can be effectively cached.

```dockerfile
FROM node

# move to working directory
WORKDIR /app

### only copy the package.json
COPY package.json /app
# run commands when the image is created
RUN npm install

# Copy everything else
COPY . /app

# expose port
EXPOSE 80

# run this when the container starts
CMD [ "node", "server.js" ]
```

#### Managing Images & Containers

configuring and managing images and containers.
add *--help* to see description for docker commands.

images:
- tag - add "names" to image
- ls - list images
- inspect - analyze image
- prune - remove unused images
- rm - remove image by identifier

containers:
- name - give meaningful name
- ls - list containers
- rm - remove containers after they were stopped

#### Stopping & Restarting Containers

we can see all the main commands in docker if we run `docker --help`. there are many commands, but not all of the are in use. some commands also have alternative, 

listing containers is done with either *ps* as a main command or the *ls* command from the containers sub command.we can add the *--all, -a* flag to list containers at all states, not just the running ones.
```sh
docker ps
docker container ls -a
```

if we stop a container, we can restart it again.

```sh
docker container run -d --name ngn nginx
docker container stop ngn
docker container ls -a
docker container start ngn
docker container stop ngn
docker container rm ngn
```

#### Understanding Attached & Detached Containers

more we can do with our commands, we can run/start containers in the background, which means they don't block our terminal. this is __attached / detached__ mode. the default mode is running attached, but starting a stopped container is detached mode.

we can use the *--detach,-d* flag to run a container in detached mode. we can attach ourself to a container with the `docker container attach` command.
we can also see the logs with `docker container logs`. if we add the *--follow,-f* flag we will see the logs as they are added.

for a stopped container, we add the *--attach, -a* flag to make it a foreground task.


#### Entering Interactive Mode

lets look at another example, we have a python file at the folder "python-app-starting-app". it's a simple application that takes a min and max numbers, and returns a number in that range. no web server involved.

we will use this app in an interactive mode. it requires active participation from the user. we start by creating an image, so let's make a docker file, we start with the official python image

```dockerfile
FROM python

WORKDIR /app

COPY . /app

CMD ["python", "rng.py"]
```

so lets build this image and try running it.
```sh
cd python-app-starting-setup
docker image build --tag rnd .
docker container run --rm rnd
```
the image build, but we get an when we run the container, we are attached, but not completely, we need to also have input to the container.
lets look at the help documentation for running the docker. we can see the *--interactive,-i* flag, and the *--tty,-t* flag (a sudo terminal), so lets add those flags.

```sh
docker container run --rm  -it rnd
```
if we want to continue using the same container, we need to start it again
when we are attached to it, with STD-IN
```sh
docker container run --name rnd -it rnd
#do first try
docker container start -a rnd #doesn't work properly
docker container start -a -i rnd # input and output
```

so docker allows us to use simple utility programs, without installing packages on our local machine.

#### Deleting Images & Containers

When containers finish running, they are in a stopped state. they can be started again, or removed. we do this with the `docker container rm` command. we can't remove a running container, we must stop them before. we can use the *--force,-f*
flag to first kill a running container and then remove it.

for images, we can see all images and their sizes, 
```sh
docker image ls #list
docker images  #also list
docker image rm rnd
```

#### Removing Stopped Containers Automatically

if we don't intended to start a container after it's been finished we can automatically remove it after it's done or stopped. this is done with the *--rm* flag. 


#### A Look Behind the Scenes: Inspecting Images

the container build on top of the image, they have their own layer above it, but they all share the image layers.

we can get more information about images with `docker image inspect`

```sh
docker image inspect nginx
docker image inspect nginx --format "{{.Metadata}}"
docker image inspect nginx --format "{{json .RootFs.Layers}}"
docker image inspect nginx --format "{{range .RootFS.Layers}}{{println .}}{{end}}"
```

#### Copying Files Into & From A Container

copy files between the container and the host system.
we specify the source, the and where to copy to.
we can specify either the host or the container as the source or destination.

```sh
docker container run -d --name ngn --rm nginx
echo "ddd" >> dummy.txt
docker container cp dummy.txt ngn:/test123
rm dummy.txt
docker container cp ngn:/test123 dummy
```

if we want, we could copy code into the container, but it's not a good way. there are better ways to do that.
but some scenarios could prove useful, the more common case is to copy files from the container out to the host, if we forgot to set up a data volume.

#### Naming & Tagging Containers and Images

we can give names for images and containers, instead of using the image id or the container random name.

for containers, we simply pass the *--name* flag and give it a unique name. we can rename a container with `docker container rename <old name> <new name>`

for images, there aren't names exactly, but we use tags instead.
we can add tags to exiting images or add the tag when we build the image.
tags are structured as two parts **name:tag**, the name is shared for the image, and the tag can specify a specific image version, such as "latest", "alpha", "12.0.1"\
to build an image with a tag with add the *--tag,-t* flag. if we want to remove a tag from an image, we use `docker image rm` and specify the tag. an image can have any number of tags.

```sh
docker image tag nginx nginx:beny
docker image ls
docker image rm nginx:beny
docker image ls
```


#### Assignment Time to Practice: Images & Containers

lets look at the assignment, we have a folder "assignment-problem"

> Dockerize BOTH apps - the Python and the Node app.
> 1. Create appropriate images for both apps (two separate images!).\
> HINT: Have a brief look at the app code to configure your images correctly!
> 2. Launch a container for each created image, making sure, 
that the app inside the container works correctly and is usable.
> 3. Re-create both containers and assign names to both containers.
Use these names to stop and restart both containers.
> 4. Clean up (remove) all stopped (and running) containers, 
clean up all created images.
> 5. Re-build the images - this time with names and tags assigned to them.
> 6. Run new containers based on the re-built images, ensuring that the containers
are removed automatically when stopped.

first step is to create a Dockerfile in each folder so we could build an image
```sh
cd assignment-problem
touch node-app/Dockerfile python-app/Dockerfile #won't work in windows
```

dockerfile for python app
```dockerfile
FROM python

WORKDIR /app

COPY . /app

CMD ["python", "bmi.py"]
```

dockerfile for node app
```dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node", "server.js" ]
```

now we build the images and launch the containers
```sh
docker image build python-app/.
docker container run -it <python image>

docker image build node-app/.
docker container run --detach --publish 80:3001 <node image>
```

stopping and removing images and containers
```sh
docker container stop <container 1> <container 2>
docker container rm <container 1> <container 2>
docker image rm <python image> <node image>
```

building images with tags and running containers with names
```sh
docker image build --tag ass1py:0.0.1 python-app/.
docker container run -it --rm --name bmi ass1py:0.0.1
docker image build --tag ass1nd:0.0.1 node-app/.
docker container run --detach --publish 80:3001 --rm --name nd ass1nd:0.0.1
docker container stop nd
```


#### Sharing Images - Overview

#### Pushing Images to DockerHub

#### Pulling & Using Shared Images

#### Managing Images & Containers

#### Module Summary

#### Module Resources

