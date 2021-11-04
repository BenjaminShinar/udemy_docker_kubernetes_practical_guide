<!--
ignore these words in spell check for this file
// cSpell:ignore udemy println beny swfavorites macvlan
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

| action                   | Docker Containers                                                 | Virtual Machine                      |
| ------------------------ | ----------------------------------------------------------------- | ------------------------------------ |
| OS impact                | low, fast to run                                                  | bigger Impact, slower to start       |
| Disk usage               | minimal                                                           | larger                               |
| Sharing and distribution | easy                                                              | can be challenging                   |
| Encapsulation            | encapsulate applications with their environments and dependencies | encapsulate entire OS, extra baggage |

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
docker container run --detach --publish 80:3000 --rm --name nd ass1nd:0.0.1
docker container stop nd

docker image rm ass1py:0.0.1 ass1nd:0.0.1
```

#### Sharing Images - Overview

so far, docker helped avoid installing and uninstalling libraries and dependencies, we could use a different version of python for each program without manually managing them.

the next advantage of using docker is to share images (and containers), either with co-workers or publishing them to the world.
everyone who has an image, can run a container based on that image.
there are two ways to share an image:
1. by sharing the docker-file and the source code. so anyone can build the image.
2. share the image itself.

The preferred way is to share images, by pushing them onto a hub, which is a repository for images. if we want the dockerfile, we can look at the source code in the code repository (such as github). A complete image is assured to be the same as what everyone else uses.

#### Pushing Images to DockerHub

so where do we find actual image? we don't share them as files, we get them from repositories, such as dockerHub, or from private registries.

we can store our images on dockerHub, and then we could get them from different machines in the future, and other people can also pull those images and use them. DockerHub is the default registry that docker uses.

the format for the image is registry/user/depository/image:tag
we need to make the image name:tag to be the same as we want on the registry.

```sh
docker image pull <image/repo name : tag>
docker image push <image/repo name : tag>
```
to establish a connection between our docker and the registry we run the `docker login` command. images stored in layers, as always.

#### Pulling & Using Shared Images

we can get images with the `docker image pull` command, when we try running a container, docker first looks for the image locally, and only then at the online registry. this might create problems when we think we're using the latest version. we think the local version is the most up do to date, but it isn't.


#### Module Summary

- What images and containers are.
- Image layers, and how containers are another layer,
- How to get images, either by building them or by pulling them from a registry.
- How to use containers, run, stop, re-start, remove them, and how to use the interactively.
- How to manage and list containers and images. 


### Managing Data and Working With Volumes

A deeper dive into using containers. managing data in images and containers, how to use persistent data and connect data into containers. using data volumes.

#### Understanding Data Categories / Different Kinds of Data

different kinds of data:
> - Application: 
>   - Source code and environment
>   - Dependencies and libraries
>   - Copied into the image
>   - Unchangeable data, read only
> - Temporary Application data:
>     - Data generated by the application
>     - Can be stored internally or in a database
>     - It's ok to discard the data eventually.
>     - Stored inside the file system layer of the container.
> - Permanent Application data:
>     - Needs to persist
>     - Stored in files / database
>     - Data won't be lost when the containers finishes.


Persistent data storage is down with **Volumes**.

#### Analyzing a Real App

another nodeJs example for us to dockerize. the folder "data-volumes-01-starting-setup"

this time the form creates files and stores them, we would want these data to be persistent somehow across uses. we don't want to lose the feedback from the user when the website goes down.

#### Building & Understanding the Demo App

we start by dockerize-ing the app. just like what we did before.

```dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80

CMD [ "node", "server.js" ]
```

now we build and run the image. we can go into the container afterwards and see the files being created when we use the website. we can also visit the feedback folder from the browser going into (localhost:3000/feedback/filename.text), but this isn't available from the host machine directly.

```sh
docker image build --tag feedback:0.0.1 .\data-volumes-01-starting-setup\ 
docker container run --rm --detach --name feedback -p 3000:80 feedback:0.0.1
docker container exec -it feedback bash
```

#### Understanding the Problem

When we close the container and run it again, all the data we had was removed! this happens when we remove the container, stopping and starting the container again is ok. but the container hold the file system layer, so when the container goes away, the layer is removed.

#### Introducing Volumes

The solution for this problem is by using volumes. volumes are folders on the host machine that are mounted (mapped, made available) on folder inside the container. unlike the copy command, the connection between the folders remains. this way, data remains even after a container shuts down.
this way we can have data available from the host machine, and we can relaunch a container with the same data.


#### A First, Unsuccessful Try

to use volumes, we need to change the docker file by adding the `VOLUME` stanza. we first decide which folder on the container should be exposed / linked to the host machine.

```dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80

VOLUME ["/app/feedback"]

CMD [ "node", "server.js" ]
```

now we build again and try this

```sh
docker image build --tag feedback:0.0.2 .\data-volumes-01-starting-setup\ 
docker container run --rm --detach --name feedback -p 3000:80 feedback:0.0.2
```

but this fails! the container crushes. we can look at the logs and see the errors.

the error is actually coming from the nodejs code, the rename command doesn't work across machines.

we can fix the nodejs code, this will require re-building the image.
```js
await fs.copyFile(tempFilePath, finalFilePath);
await fs.unlink(tempFilePath);
```
but this still isn't good enough!

#### Named Volumes To The Rescue!

there are two ways to use external data,Volumes and bind mounts.
volumes also have two types: anonymous and named. in both cases docker sets up a folder on the host machine and link it.
anonymous volumes don't persist across the lifetime of the container.
Named volumes have a defined path in the container mapped to the path on the host machine. and they are able to persist.

named volumes aren't created in the dockerfile, we need to create them when running the container, so we can remove the instruction from the docker file.

```dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80

#VOLUME ["/app/feedback"]

CMD [ "node", "server.js" ]
```
to run a named volume, we add a flag to the container run, we pass a name for the volume and the path inside the container
*[volume name]:/[path]*

```sh
docker container run --rm --detach --name feedback -v named:/app/feedback -p 3000:80 feedback:0.0.3
docker container stop feedback
docker container run --rm --detach --name feedback -v named:/app/feedback -p 3000:80 feedback:0.0.3
```
anonymous volumes are coupled with a container, named volumes are entities on their own.

#### Removing Anonymous Volumes

when we start a container with an anonymous volume with the *--rm* flag, the volume will be cleared when the volume is removed. if we don't have the flag, the volume won't be removed, but it also won't be reused. we have to remove it with the `docker volume rm` command.
each time we start with an anonymous volume, a new volume is created.

#### Getting Started With Bind Mounts (Code Sharing)

we now dive into bind mounts. 
bind mounts allow us a bi-directional connection to the container. but if we change the source code, we have to re-build the image. this isn't great for us. during development we would like to have quicker cycles of changes without all the restarts.

volumes are managed by Docker, and we don't know where they are stored. bind mounts are defined by us, and the container can see persistent and editable data.

bind mounts are specific to the container, so we need specify it with an absolute path and where it's mapped to.

```sh
docker container run --rm --detach --name feedback -v D:/Docker_Kubernetes_The_Practical_Guide/data-volumes-01-starting-setup/feedback:/app/feedback -p 3000:80 feedback:0.0.3
```

we should make sure that docker has access to the folder, (note visible in windows docker-desktop with wsl integration).
with docker toolbox the default is the user folders [docker toolbox instructions](https://headsigned.com/posts/mounting-docker-volumes-with-docker-toolbox-for-windows/).

in the video he has an error about binding everything.

note: for windows we can write `-v "%cd%":/app` instead of the entire path.

#### Combining & Merging Different Volumes

recall that this failed
```sh
docker container run --detach --name feedback -v D:/Docker_Kubernetes_The_Practical_Guide/data-volumes-01-starting-setup:/app -p 3000:80 feedback:0.0.3
docker container ls -a
docker container logs feedback
```

because of how we bind the folders, we overwrite the container file system with the original, we remove what we created in the image with the local folder. so we no longer have all of our dependencies.
we can have both volumes and bind mounts for the same container.

we need to tell docker not to overwrite the files inside it. we add another anonymous volume and direct it to the node modules folder.
```sh
docker container run --detach --name feedback -v feedback:/app/feedback -v D:/Docker_Kubernetes_The_Practical_Guide/data-volumes-01-starting-setup:/app -v /app/node_modules -p 3000:80 feedback:0.0.3
```
we can (any maybe should) have it in the dockerfile. if there is a conflict between volumes, the most specific one wins. so the anonymous volume wins over the bind mount and retains itself. we now can change the source code and still use the same image. this is easier for us in the development stages.

#### A NodeJS-specific Adjustment: Using Nodemon in a Container

changes in the html files are immediately reflected, but changes to the javascript code aren't. the application is being run by node, so we need to restart the node server (not the container), we can stop and re-start the container, but that clashes with the *--rm* flag which we really like.

for nodeJS, we can use a package called __"nodemon"__ that knows how to restart the server when something changes. we add this to "package.json" under "devDependencies", we also add a "scripts" section.

```json
"scripts":{
   "start":"nodemon server.js"
},
"devDependencies": {"nodemon":"2.0.4"}
```

this also requires us to change the dockerfile to use the script.

```dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80

#use an anonymous volume to keep the node_modules
VOLUME ["/app/node_modules"]

# use the 'start' script
CMD [ "npm", "start" ]
```
so we have to rebuild the image.

```sh
docker image build --tag feedback:0.0.4 .\data-volumes-01-starting-setup\ 
docker container run --detach --name feedback -v feedback:/app/feedback -v D:/Docker_Kubernetes_The_Practical_Guide/ \ data-volumes-01-starting-setup:/app -p 3000:80 feedback:0.0.4
```

for windows, because of wsl2, stuff doesn't work. there is an issue.

#### Volumes & Bind Mounts: Summary

three ways to use the *--volume, -v* flag, getting us an anonymous volume, a named volume or a bind mount.
```sh
docker container run -v /app/data #anonymous volume
docker container run -v named:/app/data #named volume
docker container run -v /path/to/code:/app/data #bind mount
```

| Volume type     | Lifetime                                                            | Reusability | Creation                                  | Notes                                            |
| ---------- | ------------------------------------------------------------------- | ----------- | ----------------------------------------- | ------------------------------------------------ |
| Anonymous  | with the container, disappears if the container used the *--rm flag* | none        | with the *-v* flag or from the dockerfile | create a match with outside resources to override bind-mounts           |
| Named      | persistent                                                          | yes, between containers and across time         | passing a name with the *-v* flag         | data can be shared across containers
| Bind Mount | persistent                                                          | yes, code is shared with the host machine        | passing an absolute path                  | allows for bi-directional changes in source code |


#### A Look at Read-Only Volumes

if the idea is to make changes to the source code available to the container, then it doesn't make sense for the container to be able to change the files on the host system. to enforce this, we can make the bind mount a read-only  volume, if we add **":ro"** after the container path in the volume, we make this volume read only.  the same rules of specificity apply, more specific volumes are stronger the general, so an anonymous volume will allow writing data again. \
Overriding only happens if we write them in the command line, not in the dockerfile.


```sh
docker container run --detach --rm --name feedback -p 3000:80  -v feedback:/app/feedback -v D:/Docker_Kubernetes_The_Practical_Guide/data-volumes-01-starting-setup:/app:ro -v /app/temp -v /app/node_modules -v feedback:0.0.4
```

#### Managing Docker Volumes

volumes are managed by docker,  we can look at available commands for volumes with `docker volume --help`.

- create
- inspect
- ls
- prune
- rm

we can list all our volumes, which will show us named and anonymous volumes, but not bind mounts.
we can create named volumes before running the container.
if we inspect the volumes, we can find the mount point on the host machine, this won't work well in windows, because docker desktop runs a virtual machine to run docker. if the volume is a readonly, it will show under the "options" key.

we can remove either all volumes (prune) or a specific one, but that also clears all of our data, so we need to be careful with them.



#### Using "COPY" vs Bind Mounts

if we are using the bind mount to get all the files into the container then why are we copying the contents inside the dockerfile?

the answer is that bind mounts are used during development, this is so we can reflect changes without stopping the container and re-building the image. once we get to the production/deployment stage, we won't have the source code available on the server, and we won't want to change it during runtime.

#### Don't COPY Everything: Using "dockerignore" Files

we can restrict what the `COPY` stanza copies, we can add ".dockerignore" file that won't be copied by the docker file when the image is being built. this is like ".gitignore".\
the dot is an important part of the file name. 

a good thing to ignore is the "node_modules" folder, which would protect us from overwriting the dependencies we got from `npm install`. we can also ignore the dockerfile itself, any git folders and anything that isn't required to run the application.


#### Working with Environment Variables & ".env" Files

> "Docker support build-time arguments and runtime environment variables"

arguments allow us to set flexible data that is matched with argument from the image build command with the *--build-arg* flag.

environment variables are available to applications inside the container, we can set them in the dockerfile `ENV` or pass them into the container.

for example, we could change the port that the server listens on to use environment variables.

```js
//app.listen(80);
app.listen(process.env.PORT)
```

we can set the environment variable in the docker file
```dockerfile
ENV PORT 80
EXPOSE $PORT
```

we can also change the environment variable when we run the container, with the *--env, -e* flag, which take a key:value pair. or pass a file with the environment variables by using *--env-file* flag
```sh
docker container run --env PORT=8003 <...>
docker container run --env-file ./.env <...>
```

we should be careful with the data that we put into the dockerfile and the image, we don't want to add any private data inside,that means passwords, credentials, private keys and stuff.

#### Using Build Arguments (ARG)

Docker also has build time arguments, that effect image building, in our example, we have the default port hardcoded into the docker file. this is done with `ARG` stanza, which takes a name and a possible default value. this parameter can only be used during build stages, but not for runtime commands (such as `CMD`).
the dollar sign means we are referring to a parameter.

```dockerfile
ARG DEFAULT_PORT=80
ENV PORT $DEFAULT_PORT
EXPOSE $PORT
```

when we build the image, we pass the value with the *--build-arg* flag so now the image uses this variable.
```sh
docker image build --build-arg DEFAULT_PORT=8000 .
```

because of how images are built (with layers), it's best to declare the arguments as late as possible, so we won't need to rebuild so much of the image for each change.

#### Module Summary

> "Containers can read and write data, **Volumes** can help with data storage, **Bind Mounts** can help with direct container interaction."

by default, data that is produced by the container is gone when the container finishes, to get the data out, we would want to use a volume. 

> Volumes are folder on the host machine, managed by Docker, which are mounted into the container
> - **Named Volumes** survive container removal and can therefore be used to store persistent data
> - **Anonymous Volumes** are attached to a container - they can be used save (temporary) data inside the container.
> - **Bind Mounts** are folders on the host machine which are specified by the user and mounted into containers (like named volumes).
>     - we combine them with anonymous volumes to override specifications.

> **Build Arguments** and **Runtime Environment** variables can be used to make images and containers more dynamic / configurable.

build argument allow us to modify the image we build. environment variables effect the container instance itself.


### Networking (Cross-) Container communication

Now we will look at networks, how containers talk to one another, or how can containers connect with the local machine with http request or how the outside world can connect with the containers.

#### Communication Types

three forms of communication that our containers require.

##### Case 1: Container to WWW Communication

lets assume that we have an application in a docker container, and that this application wants to talk to the outside world, a site that isn't managed by us.

we have the example in "networks-starting-setup", an app that uses the *axios* package to talk with an external api ("star wars api"), and fetches data from it.

so if we use this node in a container, we must allow it to send and receive requests

##### Case 2: Container to Local Host Machine Communication

another kind of communication is to something on the host machine, like a webserver or a database. it's another application, but it doesn't run inside a container. in the application, we have a mongo database running, so we need to talk with it.

##### Case 3: Container to Container Communication

the last kind of communication is between containers, we can run a sql database on a container, and have another container talk to it. most applications use several containers together, each container does one thing. so one container runs the database, another runs the front end side of the app, and a different container runs the backend logic.

#### Analyzing the Demo App

lets look at the application. it has some dependencies and it runs a web api, it doesn't have a front end side with html responses.
this API has four entry point
- get - favorites
- post - favorites
- get - movies
- get - people

the "get movies" and "get people" use the external star wars api.
we also need a mongo database, where we store data about our favorites. we communicate with the mongoDB by using the 'mongoose' package.

we will use mongoDB in a container, we will also use *postman* to send the http requests.


#### Creating a Container & Communicating to the Web (WWW)

we will first dockerize this app. we have a dockerfile already. trying to run just this app fails because we don't have mongoDB.

```sh
docker image build -t favorites-node ./networks-starting-setup
docker image ls
docker container run -d --rm -p 3000:3000 --name sw favorites-node
docker container ls -a
docker container run --rm -p 3000:3000 --name sw favorites-node
```
we try commenting out the code that talks with mongodb to see if the other parts run. we build the image again and see that the other parts work, containers get access to the web right out of the box, we can send http requests to the external world.

#### Making Container to Host Communication Work

now we check if we can make a container talk to an app working on the local machine. if we had a mongodb running locally, we would want to talk with it.

to fix this, we change our code and use a special address, we replace "localhost" with "host.docker.internal" this will work with any service, be it a an app or a web server on the local machine.

#### Container to Container Communication: A Basic Solution

communicating between containers. for this we need a container running mongodb.

[MongoDB](https://hub.docker.com/_/mongo) has an official image we can use.

we also need to change our code again, to make it talk to a dockerize container running the mongoDB.
we can inspect the mongoDB container and check the ip address of the container.

```sh
docker container run --rm -d --name mongodb mongo
docker container inspect mongodb
```

we can try changing the address in the code and hard coding it. this will work, but is a bad solution, we can't be sure that the mongoDB will always run on the same ip. and we had to change the image.

#### Introducing Docker Networks: Elegant Container to Container Communication

we can multiple containers running on the same docker network, we do this with the *--network* flag, which makes all containers running on the same network able to talk to one another.

we need to change the code again to make the application able to talk to other, docker gives us an internal DNS, so we can use the container name in the code to talk to other application. we just need to build the image again...
```js
mongoose.connect(
  //'mongodb://localhost:27017/swfavorites',
  //'mongodb://host.docker.internal:27017/swfavorites',
  'mongodb://mongodb:27017/swfavorites',
  { useNewUrlParser: true },
  (err) => {
    if (err) {
      console.log(err);
    } else {
      app.listen(3000);
    }
  }
);

```

networks aren't created by running a container (named volumes are...), we must create them before.
```sh
docker network create my_network
docker container run --rm -d --network my_network --name mongodb mongo
docker container inspect mongodb --format "{{json .NetworkSettings.Networks }}"
docker container run --rm -d -p 3000:3000 --network my_network --name sw favorites-node
```

we don't have to add published port to the mongoDB container, as it is only talking to stuff inside the network, it doesn't go outside or talks to external apis.

docker doesn't replace source code to replace stuff, it has an internal dns that resolves addresses.

#### Docker Network Drivers

there is an additional flag to the `docker network create` command, the *--driver, -d* flag with one of the following options:

- *bridge* (default) - containers on the same network find each other.
- *host* - for standalone containers, the container shares the same network as the local host
- *overlay* - parts of the swarm orchestration mode
- *macvlan* - custom MAC address
- *none* - no networking
- (others, 3rd party tools) - extensions
  
#### Module Summary

we can combine networks and volumes to store persistent data. most applications use more than one container.

Connection | notes
----|------|
Container to outside net | works out of the box
Container to local machine | requires code changes - replace **"localhost"** with **"host.docker.internal"**
Container to Container | use docker networks

## Practical Application Usage
(includes sections 5,)
### Building Multi-Container Applications with Docker
