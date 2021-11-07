<!--
ignore these words in spell check for this file
// cSpell:ignore INITDB dockerized
-->

[Menu](../README.md)

## Practical Application Usage
(includes sections 5,6,7)

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

the code is in the "multi-01-starting-setup" folder.
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
docker container run --name goals-backend --rm -d --network goals-network -v goals-logs:/app/logs --publish 80:80 -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-01-starting-setup\backend:/app" -v /app/node_modules goals-node
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
docker container run --name goals-backend --rm -d --network goals-network -v goals-logs:/app/logs --publish 80:80 -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-01-starting-setup\backend:/app" -v /app/node_modules -e MONGODB_USERNAME=max --env MONGODB_PASSWORD=secret  goals-node
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
docker container run -v "D:\Docker_Kubernetes_The_Practical_Guide\multi-01-starting-setup\frontend\src:/app/src" --name goals-frontend --rm -p 3000:3000 -it goals-react
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
