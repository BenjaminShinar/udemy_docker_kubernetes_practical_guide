<!--
ignore these words in spell check for this file
// cSpell:ignore INITDB dockerized drwxr cliuser userdel adduser addgroup gecos laravel mkdir fastcgi ignore-platform-reqs chwon
-->

[Menu](../README.md)

## Practical Application Usage
(includes sections 5,6,7,8)

### Building Multi-Container Applications with Docker

<details>
<summary>
Demo application with multiple containers working together.
</summary>

a more realistic application, with multiple services and containers. lean how docker operates with multiple containers.

#### Our Target App & Setup

our application has three components:
1. Database - by using mongoDB.
2. Backend - nodeJS rest API.
3. Front - react single page application.

the code is in the "multi-app" folder.
we can go over the code and try to understand it on our own, but this isn't required. 

we want the dockerize-d database to persist, and for the logs folder to be persistent. we also want changes to the source code to be reflected live, both for the backend and the frontend.

task list
- [ ] Backend + Frontend
  - [ ] copy stuff properly in the dockerfile
  - [ ] mirrored source code volume, persistent logs folder
  - [ ] ensure live reload of code with daemon-js
  - [ ] fix network from local host to virtual network
- [ ] MongoDB 
  - [ ] persistent data using named volume
  - [ ] attach to virtual network
  - [ ] limiting access

#### Dockerizing the MongoDB Service

[MongoDB](https://hub.docker.com/_/mongo) image documentation.

if we aren't using dockerized versions of te backend, we would need to expose the port to the outside.
```sh
docker container run --rm --detach --name mongodb --publish 27017:17017 mongo
# check that the app works
node backend/app.js
```
for the future uses, we would want this to run inside as part of the network.
```sh
docker network create backend
docker container run --rm --detach --name mongodb --network backend --volume namedMongo:/data/db \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=secret \
mongo
```

#### Dockerizing the Node App

now we want to dockerize the backend app.

we need a dockerfile to build the image. for the moment, we use something very basic.

``` Dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80


CMD [ "node", "app.js" ]
```

we then build it and try to run it, but it should fail.
```sh
docker image build --tag backendImage backend/. 
docker container run --rm backendImage
```

we can no longer connect to the mongo database. we can fix it by changing the connection point. this would require us to re-built the image.

```js
mongoose.connect(
  //'mongodb://localhost:27017/course-goals',
  'mongodb://hist.docker.internal:27017/course-goals',
  {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  },
  (err) => {
    if (err) {
      console.error('FAILED TO CONNECT TO MONGODB');
      console.error(err);
    } else {
      console.log('CONNECTED TO MONGODB');
      app.listen(80);
    }
  }
);
```

if we have the frontend running as an none-dockerized application, we would need to expose the correct port on the backend container

```sh
docker container run --name goals-backend --rm --detach --publish 80:80 backendImage
```

#### Moving the React SPA into a Container

after dockerizing the database and the backend, we next move to the front end app.
as before, we need a dockerfile for the image.
the base image that we use is still node.

``` Dockerfile
FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]
```

we build and run the image as a container. we still need to publish the ports to the public. this will fail for us because of how react works, so we add the *-it* flag. once we do this, we have all three parts of the application running.

now we should polish the extra parts of the the application, such as networking,persistent data and hot reload.

#### Adding Docker Networks for Efficient Cross-Container Communication

the first part is to set up the network properly, so that the containers talk to one another directly, without going through the host machine.

For this, we first create the network, then we can stop publishing the port on the database container.\
For the backend, we again stop publishing the port, but this isn't enough, we also need to change the source code again to tell it to use the service domain name instead of the local host. so we change `host.docker.internal` to the container name `mongodb`.\
We also do the same thing for the front end source code. wherever we use 'localhost' we need to replace it with the service name. so instead of `http://localhost/goals/`, we have `http://goals-backend/goals/`. we can also stick this in a const variable if we decide we might want to change this again.\
because we changed the source code, we need to build the backend and frontend images again.

```sh
docker network create goals-network
docker container run --name mongodb --rm -d --network goals-network mongo.
docker container run --name goals-backend --rm -d --network goals-network goals-node
docker container run --name goals-frontend --rm -it --network goals-network  --publish 3000:3000 goals-react
```

all this image building takes longer than we want, because of all the copying that happens (the "node-modules" folders). we will fix this later.

however, **this still doesn't work!** the react stuff still doesn't work! that's because the app isn't being run directly inside the container, it run inside the browser! \
Well, we need to rethink our steps, we first revert our changes, from the service name back to **localhost**. so we still need to publish the port on the backend container. and we don't use the *--network* flag in the front end container.

```
docker container run --name goals-backend --rm -d --network goals-network --publish 80:80 goals-node
docker container run --name goals-frontend --rm -it --publish 3000:3000 goals-react
```

now that we got the network part settled (sort of), it's time to move forward.

#### Adding Data Persistence to MongoDB with Volumes

in the current state of things, removing the mongoDB containers causes us to lose all the data that our app created. we want this data to persist across runs of the container.\

we do this by adding the *--volume,-v* flag to the run command, in the documentation we see the appropriate usage, which is the path inside the app to where the data is stored. we will use a named volume, rather than an anonymous one or a bind mount.

```sh
docker container run --name mongodb --rm -d --network goals-network --volume goals-data:data/db mongo
```

we can start the database container again and see how the data now persists.

another requirement was to add security. this is done with two environment variables: *MONGO_INITDB_ROOT_USERNAME* and *MONGO_INITDB_ROOT_PASSWORD*,

```sh
docker container run --name mongodb --rm -d --network goals-network --volume goals-data:/data/db -e MONGO_INITDB_ROOT_USERNAME=max -e MONGO_INITDB_ROOT_PASSWORD=secret mongo
```
now when we start this database, the backend fails to fetch the data, because it doesn't use the correct authorization. to fix this, we add the can add user name and password to the connection string in the backend. these were optional so far, but now are required. we also need a `?authSource=admin` at the end of the connection string.



```js
//'mongodb://mongodb:27017/course-goals',
'mongodb://[userThenCollinsThenPassword]@mongodb:27017/course-goals?authSource=admin',
```
if we try this again, things will work for us.
in the real world, we should somehow also pass those two as parts of the environment

#### Volumes, Bind Mounts & Polishing for the NodeJS Container

Our next target is have persistence data for the logs folder, and have live code updates.

we need one volume for the logs folder, we can either use named or bind volumes. we also want a bind mount to allow for live update, this requires an absolute path. recall how the priority works for paths. so we also add a volume for the node-modules

we are still missing the command to hot reload the source code when it changes. we saw earlier that we can do this with the *nodemon* package. we add it to the "package.json" files as a dev-dependency, we add a *"start": "nodemon app.js"* script, and fix the dockerfile `CMD` stanza to `["npm", "start"]`.

**NOTE: for windows we need to add *-L* flag for the script**
```json 
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start":"nodemon -L app.js"
  },
```
**NOTE: we might need to remove the 'package-lock.json' file.**
we now can build the image once again.

```sh
cd multi-01-starting-app

#build image
docker image build --tag goals-node backend/.

#run container
docker container run --name goals-backend --rm -d --network goals-network -v goals-logs:/app/logs --publish 80:80 -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-app\backend:/app" -v /app/node_modules goals-node
```

two last things, we have the user name for the mongodb hardcoded, we don't like this. let's change this to use environment variables as well

```dockerfile
ENV MONGODB_USERNAME=root
ENV MONGODB_PASSWORD=secret
```

and now we change the code to use those variables dynamically.
we access them with `{}

```js
const userName = process.env.MONGODB_USERNAME;
const password =process.env.MONGODB_PASSWORD;
//'mongodb://user-then-collins-then-password@mongodb:27017/course-goals?authSource=admin',
`mongodb://{user-then-collins-then-password@mongodb:27017/course-goals?authSource=admin`,
```
we build the image again, and now run the container with the *--env* flag.

```sh
docker container run --name goals-backend --rm -d --network goals-network -v goals-logs:/app/logs --publish 80:80 -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-app\backend:/app" -v /app/node_modules -e MONGODB_USERNAME=max --env MONGODB_PASSWORD=secret  goals-node
```

now lets add a *.dockerignore* file to ensure we aren't copying dependencies again and again.

```dockerignore
node_modules
Dockerfile
.git
```

we build the image again, and continue to work on the react frontend service.l

#### Live Source Code Updates for the React Container (with Bind Mounts)

in the react code, we also want to allow for live source updates. we need bind mounts as well. there is no need to use nodemon in react.

```sh
docker container run -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-app\frontend\src:/app/src" --name goals-frontend --rm -p 3000:3000 -it goals-react
```

eventually this works. if we want live update, we need to follow the article attached and use a linux based file system.
(not going to do this)

our frontend image takes longer to build. we don't want this. we can use another *.dockerignore* file to reduce the amount of work we do.

#### Module Summary

we managed to dockerize our three components, we encountered some problems and fixed them. this section was aimed for development setup, rather than production.

we turned out to have three long docker container run commands, we would like to somehow reduce this. this is the topic of the next section.

</details>

### Docker Compose: Elegant Multi-Container Orchestration

<details>
<summary>
Using a docker-compose configuration file to build and run multiple containers with the appropriate flags
</summary>

In the previous section we created a multi-container application, we had three containers working together and things eventually worked out.
however, actually running the containers with all the correct commands was quite long and tiresome. we had many flags and volumes, and things got confusing pretty quick.

The docker eco-system has a built-in tool called **Docker-Compose**, which allows us to build everything together with one command and take it down just as easily. 

#### Docker-Compose: What & Why?

Docker compose allows us to replace multiple docker commands with a configuration file. instead of building images and running containers as separate commands, docker-compose takes care of all of this. this makes starting the app much easier, and also helps with sharing the workflow.

docker compose is not a replacement of dockerfile and doesn't build images. it also isn't a replacement for images or containers. and it's not intended for managing multiple containers on different hosts. it works best for a single machine. 

docker compose is a simple file. we put the configuration into the file. the core components are "services", which are the containers. for each service we can configure the behavior of the containers, such as ports, environment variables, volumes and networks.

docker compose files are a replacement for running individual commands. we will continue working with our previous application.

#### Creating a Compose File

we start by creating the file, called "docker-compose.yaml". here we describe our configuration. yaml format uses indentations.

we start by specifying the version of the docker-compose file, which determines which features ara available for us to use.
[list of versions and features](https://docs.docker.com/compose/compose-file/compose-versioning/).

lets go with the latest version, 3.8 in time of writing.

the next part is the services, which defines the services. we define the services by names. for each service we define the configuration for the container.

```yaml
version: "3.8"
services:
  mongodb:
  backend:
  frontend:
```

#### Diving into the Compose File Configuration

we can continue with the configurations. let's look again at our command to run the container.

```sh
docker container run --name mongodb --rm -d --network goals-network --volume goals-data:/data/db -e MONGO_INITDB_ROOT_USERNAME=max -e MONGO_INITDB_ROOT_PASSWORD=secret mongo
```

let's break it down
- name of the container *--name*
- detached mode *--detach*
- remove on stop flag *--rm*
- network *--network*
- name volume *--volume*
- environment variables (two of them!) *--env*
- the image itself

each of those is matched to a line in the docker-file.


```yaml
version: "3.8"
services:
  mongodb:
    image: 'mongo'
    volumes:
      - data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: max
      MONGO_INITDB_ROOT_PASSWORD: secret
    # networks:
    #   - goals-network
  backend:
  frontend:
  
volumes:
 data:
```

when we use yaml syntax (the **key:value** pairs) we don't need dashes to specify the items. For **named volumes** we need a root volume key. this allows containers to share the same volume.

#### Docker Compose Up & Down

we can spin up a docker-compose deployment with the cli command `docker-compose up`, it will pull and build all images if needed. by default we start in attached mode, but we can add *-d* flag. when we are finished we can simply shut it down with the `docker-compose down` command.
```sh
docker container prune
docker image prune -a
docker-compose up -d
docker containers ls
docker networks ls
docker-compose down
docker networks ls #no networks after shutdown
```

it does not remove volumes by default, unless we specify it with `docker-compose down -v`. we usually don't do this.

lets continue with the other containers.

#### Working with Multiple Containers

we now have the backend and frontend services. we already removed the images, but we can have docker-compose build them for us, we simply add the *build:* key to tell it to build the image. this replaces the image command.
there is a long form of context and dockerfile and argument if we have a different name or a complex build image process. the context is where we want to run the build command from. this will come up in the future.


we add the ports under "ports", the environment variables and the volumes. for the named volume we need to specify it under the volumes root-key as well. for the bind-mount, we can use a relative path from the docker-compose file. 

this time we will use an environment file instead, under "env/backend.env"
```
MONGODB_USERNAME=max
MONGODB_PASSWORD=secret
```

we will also add another key, **depends_on**, which means that this service will only run after another service is up.

```yaml
version: "3.8"
services:
  mongodb:
    image: 'mongo'
    volumes:
      - data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: max
      MONGO_INITDB_ROOT_PASSWORD: secret
    # networks:
    #   - goals-network
  backend:
    build: ./backend
      #context: ./backend
      #dockerfile: Dockerfile
      #args:
        #some-arg: some-value
    env_file:
      - ./env/backend.env
    ports:
      - "80:80"
    # networks:
    #   - goals-network
    volumes:
      - logs:/app/logs #named
      - /app/node_modules #anonymous
      - ./backend:/app # bind mount, relative path
    depends_on:
      - mongodb

  frontend:
  
volumes:
 data:
 logs:

# networks:
#   goals-network
```

we can try spinning up the file again, and see if it builds the image correctly and if the backend connects properly. things are going fine so far. we can even change the source code live and see it updated!

the name of the services are used by the containers internally, even if the names of the containers are now mutated with the prefix of the folder name.

#### Adding Another Container

we still have the frontend react app to add to our docker-compose file.we have a bind-mount volume and the ports as before. the new thing is the *-it* flag.
we can use the two keys of *stdin_open* and *tty* to recreate the effect. we can also have the *depends_on* key just to ensure our services are starting in order.
```yaml
version: "3.8"
services:
  #mongodb: #same as before
  #backend: #same as before
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend/src:/app/src # bind mount
    stdin_open: true
    tty: true
    depends_on:
      - backend
    
volumes:
 data:
 logs:
```
we run the command and see that everything works. it's quite nice and easy to use. we stick everything into a file and we can spin the entire app up with one command.

#### Building Images & Understanding Container Names

other the `docker-compose up` and `docker-compose down`, there are also some more options. for `docker-compose up`, we can add the *--build* flag to force a rebuild of the image, if something changed we should use this. if we simply want to build the images without running the services, we run `docker-compose build`. this can be useful as part of a set-up process.

the containers get names by either the docker-compose automatically (foldername, service name, and then a running number), but we can also force a container name with a *container_name* key. we usually won't use it.


#### Module Summary

There are many more options for docker-compose files.

the main advantage of the docker-compose file is the ease of use, it works for a single container commands just as efficiently as it works for multiple containers. it doesn't replace all the docker commands, but it simplifies some workflows. it's another tool for us to use.

Docker CLI | docker-compose.yaml | notes
---|----|---
image specification | image: | can be tagged, a url, etc
*--rm* | default behavior |
*--detach* | default behavior |
*--volume* | volumes: | more than one, list form. same syntax as cli
*--env* | environment: | more than one, same syntax as cli or with yaml syntax.
*--env-file* | env_file: | list of files with relative path
*--network* | networks: | not always needed, docker-compose creates a shared environment network for all the services. but we can specify if we want different networks for each service.
*--publish*| ports: | list form
*-it* | stdin_open:, tty: | the  cli flag is actually two flags combined, so two keys are fair game
*--name* | container_name: | probably not worth using

</details>

### Working with Utility Containers

<details>
<summary>
Using Containers as an environment rather than an application.
</summary>

a deeper dive into the usage of containers. not just running applications. "utility containers" are containers that we run because of their environment, which we can use to run additional commands.

#### Utility Containers: Why Would You Use Them?

imagine that we want to run a node app in a container? we first need to create the source code. this usually means setting up a project with `npm init`, which will create a "package.json" file. but we want everything to be dockerized, we don't want to install node js and all those libraries! this is a case where using containers as "utility containers" can shine.

#### Different Ways of Running Commands in Containers

we can run the node image in an interactive mode. which opens up the node environment for REPL. we can also run the container in an interactive mode but detached, and then use the `exec` command with the *-it* flag to run a command from outside the container. we can also use `exec` to run commands without interrupting the running behavior of the container.
```sh
docker container run --rm -it node 
docker container run --name nodejs -d --rm -it node 
docker container exec -it nodejs npm init
```

another option is to change the basic command of the container, so rather than starting in the default command, we start with some other command.
```sh
docker container run --rm -it node npm init
```

#### Building a First Utility Container

lets create something for ourselves.

```dockerfile
FROM node:14-alpine

WORKDIR /app
```

now we build the image and use it with a bind mount to create the node project on a local folder without having to install the node packages!

```sh
docker image build -t node-utility
docker container run --rm -it -v "${pwd}/node:/app" node-utility npm init
```

this isn't just for nodejs, it also helps with other programming stacks, such as php and laravel, and many others.

#### Utilizing ENTRYPOINT

what if we want to make our container limited to only **"npm"** commands? for these, we use the `ENTRYPOINT` stanza. when we run a container, if we add a command after the image name, that command overrides the command in the `CMD` stanza. if we have an `ENTRYPOINT` stanza, then anything we have after the image name is appended to what we wrote.

```dockerfile
FROM node:14-alpine

WORKDIR /app

ENTRYPOINT ["npm"]
```
and now we run the container again with just the 'init' after the image name. we therefore limit the use of this image to only **"npm"** commands.

```sh
docker image build -t node-utility
docker container run --rm -it -v "${pwd}/node:/app" node-utility init
docker container run --rm -it -v "${pwd}/node:/app" node-utility install express --save
```

the downside is that we are back to running long commands from the terminal, didn't we want to move to docker-compose to avoid that?

#### Using Docker Compose

we already said that docker-compose can also help us with single container applications.
```yaml
version: "3.8"
services:
  npm:
    build: ./
    stdin_open: true
    tty: true
    volumes:
      - ./:/app  
```

if we spin the services right now, things won't work for us, we need some way to use them. docker-compose has two additional commands we can use `exec` which allows us to run commands on already running containers, and `run`, which allows us to run a single service from the yaml. we simply specify the service name and the arguments we wish to add.

```sh
docker-compose up
docker-compose down
docker-compose run npm init
docker-compose run --rm npm init
```
when we start services with `docker-compose up` it is automatically removed, but no for `docker-compose run`. we can fix this by adding the *--rm* flag

#### Utility Containers, Permissions & Linux

some thread about linux utility containers, copied here in it's entirety.
[Utility Containers and Linux](https://www.udemy.com/course/docker-kubernetes-the-practical-guide/#questions/12977214/)

> This is truly an awesome course Max! Well done! \
> I wanted to point out that on a Linux system, the Utility Container idea doesn't quite work as you describe it.  In Linux, by default Docker runs as the "Root" user, so when we do a lot of the things that you are advocating for with Utility Containers the files that get written to the Bind Mount have ownership and permissions of the Linux Root user.  (On MacOS and Windows10, since Docker is being used from within a VM, the user mappings all happen automatically due to NFS mounts.)
>
> So, for example on Linux, if I do the following (as you described in the course):
> ``` Dockerfile 
> FROM node:14-slim
> WORKDIR /app
> ```
> ```sh
> docker build -t node-util:perm .
> docker run -it --rm -v $(pwd):/app node-util:perm npm init
>  ls -la
> ```
> 
> ```
> total 16
> drwxr-xr-x  3 scott scott 4096 Oct 31 16:16 ./
> drwxr-xr-x 12 scott scott 4096 Oct 31 16:14 ../
> drwxr-xr-x  7 scott scott 4096 Oct 31 16:14 .git/
> -rw-r--r--  1 root  root   202 Oct 31 16:16 package.json
> ```
>
> You'll see that the ownership and permissions for the package.json file are "root".  But, regardless of the file that is being written to the Bind Mounted volume from commands emanating from within the docker container, e.g. "npm install", all come out with "Root" ownership.
> 
> -------
>
> Solution 1:  Use  predefined "node" user (if you're lucky)\ 
> There is a lot of discussion out there in the docker community (devops) about security around running Docker as a non-privileged user (which might be a good topic for you to cover as a video lecture - or maybe you have; I haven't completed the course yet).  The Official Node.js Docker Container provides such a user that they call "node". 
> https://github.com/nodejs/docker-node/blob/master/Dockerfile-slim.template
> ```Dockerfile
> FROM debian:name-slim
> RUN groupadd --gid 1000 node          
> && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
> ```
> 
> Luckily enough for me on my local Linux system, my "scott" uid:gid is also 1000:1000 so, this happens to map nicely to the "node" user defined within the Official Node Docker Image.
> 
> So, in my case of using the Official Node Docker Container, all I need to do is make sure I specify that I want the container to run as a non-Root user that they > make available.  To do that, I just add:
> 
> ```Dockerfile
> FROM node:14-slim
> USER node
> WORKDIR /app
> ```
>
> If I rebuild my Utility Container in the normal way and re-run "npm init", the ownership of the package.json file is written as if "scott" wrote the file.
> ```sh
> $ ls -la
> ```
> ```
> total 12
> drwxr-xr-x  2 scott scott 4096 Oct 31 16:23 ./
> drwxr-xr-x 13 scott scott 4096 Oct 31 16:23 ../
> -rw-r--r--  1 scott scott 204 Oct 31 16:23 package.json
> ```
> 
> Solution 2:  Remove the predefined "node" user and add yourself as the user\
> However, if the Linux user that you are running as is not lucky to be mapped to 1000:1000, then you can modify the Utility Container Dockerfile to remove the predefined "node" user and add yourself as the user that the container will run as:
> 
> ```Dockerfile
> FROM node:14-slim
> RUN userdel -r node
> ARG USER_ID
> ARG GROUP_ID
> RUN addgroup --gid $GROUP_ID user
> RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user
> USER user
> WORKDIR /app
> ```
> 
> And then build the Docker image using the following (which also gives you a nice use of ARG):
> ```sh
>  docker build -t node-util:cliuser --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
> ```
> And finally running it with:
> ```sh
>  docker run -it --rm -v $(pwd):/app node-util:cliuser npm init
> $ ls -la
> ```
> ```
> total 12
> drwxr-xr-x  2 scott scott 4096 Oct 31 16:54 ./
> drwxr-xr-x 13 scott scott 4096 Oct 31 16:23 ../
> -rw-r--r--  1 scott scott  202 Oct 31 16:54 package.json
> ```
>  Reference to Solution 2 above: https://vsupalov.com/docker-shared-permissions/
> 
> Keep in mind that this image will not be portable, but for the purpose of the Utility Containers like this, I don't think this is an issue at all for these "Utility Containers"


#### Module Summary

we discussed the ways that we can use containers for the runtime environment, we can use docker containers as a way to get their abilities without installing the libraries on the local machine.
</details>

### A More Complex Setup: Laravel and PHP Dockerized Project

<details>
<summary>
Using a docker-compose set-up to start a php & laravel project. deeper dive and fixing problems.
</summary>

in this module we will practice what we learned so far, and discover some new abilities of docker-compose. we will do so by using a combination of PHP and Laravel, we will create a dockerized application this time. Laravel and PHP generally require a lengthy setup, so that's why using docker will be very helpful.

#### The Target Setup

docker isn't limited to node. node has application code and server runtime bundled together. Laravel is the most popular framework for PHP development. if we check the requirements for laravel we see that we need php and many more dependencies.

in this module, we will have 
- source code in a folder in the host machine
- PHP interpreter container
- Nginx Web server container
- MySQL database container
- *Composer* PHP utility container (*Composer* to PHP is like *npm* to node)
- Laravel Artisan utility container
- npm utility container (is used by laravel)

the application containers (PHP interpreter, nginx and mysql) are part of the running app, and the utility containers help us build and deploy it.

#### Adding a Nginx (Web Server) Container

we start in an empty folder, and we begin with a docker-compose.yaml file.
```sh
mkdir laravel
cd laravel
mkdir nginx
touch nginx/nginx.conf
```
lets begin with the basic layout, we start with the nginx server. we open a port and create a bind mount to make sure the configuration forwards the requests to where we need them. the port and the path to the file are described in the documentation. we also make sure the configuration is read-only so it can't be changed from inside the container.

```yaml
version: "3.8"
services:
  server: 
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  php:
  mysql:
  composer:
  artisan:
  npm:
```
the nginx.conf file is provided in the lecture resources, and describes how the server works. it lists the port that the sever listen on, where the root directory is, redirection rules and other stuff
```config
server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    root /var/www/html/public;
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:3000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

#### Adding a PHP Container

lets continue to the PHP container. we will need a custom dockerfile, we will put all of our dockerfile in once place.\
the dockerfile build on a *php-fpm* image and runs some commands to install packages. we need to run these commands in the correct root folder. we don't have a `CMD` command here, but we use that of the base image

```dockerfile
FROM php:7.4-fpm-alpine

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql
```

lets update the docker-compose file, we tell the file how to build the image (and which file), we also need to bind the container source code folder, we add a "delegated" to improve performance. we need to write some files to the folder, but there is no rush to do it immediately, so we can some performance improvement out of it.\
```yaml
version: "3.8"
services:
  #server: 
  php:
    build: 
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www/html:delegated   
  #mysql:
  #composer:
  #artisan:
  #npm:
```
in the nginx.conf file there is this line "fastcgi_pass php:3000;" that sends request into port 3000, while the container itself uses port 9000. but this isn't the correct place to map the request. this only matters for the host machine. instead we should change the configuration file.

#### Adding a MySQL Container

of course, mysql has an official image. we use a specific image, there is nothing configure about the network, but we need some environment variables. we will use a file instead. lets create a "env" folder and "mysql.env" file and populate it.

```env
MYSQL_DATABASE=homestead
MYSQL_USER=homestead
MYSQL_PASSWORD=secret
MYSQL_ROOT_PASSWORD=secret
```
we should reference this file in the docker-compose.yaml file
```yaml
version: "3.8"
services:
  #server: 
  #php:   
  mysql:
    image: mysql:5.7
    env_file:
      - ./env/mysql.env
  #composer:
  #artisan:
  #npm:
```

#### Adding a Composer Utility Container

the next step is to add the composer service, which is a utility container. we need another dockerfile for this, we do this to get the entry point set up

```dockerfile
FROM composer:latest

WORKDIR /var/www/html

ENTRYPOINT ["composer", "--ignore-platform-reqs"]
```

and now we update the docker-compose file.
```yaml
version: "3.8"
services:
  #server: 
  #php:   
  #mysql:
  composer:
    build:
      context: ./dockerfiles
      dockerfile: composer.dockerfile
    volumes:
      - ./src:/var/www/html
  #artisan:
  #npm:
```
we now have the three application containers, we can use the composer utility to create the application, and then launch it.

#### Creating a Laravel App via the Composer Utility Container

in the official laravel documentation, we see how to create a project with composer. it's `composer create-project --prefer-dist laravel/laravel`. we can run it with our utility container.

```sh
docker-compose run --rm composer create-project --prefer-dist laravel/laravel .
```

if we try it by ourselves, we should be seeing our "src" folder being populated.

#### Launching Only Some Docker Compose Services

we need to fix the *".env"* file so it will use the correct database.
```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=homestead
DB_USERNAME=homestead
DB_PASSWORD=secret
```
we can now try running our application. but before that, we need to fix some parts, we need an extra volume for the server service. we fix the root to the source file. (as the nginx.conf file)

```yaml
version: "3.8"
services:
  server: 
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./src:/var/www/html
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  #php:
  #mysql:
  #composer:
  #artisan:
  #npm:
```

we don't want to spin up the composer service, so we can specify only which services we want to run. but just running it didn't work properly.
```sh
docker-compose up -d server php mysql
```
turns out we aren't binding the configuration correctly, we need to bind to another file.

and try again, if we did it properly, we should see the laravel screen on port 8000 in the browser.
```
docker-compose down
docker-compose up -d server php mysql
```

rather then write all three servers that should go up, we can write them as dependencies using the *depends_on:* key to server service.

```yaml
version: "3.8"
services:
  server: 
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./src:/var/www/html
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - php
      - mysql
  #php:
  #mysql:
  #composer:
  #artisan:
  #npm:
```

we can add another option to the `docker-compose up`, we can force a build image situation with *--build*.
```sh
docker-compose up -d --build server
```
now, our code application should actually be running properly and being updated live when we change the source code.

#### Adding More Utility Containers

with the artisan utility, we build off from the php container. we can override some setting from the docker file, like adding an entry point.
```yaml
version: "3.8"
services:
  #server: 
  #php:
  #mysql:
  #composer:
  artisan:
    build: 
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www/html
    entrypoint: ["php","/var/www/html/artisan"]
  npm:
    image: node:14
    working_dir: /var/www/html
    entrypoint: ["npm"]
    volumes:
      - ./src:/var/www/html
```
now we first run the server up, and we then run the artisan container to check the database connection,

```sh
docker-compose run --rm artisan migrate
```
we should have see something happening.

#### Docker Compose with and without Dockerfiles

while we can add dockerfile commands in the docker-compose, we aren't required to do so. this depends on preference. there aren't `RUN` or `COPY` alternatives in the yaml file.

about the bind mounts, they are good for development stages, but aren't fit to deployment operations. when we get to the production stage, we want to put everything inside the image.

#### Bind Mounts and COPY: When To Use What

lets add a nginx dockerfile, for when we want to do deploy the configuration and the source code are added to the image as a snapshot.

```dockerfile
FROM nginx:stable-alpine

WORKDIR /etc/nginx/conf.f

COPY nginx/nginx.conf .

RUN mv nginx.conf default.conf

WORKDIR /var/www/html

COPY src .
```

now we also tweak the yaml file to make it build an image. the context does more than just say where the dockerfile is, it also dictates where the dockerfile is being built. so we cant set the context to the dockerfiles folder. this matters because the copy command happens in image build time, and bind mounts happen when the container runs.\
we should also do the copying in the php dockerfile and update the context for the build key. if we comment out the volumes bind mounts, the images will be build with the current source code. we don't change the bindings for the other containers, as they are only meant to be run as part of the development cycle. but because the artisan service uses the same dockerfile, we need to update it as well

```yaml
version: "3.8"
services:
  server: 
    build:
      context: .
      dockerfile: dockerfiles/nginx.dockerfile
    ports:
      - '8000:80'
    volumes:
      - ./src:/var/www/html
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - php
      - mysql
    php:
    build: 
      context: .
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www/html:delegated   
  #mysql:
  #composer:
  artisan:
    build: 
     context: .
      dockerfile: dockerfiles/php.dockerfile
    volumes:
      - ./src:/var/www/html
    entrypoint: ["php","/var/www/html/artisan"]
  #npm:
```

in the video there is an error, this requires our php dockerfile to get some more permissions (**might be a linux only issue**). we fix it by adding a `chwon` (change owner) command to `RUN` to give the default user permissions.


**(we should also fix the image to use *php:8.1.0RC5-fpm-alpine3.14* instead, this solved the problem for other people in the comments).**

```dockerfile
# FROM php:7.4-fpm-alpine
FROM php:8.1.0RC5-fpm-alpine3.14

WORKDIR /var/www/html

COPY src .

RUN docker-php-ext-install pdo pdo_mysql

RUN chown -R www-data:www-data /var/www/html
```

</details>