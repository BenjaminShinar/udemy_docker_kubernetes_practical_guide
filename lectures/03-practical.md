<!--
ignore these words in spell check for this file
// cSpell:ignore INITDB dockerized
-->

[Menu](../README.md)

## Practical Application Usage
(includes sections 5,6,7)

### Building Multi-Container Applications with Docker

<!-- <details> -->
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
now when we start this database, the backend fails to fetch the data, because it doesn't use the correct authorization. to fix this, we add the can add user name and password to the connection string in the backend. these were optional so far, but now are required. we also need a `?authSource=admin` at the end of the connection string

```js
//'mongodb://mongodb:27017/course-goals',
'mongodb://max:secret@mongodb:27017/course-goals?authSource=admin',
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

```js
//'mongodb://max:secret@mongodb:27017/course-goals?authSource=admin',
`mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@mongodb:27017/course-goals?authSource=admin`,
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
#### Module Summary

</details>
