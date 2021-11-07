
<!--
ignore these words in spell check for this file
// cSpell:ignore udemy
-->

[Menu](../README.md)


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

<details>
<summary>
Overview of basic concepts and how to set up the Environment to use Docker.
</summary>

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

</details>