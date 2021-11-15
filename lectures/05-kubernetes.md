<!--
ignore these words in spell check for this file
// cSpell:ignore Kubermatic systeminfo USERPROFILE mkdir hyperv rootkey  configmap benjaminshinar Kops kubeconfig sigs
-->

[Menu](../README.md)

## Kubernetes
(includes sections 11,12,13,14,15,16)

### Getting Started With Kubernetes

<details>
<summary>
Basic Kubernetes Terms and Concepts.
</summary>

deploying docker containers with kubernetes. kubernetes is an independent container orchestration tool (framework) that works for large-scale deployment and is agnostic (independent of) the cloud vendor.

[Kubernetes website](https://kubernetes.io/)

#### More Problems with Manual Deployment

from the Kubernetes website:
> "Kubernetes, also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications."

when we deploy containers to the cloud, we might have a problem, when we manually deploy containers into a remote machine on the cloud (EC2), we have challenges beyond the security and configuration concerns.
- Containers might crush/go down and need to be replaced.
- Containers might be insufficient to handle spikes in traffic (or workload) and we will want to add more machine.
- If we have many containers running the same app, we would want the work to be distributed equally between them.


**Monitor**, **Scale**, **Distribute Workload**

all this requires some tedious manual work, and having a human ready to step in and perform the work.

#### Why Kubernetes?

Cloud services (like AWS ECS) can help with some of the tasks, like checking the health of the containers and re-deploys them if needed. we can also have autoscaling, and the LoadBalancer (which gave us a constant IP address) can also distribute work among the containers.\
The downside is that we are "locked" into the cloud vendor, and we have to confirm our configuration to what the specific vendor expects, we need to use the tools it provides to us, either with the UI, the CLI tool they provide or their configuration files.\
If we want to switch to another vendor, we will have to start the configuration process again according to what the new provider requires. we will have to learn new skills for each service that we use.

#### What Is Kubernetes Exactly?

Kubernetes lets us define a policy that works with any cloud provider: automatic deployment, scaling and load balancing and managing containers. we have one configuration file that can be used anywhere (as long as the machine uses kubernetes)

Kubernetes uses yaml configuration files, and we can even have cloud specific configuration options, if we ever need those. this is a standardized way of describing deployments.

Kubernetes is **NOT**:
- a cloud service provider, it doesn't replace AWS or Google cloud.
- a service by a cloud provider. we might get a kubernetes version from the cloud vendor..
- a single software, it's collection of tools and concepts.
- a replacement for docker. they work together (kubernetes can also use other containers)

Kubernetes is like Docker-Compose for multiple machines. 

#### Kubernetes: Architecture & Core Concepts

in the kubernetes world, containers are managed by **pods**. the pods are the smallest unit in the kubernetes world. a pod can manage one (or more) container.

a pod runs inside a **worker Node**, a node is a machine (real or virtual) that runs the pods, a node can run multiple pods. a worker node also has a *Proxy/Config*, which connects the pods and the outside world. when we run kubernetes, we need at least one worker node, and usually more.

The worker Nodes are managed by the **Master/Manager/Control Node**, which exists in **"The control plane"**. this is what the developer interacts with. we define the desired state, and the control nodes interacts with the worker nodes. we can have the worker node and the master node on the same machine, but we usually don't. The control plane is a collection of tools and services that operate on the nodes.

all those nodes run inside a **cluster**, which is a network where all those parts are connected. the master nodes talk with the cloud provider and use the appropriate commands for that vendor.

#### Kubernetes will NOT manage your Infrastructure!

just like docker-compose can run containers, but it doesn't configure the machine, so does kubernetes. there are things that kubernetes won't do for us, and that we need to provide.

we are responsible to create the cluster and the node instances, and give them the appropriate software (kubernetes), we are also responsible for creating the resources such as a load balancer or file systems which might be needed. there are additional tools for that.

but once we run Kubernetes, those things will be managed by it.

#### A Closer Look at the Worker Nodes

a worker node is a machine (such as EC2) that has pods (one or more), which have containers inside (usually one, but also more, also volumes), it also docker (or an equivalent software), and process called *kubelet* that communicates with controller node and a *kube-proxy* service. eventually, the worker nodes are controlled by the manager nodes.

in kubernetes, we only define the desired state, and the cloud provider sets it up.

#### A Closer Look at the Master Node

> The Master Nodes has:
> - API server - API for the Kubelets to communicate with
> - Scheduler - Watches for new Pods, selects worker nodes to run them on
> - Kube-Controller-Manager - Watches and controls Worker nodes, correct number of Pods & more
> - Cloud-Controller-Manger -  like the Kube-Controller-Manager BUT for a specific Cloud Provider. Knows how to interact with Cloud Provider Resources

the big cloud providers already have stuff like this set up and we only need to provide the work we want to run.

#### Important Terms & Concepts

core concepts we should keep in mind:

> - Cluster - A set of *Node* machines which are running the *Containerized* Application (*Worker Nodes*) or control other Nodes (*Master Node*)
> - Nodes - *Physical or virtual machine* with a certain hardware capacity which hosts *one or multiple Pods* and communicates with the Cluster.
>   - Master Node - Cluster *Control Plane, managing the Pods* across worker Nodes.
>   - Worker Node - Hosts Pods, *Running App Containers (+ resources)*
> - Pods - Pods *hold the actual running App Containers* + their *required resources* (e.g. volumes)
> - Containers - Normal (Docker) Containers
> - Services - A *logical set (group) of Pods* with a unique, Pod- and Container- *independent IP address*
> 

</details>


### Kubernetes in Action - Diving into the Core Concepts

<details>
<summary>
Actually using kubernetes
</summary>

setting a Kubernetes environments, working with Kubernetes objects and deploying an actual example.

#### Kubernetes does NOT manage your Infrastructure

as before, we need to keep in mind that kubernetes does not create the cluster and the node instances. this is something we need to do. kubernetes manages the deployed applications, but it won't create the infrastructure. it's not a cloud infrastructure creation tool.

It doesn't know anything about the machines that it will use, and requires us to create them and install the required software. we also might need the other resources such as the load balancer and file systems.

There are tools for creating resources, such as [Kubermatic](https://www.kubermatic.com/) and the cloud providers have managed services with some good presets.

#### Kubernetes: Required Setup & Installation Steps

we will use a local example for this part of the course. we need to install some stuff beforehand. we want a cluster with a master node and worker nodes. we need those nodes to have the correct software, such as kubernetes, docker, and so on.

we also need the Kubectl on our local machine, this allows us to sends instructions to the cluster via the CLI. it communicates with the master node which then interacts with the worker nodes.

in the real world, we deploy on the cloud, but for the learning process, we will use [minikube](https://minikube.sigs.k8s.io/docs/) to run a cluster locally.

#### macOS Setup
#### Windows Setup
to check if we can install the tools we run `systeminfo` in the command line and check that a hypervisor is detected, we then install minikube and kubectl from the websites.
```sh
systeminfo
minikube version
kubectl version --client
```
now some other stuff.
``` sh
cd %USERPROFILE%
mkdir .kube
echo "" > config
```
and now we start a minikube machine
```sh
# This will start a virtual machine
minikube start --driver=docker
#minikube start --driver=hyperv
# Verify that things work
docker container ls -a
minikube status
minikube dashboard #opens a browser tab!
minikube delete
```

#### Understanding Kubernetes Objects (Resources)

we need to run this in administrator mode
```ps

```

let's go over the language the kubernetes works with. it works with objects, such as pods, deployments, services, volume and others. we can create object imperatively or declaratively, we start with th imperative approach.

a **Pod** is the smallest unit that kubernetes interacts with, it contains and runs one or more containers inside it. they contain shared resources for all the containers inside them, by default, a pod has a cluster-internal IP address, which is used internally. if we have multiple containers inside the pod, they can communicate with one another using localhost (like multiple containers in AWS ECS task).

> "pods are '*ephemeral*', kubernetes ill start, stop and replace them as needed"

if we want to store data, we need to set this up ourselves, just like local containers. we can create pods directly, but we usually use kubernetes to do this for us. this is done with controller objects, such as *deployment*.

#### The "Deployment" Object (Resource)

one of the most important objects we will use. a deployment controls one or more pods, we define the deployment to the desired state, and kubernetes will do what's needed to reach that state. the pod objects are created with the containers and runs them on a worker node. we can pause or delete deployments, and roll them back to a previous state.

deployments can be scaled dynamically and automatically (according to some rules) to create more pods. we can have more than one pod running the same container.

let's get our hands dirty!

#### A First Deployment - Using the Imperative Approach

we have sample app that can either return a web page or crush if we send a request to "/error" to port 8080.

we first need to build the image and push it to the dockerhub

we check the status of the minikube cluster and then tell the cluster what to do.
```sh
minikube status
kubectl create deployment some-name --image=local-image

kubectl get deployments
kubectl get pods
kubectl delete deployment some-name
kubectl create deployment some-name --image=remote-image
minikube dashboard
```

in the dashboard we can see the status of the cluster, and even see the internal IP of the pod.

#### Kubectl: Behind The Scenes

when we ask the kubectl to create a deployment, the request goes through the master node (control plane), where the scheduler analyzes the request and decides where (worker node), then the kubelet in the worker node does the creation and monitoring of the stuff.

#### The "Service" Object (Resource)

to reach a container, we need a service object, a service exposes the pod to other pods in the cluster or to the outer world. pods have an internal IP by default, which is changed whenever the pod is created, so we can't use it really. a service groups pods together and gives them a shared IP address that doesn't change. we can also expose this ip address outside and make our pods reachable.

#### Exposing a Deployment with a Service

we can create a service with `kubectl create`, but a better way is to expose it. we need to pass the type and the port.

```sh
kubectl expose deployment test-app --type=LoadBalancer --port=80
kubectl get services
```

there are a few types:
1. ClusterIP - makes this pod reachable from inside the cluster
2. NodePort - accessible from outside
3. LoadBalancer - use an existing load balancer and evenly distribute traffic

most cloud providers support loadBalancer, in minikube we don't get an external ip. but we can still get an ip
```sh
minikube service test-app
```

#### Restarting Containers

we can play with our deployment a bit, we have a way to crush the app, so we will lose the container. we can also delete the pod and then the deployment restarts it. but then we don't see the restart count go up. 

we can `exec` the pod and restart it, though.

#### Scaling in Action

if we don't have auto-scale, we can add more pods

```sh
kubectl scale deployment/test-app --replicas=3
kubectl get pods
kubectl scale deployment/test-app --replicas=1
kubectl get pods
```

this gives us more pods, running the same container, and with the load balancer, traffic will be directed to another pod.

#### Updating Deployments

changing the code, updating the deployment, and then rolling back.
lets assume we bring up an updated image, now we want to make our deployment use the updated image.

```sh
kubectl set image deployment/test-app <current_image-name,no tag>=<new-image-name, with tag>
```

we need to make sure the new image has a different tag, otherwise kubernetes won't see a difference and won't do anything.

we can see what happened in the dashboard under the 'events' list for the pod

#### Deployment Rollbacks & History


```sh
kubectl rollout status deployment/test-app
#this will fail
kubectl set image deployment/test-app nginx=nginx:benny
kubectl rollout status deployment/test-app
kubectl get pods
kubectl rollout undo deployment/test-app
kubectl rollout history deployment/test-app
kubectl rollout history deployment/test-app --revision=<revision number>
```

the old pod doesn't go away because the new pod can't find the image and start. we can cancel the deployment with `rollout undo`. we can also look at old versions of the deployment and return to it.

```sh
kubectl rollout undo deployment/test-app --to-revision=1
```

now lets clean stuff up a bit before moving to the declarative approach
```sh
kubectl delete service test-app
kubectl delete deployment test-app
```
#### The Imperative vs The Declarative Approach

the imperative style means telling the kubernetes what to do, we repeat commands and have to memorize them, we want something else. just like we moved from `docker container run` commands to use a docker-compose file.

we would want to write down our configuration to a file and use that file to tell kubernetes what is the desired state, this is called **a resource definition** file.

in the imperative approach we write commands to trigger action, in the declarative approach we use a file and tell kubernetes to reach the target state in the file.

```sh
kubectl apply -f config.yaml
```

#### Creating a Deployment Configuration File (Declarative Approach)

we will still use the same application as before. we want to clear all of the deployments.

now we need a file, there is no default file name, but it should be a yaml file, so let's use "deployment.yaml".


[reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/)

we must start with the rootkey of "**apiVersion**", then we define the "**kind**" of kubernetes object we want to create, in our case, "deployment", and then "**metadata**" with a name as a nested value. the final part is the "**spec**", which is the meat of the object, how it's going to be configured.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: test-app-2
spec:
```
#### Adding Pod and Container Specs

let's look into the specification of the deployment, we define the number of pods, and how to build them.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: test-app-2
spec:
    replicas: 1
    template:
        metadata:
            labels:
                app: second-app
        spec:
            containers:
                - name: second-node-app
                  image: nginx:alpine
```

we can use whatever key-value pair in the labels. we don't need to specify the kind inside the template. 

and now we need to apply that deployment to the cluster
```sh
kubectl apply -f=deployment.yaml 
```
but this doesn't work, because we are missing the selector.

#### Working with Labels & Selectors
when we tried running the file before, we failed because we were missing a selector. a selector works together with labels, there are different types, matching labels and matching expressions. we will use matching labels. the selector requires the objects to have all the matching labels.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: test-app-2
spec:
    replicas: 1
    selector:
        matchLabels:
            app: second-app
            tier: backend
    template:
        metadata:
            labels:
                app: second-app
                tier: backend
        spec:
            containers:
                - name: second-node-app
                  image: nginx:alpine
```

we can now try running this
```sh
kubectl apply -f first_k8s_deployment.yaml 
```
and now things seem ok. we can get the pods or the deployment, and if we want to change something, we can update the file and apply it again.

#### Creating a Service Declaratively
our app still isn't working, because we don't have a service yet, so we need another yaml file.

the selector is a bit different for the service, we don't have to specify the options, as we only have the ability to match labels. we can choose to use just one of the labels.

we also add the ports, and the type of the service.
```yaml
apiVersion: core/v1
kind: Service
metadata:
    name: backend
spec:
    selector:
        app: second-app
    ports:
        - protocol: 'TCP'
          port: 80 #external
          targetPort: 80 #inside the container
    type: LoadBalancer
```
now we apply the configuration and expose the service with minikube to get the address
```sh
kubectl apply --filename first_k8s_service.yaml
kubectl get services
minikube service backend
```

#### Updating & Deleting Resources

with the declarative approach, when we want to change the configuration, we simply change the file and apply the file again. no need to type `kubectl` commands.

if we want to delete a deployment, we can do this imperatively as before, but we can also use the file to delete the resources created by it.

```sh
kubectl delete deployment test-app-2
kubectl delete -f first_k8s_deployment.yaml
```

#### Multiple vs Single Config Files

we can use multiple files like before, or have everything defined in the same file. we simply separate the resources with three dashes (---). 
```yaml
# first resource

# apiVersion: v1
# kind: Service
# metadata:
#     name: backend
# spec:
---
# second resource

# apiVersion: apps/v1
# kind: Deployment
# metadata:
#     name: test-app-2
# spec:
```

if we use the same file for deployment and services, then it's considered the best practice to put the service at the top.

#### More on Labels & Selectors

selectors are really important, they are how we connect resources to one another. we have selector to match labels or match expressions.

matching expressions is a more complex way, we again need to match all expressions, we can have multiple values, use inclusion or exclusion, etc...
```yaml
selector:
    matchExpressions:
    - {key: app, operator: In, values: [second-app, first-app]}
```

a deployment always needs to match the pods it creates.

we can also use selector when using the imperative approach. we first add labels to the service and deployment files under the metadata rootkey, and now we can use the *--selector, -l* flag with key=value to choose target, we can specify which kinds of resources to delete as well, this will protect us from making mistakes.

```sh
kubectl apply -f first_k8s_deployment.yaml, first_k8s_service.yaml
kubectl get all -l group=example
kubectl delete deployment --selector group=example 
kubectl get all -l group
kubectl delete deployment,services --selector group=example 
```

#### Liveness Probes

when we have a pod running, it checks the state of the container occasionally, this is also something which we can control. this is done with the "livenessProbe" key.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: test-app-2
    labels:
        group: example
spec:
    replicas: 3
    selector:
        matchLabels:
            app: second-app
            tier: backend
    template:
        metadata:
            labels:
                app: second-app
                tier: backend
        spec:
            containers:
                - name: second-node-app
                  image: nginx:alpine
                  livenessProbe:
                    httpGet:
                        path: /
                        port: 8080
                        #httpHeader:
                    periodSeconds: 3
                    initialDelaySeconds: 5
```

#### A Closer Look at the Configuration Options

there are many, many,many things to configure in kubernetes, everything we can configure in `docker container run` we can define here. 

also, if we configure the image tag to be the latest, then the new image will always be used. we can set and "imagePullPolicy", which acts like the *--pull* flag when running containers.

#### Summary

we used minikube to run local cluster, we first used imperative style, and later used declarative style. we used kubectl to create resources, list them, and delete, and with looked at the yaml files.

we also saw the service types: clusterIP, nodePort and LoadBalancer, and we looked at how selectors work.

</details>


### Managing Data & Volumes With Kubernetes

<details>
<summary>
Storing Data across runs with volumes and persistent data.
</summary>

even if we deploy on the cloud, we still have the same problems as we had with local deployment.
we still want persistent data, so we need to bring volumes to the cloud.

#### Starting Project & What We Know Already

we have a example project in the "kub-data-01-starting-setup" folder. we have two entry point, `GET` and `POST` to "/story". the data should survive across deployments.
we can test this app locally with docker compose
```sh
cd kub-data-01-starting-setup
docker-compose up -d --build
```

and now we can test this with postman or with a local tool (curl)
```sh
curl --location --request POST 'localhost/story' \
--header 'Content-Type: application/json' \
--data-raw '{
    "text": "my text11"
}'
curl --location --request GET 'localhost/story'
Invoke-RestMethod 'localhost/story' -Method 'GET' -Headers $headers | ConvertTo-Json 
```
we can stop and restart the app and the data will still be there, because we are using volumes.

```sh
docker-compose down
docker-compose up -d
curl --location --request GET 'localhost/story'
```
if we want to remove the data, we need to remove the volume itself
```sh
docker volume ls
docker volume rm kub-data-01-starting-setup_stories
```
now we would want to use the same thing on remote deployment

#### Kubernetes & Volumes - More Than Docker Volumes

there is a term that we use sometimes "state", this refers to data that is created and used by the application and shouldn't be lost.
the data can be 'persistent' or intermediate data, we want this data to remain even if the container is removed. persistent data should be stored in a database (such as user generated data), but also intermediate might need to consist.

in the kubernetes world, we still need the data. so we still need volumes and some way to retain the data. so we need to configure kubernetes to run the containers with the appropriate volumes.


#### Kubernetes Volumes: Theory & Docker Comparison

luckily, kubernetes can mount volumes onto containers, just like local docker, kubernetes supports a wide variety of volume types and drivers: like "local" volumes (which live on the nodes), or cloud-vendor specific volumes. the lifetime of the volume is linked to the **pods** lifetime. it survives containers removal and restarts, but not pod actions.

kubernetes volume are similar but different from docker volumes, we have more support for storage and driver types, it's more flexible.

<> | Docker Volume | Kubernetes Volume
----|---------|---
Driver and type support | Basically no driver / Type support | Supports many different drivers and types
Volumes persistency | Volume persist until manually cleared | Volumes are not necessarily persistent
Volume Lifetime | Volumes survive Container restarts and removals | Volumes survive Container restarts and removals

#### Creating a New Deployment & Service

lets do this step by step, we need to make this into a deployment.

we need a deployment and service yaml files, lets start writing them, just as before.

**deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: story-deployment
spec:
    replicas: 1
    selector:
        matchLabels:
            app: story
    template:
        metadata:
            labels:
                app: story
        spec:
            containers:
                - name: story
                  image: benjaminshinar/kub-data-demo
```
**service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
    name: story-service
spec:
    selector:
        app: story
    ports:
        - protocol: 'TCP'
          port: 80 #external
          targetPort: 3000 #inside the container
    type: LoadBalancer
```

but we first need to push the image to the docker repository.

```sh
docker login
docker image build -t benjaminshinar/kub-data-demo . 
docker image tag benjaminshinar/kub-data-demo benjaminshinar/kub-data-demo:0.1
docker image push benjaminshinar/kub-data-demo:0.1
```

and lets see if it works
```sh
minikube status
minikube start --driver=docker
minikube status
#in new terminal
minikube dashboard

kubectl apply -f service.yaml -f deployment.yaml
kubectl get deployment
#expose
minikube service story-service

```
now that we have the url, we can use it in postman and get a valid response.

#### Getting Started with Kubernetes Volumes

the problem is that the data isn't persistent. if we can crush the pods, then we will lose the data. to fix this, we need to somehow use volumes. kubernetes supports a variety of volume types and drivers. not just local storage on the nodes, we also have cloud vendor specific storage.

we will look at three types, **emptyDir**,**hostPath** and **CSI**, all these types don't change how the volume works inside the container, but they dictate how the data is stored outside the container.

[volume types](https://kubernetes.io/docs/concepts/storage/volumes/)

#### A First Volume: The "emptyDir" Type

the volume life time depends on the pod, not the container.

```sh
Invoke-RestMethod 'http://127.0.0.1:50261/story' -Method 'GET' -Headers $headers | convertTo-Json
#delete pod
kubectl get pods
kubectl delete pods <pod name>

#wait for kubernetes to redeploy the pod
kubectl get pods

# check again, now the data is gone
Invoke-RestMethod 'http://127.0.0.1:50261/story' -Method 'GET' -Headers $headers | convertTo-Json
```

we have to define the volumes in the same place we define the pods.
we will also add an error route that crushes the app for us

```js
app.get('/error',()=>{
    process.exit(1);
});
```

we can rebuild the image with the new code, specify the tag in the deployment file and apply to get this running
```sh
docker image build -t benjaminshinar/kub-data-demo:0.2 -t benjaminshinar/kub-data-demo .
docker image push benjaminshinar/kub-data-demo
docker image push benjaminshinar/kub-data-demo:0.2 
kubectl apply -f .deployment.yaml
```
now we can make request to the "/error" path and crush the app, which makes us lose the data! the container restarted, but not the pod.

we can try fixing this by adding the volume in the deployment spec, an *emptyDir* (empty directory) that remains in the pod, and outlives containers. we also define the *volumeMounts* key in the container objects

**deployment.yaml**
```yaml
        spec:
            containers:
                - name: story
                  image: benjaminshinar/kub-data-demo:0.2
                  volumeMounts:
                    - mountPath: /app/story #internal
                      name: story-volume #what volume we use.
            volumes:
                - name: story-volume
                  emptyDir: {}
```
we can try this again and see if the data survives! but we first get an "file doesn't exist". we can do a post request to create the data and then things work.


#### A Second Volume: The "hostPath" Type

the emptyDir is valid way, but what if we have two replicas? if one pod fails then stuff doesn't work. the "hostPath" type host the data on the machine, rather than on the pod. this is more similar to a bindMount.

we provide a path on the host machine (the node) and how to access it.

**deployment.yaml**
```yaml
        spec:
            containers:
                - name: story
                  image: benjaminshinar/kub-data-demo:0.2
                  volumeMounts:
                    - mountPath: /app/story #internal
                      name: story-host-path-volume #what volume we use.
            volumes:
                - name: story-volume
                  emptyDir: {}
                - name: story-host-path-volume
                  hostPath:
                    path: /data #path on the host machine
                    type: DirectoryOrCreate
```

again this fails until we start writing, but if we crush one pod, we can still get the data from the other pods, because they all share the same data inside the host machine.

when we run this locally, we really have one worker node, but in real deployment, we have many remote machines, so the data won't really be shared between replicas. ths volume is also useful if we want to use existing data.

#### Understanding the "CSI" Volume Type

another type of volume is CSI - Container Storage Interface, this type is very flexible, it is a late addition to kubernetes, which was done to provide a single entry point for volumes without requiring more specific types to be added.

we can add any storage solution directly. it just needs to have a compatible CSI interface. we won't use it here, but later on in the course.

#### From Volumes to Persistent Volumes

so far we used volumes that follow the lifetime of the pod or the machine. we need something that outlives pods and nodes, like a database container or files. some data must persist across time.

kubernetes has **persistent volumes**, which are pod and nodes independent.
some of the volumes builtin already give us volume persistency because the data is stored somewhere else. but the Persistent volumes are declared to be such and have some more characteristics, they are detached from the pods and nodes, and the are supervised as part of the cluster, and we can use them from any resource with defining them again.

persistent volumes are entities in the cluster, independent from the nodes and pods, the nodes hold PV claims that give them access to the volumes, but they don't own the volumes and the data is stored outside of the nodes.

if we look at the time of persistent volumes, we see that emptyDir is missing and HostPath is noted to be suited only for testing. we see a lot of cloud storage options and the CSI type again.

#### Defining a Persistent Volume

again, we will use HostPath as an example for a persistent volume, even if we won't use it in the read world. we need a new configuration file, with some other stuff defined.

volume mode: filesystem  vs block\
accessMode: we can define more than one, and then decide when we claim it
- ReadWriteOnce - can be mounted by one node, and be used all the pods in it.
- ReadOnlyMany - readonly, but can be used by multiple nodes
- ReadWriteMany - read and write, can be used by all nodes.
  
**host-pv.yaml**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
    name: story-host-pv
spec:
    capacity:
        storage: 4Gi
    volumeMode: Filesystem #or Block
    accessMode: 
        - ReadWriteOnce
        #- ReadOnlyMany
        #- ReadWriteMany
    hostPath:
        path: /data
        type: DirectoryOrCreate
```

now we defined it the volume, but we need to claim it.

#### Creating a Persistent Volume Claim

the volume is defined in the cluster, but in order to use we need to add a claim, which is another deployment file, and the type is **PersistentVolumeClaim**.


we usually claim volumes by name, but there are additional ways to do so.

**host-pvc.yaml**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: story-host-pvc
spec:
    volumeName: story-host-pv
    accessModes:
        - ReadWriteOnce
    resources:
        requests:
            storage: 1Gi
```

now we need to connect our pods to the claim
```yaml
            volumes:
                - name: story-volume
                  emptyDir: {}
                - name: story-host-path-volume
                  hostPath:
                    path: /data #path on the host machine
                    type: DirectoryOrCreate
                - name: story-host-pv-volume
                  persistentVolumeClaim:
                    claimName: story-host-pvc
```


matching fields: | Persistent Volume | Persistent Volume Claim
------------|------------|--------
name   | metadata:name| spec:volumeName:
access modes | spec:accessModes|spec:accessModes
storage | spec:capacity:storage: | spec:resources:requests:storage

#### Using a Claim in a Pod

before using, we need to define the storage class, which is part of the cluster, and we need to use it, so we add the key `storageClassName: standard` to the persistentVolume and the persistentVolumeClaim resources.

```sh
kubectl get sc
```

now we can try this, we need to apply everything.
```sh
kubectl apply -f service.yaml -f host-pv.yaml -f host-pvc.yaml -f deployment.yaml
kubectl get pv,pvc
```

we won't see a difference, because we already had everything on one single node. but if we had other resources, they could also get the data.

we talked about state earlier, where we had data was meant to be stored and intermediate data. we usually store intermediate data in pod volumes, and the data that is important should go in the volumes and persistent volumes.

#### Volumes vs Persistent Volumes

comparing the two types of volumes. both allow us to persist data over the application, "normal" volumes are independent of containers, but are attached to the pod, so data might be lost if the pod is removed. they are part of the definition of the pods/containers. the problem is that pod specific volumes might be reparative in terms of definitions.

persistent are defined once and used multiple times.

#### Using Environment Variables

now we also look at environment variables, as we had before, we might want to pass variables to the container.

we first replace the folder name in the code, 
```js
//const filePath = path.join(__dirname, 'story', 'text.txt');
const filePath = path.join(__dirname, process.env.STORY_FOLDER, 'text.txt');
```


and we add the "env" key in the container definitions
```yaml
        spec:
            containers:
                - name: story
                  image: benjaminshinar/kub-data-demo:latest
                  env:
                    - name: STORY_FOLDER
                      value: 'story'
                  volumeMounts:
                    - mountPath: /app/story #internal
                      name: story-host-path-volume #what volume we use.
```
and of course, we push the updated image.
```sh
docker image build -t benjaminshinar/kub-data-demo:0.3 -t benjaminshinar/kub-data-demo .
docker image push benjaminshinar/kub-data-demo
docker image push benjaminshinar/kub-data-demo:0.3
kubectl apply -f deployment.yaml
```

#### Environment Variables & ConfigMaps

but we can also keep the environment variables somewhere else, and not define them again and again for each resource. we can have new configuration file

**environment.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: data-store-env
data:
    folder: 'story'
    #key: value
```

and we can apply it
```
kubectl apply -f environment.yaml
kubectl get configmap
```

and in the deployment configuration, we take the value from a resource
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: story-deployment
spec:
    replicas: 2
    selector:
        matchLabels:
            app: story
    template:
        metadata:
            labels:
                app: story
        spec:
            containers:
                - name: story
                  image: benjaminshinar/kub-data-demo:latest
                  env:
                     - name: STORY_FOLDER
                  #     value: 'story'
                        valueFrom:
                            configMapKeyRef: 
                                name: data-store-env
                                key: folder #the key in the config map
```

and apply the deployment....

#### Module Summary

we learned about data, volumes and persistent data, we also looked at many more resources and how to define them.
</details>


### Kubernetes Networking

<details>
<summary>
Networking and communication between pods
</summary>

containers in kubernetes should be able to communicate with one another and with the outer world. this will be done by using services, we will also examine pod-internal communication and pod-to-pod 

#### Starting Project & Our Goal
we have another application for this lesson, located at folder "kub-network". a 'to-do tasks' application with three parts: authentication API, Users API and Tasks API.

the auth api and the user api will be inside the same pod (for now), and the tasks API will be in a different pod. both pods will be reachable from the outside world. but the auth container won't accessible.

we can start playing with it locally.

```sh
docker compose up -d
```

and then use postman, first to the log-in, then we can post and get task, we just need to make sure to have the 'tasks' folder created either, in code or in the docker file or docker-compose.

#### Creating a First Deployment

moving everything to the cloud.

we first used the users.app, and we need to change some stuff to make this work without any other services

```js
    //const hashedPW = await axios.get('http://auth/hashed-password/' + password);
    const hashedPW = 'dummy text'
///
//  const response = await axios.get(    'http://auth/token/' + hashedPassword + '/' + password  );
const response = { status:200,data:{token:'abc'}};
```

now we need to build  a repository on dockerhub and push the image.
```sh
docker-compose build
docker login  
docker image tag kub-network_users benjaminshinar/kub-network_users
docker image tag kub-network_users benjaminshinar/kub-network_users:0.1
docker image push benjaminshinar/kub-network_users
docker image push benjaminshinar/kub-network_users:0.1
```

and the next thing will be to create a deployment file

**users-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: users-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: users 
    template:
        metadata:
            labels:
                app: users
        spec:
            containers:
            - name: users
              image: benjaminshinar/kub-network_users:0.1
```
and we will now apply this

```sh
kubectl apply -f kubernetes/users-deployment.yaml
```

we will now be able to see this in the dashboard.

#### Another Look at Services

now we want a service, because we want to able to reach the users api from the outside world.
services give us a stable address, that doesn't change if the pos is removed or changed. and the service also gives us someway to interact with the pods from the outside world.

we need to define the type as either ClusterIP, NodePort or LoadBalancer.

- ClusterIP gives inner communication and some internal balancing,
- NodePort gives a stable IP address
- LoadBalancer uses a load balancer for outside communications

**users-service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
    name: users-service
spec:
    selector:
        app: users
    type: LoadBalancer
    ports:
        - protocol: TCP
          port: 8080
          targetPort: 8080
```

we now apply the service, and give us access from minikube
```sh
kubectl apply -f kubernetes/users-service.yaml   
minikube service users-service
```

and now we use postman to try to login and sign-up.

now we can say that our application was started from minikube.

now we want a pod internal communication.

#### Multiple Containers in One Pod

now we we need to edit the code back in the users-app.js file to use the original behavior. we also want to use environment variables

```js
    //const hashedPW = await axios.get('http://auth/hashed-password/' + password);
    const hashedPW = 'dummy text'
    const hashedPW = await axios.get(`http://${process.env.AUTH_ADDRESS}/hashed-password/` + password);
///
//  const response = await axios.get('http://auth/token/' + hashedPassword + '/' + password  );
//const response = { status:200,data:{token:'abc'}};
    const response = await axios.get(`http://${process.env.AUTH_ADDRESS}/token/` + hashedPassword + '/' + password  );
```

we update the docker compose file to allow local usage,

**docker-Compose.yaml:**
```yaml
version: "3"
services:
  auth:
    build: ./auth-api
  users:
    build: ./users-api
    ports: 
      - "8080:8080"
    environment:
      AUTH_ADDRESS: auth
  tasks:
    build: ./tasks-api
    ports: 
      - "8000:8000"
    environment:
      TASKS_FOLDER: tasks
    volumes:
      - /app/tasks
```

and for kubernetes usage, we will need something else.

but we first need to build the auth image an push it
```sh
docker-compose build
docker image tag kub-network_auth benjaminshinar/kub-network_auth
docker image tag kub-network_auth benjaminshinar/kub-network_auth:0.1

docker image tag kub-network_users benjaminshinar/kub-network_users:0.2
docker image push benjaminshinar/kub-network_auth
docker image push benjaminshinar/kub-network_auth:0.1
docker image push benjaminshinar/kub-network_users:0.2
```

and now we need to use it, and for now we want to create it in the same deployment as our users app

**users-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: users-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: users 
    template:
        metadata:
            labels:
                app: users
        spec:
            containers:
            - name: users
              image: benjaminshinar/kub-network_users:0.2
            - name: auth
              image: benjaminshinar/kub-network_auth:0.1
```
we don't expose the port (80) to the outside world in the services file.

#### Pod-internal Communication

when containers are running on the same pod, we can use "localhost" to communicate between containers, so we need to provide the environment variables:

**users-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: users-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: users 
    template:
        metadata:
            labels:
                app: users
        spec:
            containers:
            - name: users
              image: benjaminshinar/kub-network_users:0.2
              env:
              - name: AUTH_ADDRESS
                value: localhost
            - name: auth
              image: benjaminshinar/kub-network_auth:0.1
```

this should work properly, the docker-compose files passes the service name, while the deployment yaml passes the 'localhost'. we can use postman to send "signUp" and "login" requests.

#### Creating Multiple Deployments

the next thing we want is the task API, and we would want to ensure that the task api can talk to the authentication api, so we should now separated the authentication api to a third pod, and we need service that is reachable from the pods, but not from the outside world.

we need a new deployment for the auth api, which separates them into different pods.

**auth-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: auth-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: auth 
    template:
        metadata:
            labels:
                app: auth
        spec:
            containers:
            - name: auth
              image: benjaminshinar/kub-network_auth:0.1
```

we also need a new service, we don't need an exposed port, so we use ClusterIP

**auth-service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
    name: auth-service
spec:
    selector:
        app: auth
    type: ClusterIP
    ports:
        - protocol: TCP
          port: 80
          targetPort: 80
```

and we change the value of the environment variables from 'localhost' to something else.

#### Pod-to-Pod Communication with IP Addresses & Environment Variables

we can get the ip of the service and use it as an environment variable:
```sh
kubectl get service
```
but this is a manual process, and there is more connivent way. kubernetes actually generates those for us. the format is the service name (all caps), then the `SERVICE_HOST` to get the ip.


```js
    //const hashedPW = await axios.get('http://auth/hashed-password/' + password);
    //const hashedPW = 'dummy text'
    //const hashedPW = await axios.get(`http://${process.env.AUTH_ADDRESS}/hashed-password/` + password);
    const hashedPW = await axios.get(`http://${process.env.AUTH_SERVICE_SERVICE_HOST}/hashed-password/` + password);
///
//  const response = await axios.get('http://auth/token/' + hashedPassword + '/' + password  );
//const response = { status:200,data:{token:'abc'}};
    // const response = await axios.get(`http://${process.env.AUTH_ADDRESS}/token/` + hashedPassword + '/' + password  );
    const response = await axios.get(`http://${process.env.AUTH_SERVICE_SERVICE_HOST}/token/` + hashedPassword + '/' + password  );
```

this hurts us when we want to use docker-compose, we would have to add the exact name to file.

```sh
docker-compose build 
docker image tag kub-network_users benjaminshinar/kub-network_users:
docker image tag kub-network_users benjaminshinar/kub-network_users:0.3
docker image push benjaminshinar/kub-network_users
docker image push benjaminshinar/kub-network_users:0.3

kubectl apply -f kubernetes/users-deployment.yaml -f kubernetes/users-service.yaml -f kubernetes/auth-deployment.yaml -f kubernetes/auth-service.yaml
```

#### Using DNS for Pod-to-Pod Communication

the automatically generated environment variables are useful, but there is even something better, CoreDNS. it also uses the service name, just like what we had with docker-compose.

```js
    //const hashedPW = await axios.get('http://auth/hashed-password/' + password);
    //const hashedPW = 'dummy text'
    //const hashedPW = await axios.get(`http://${process.env.AUTH_ADDRESS}/hashed-password/` + password);
//    const hashedPW = await axios.get(`http://${process.env.AUTH_SERVICE_SERVICE_HOST}/hashed-password/` + password);
    const hashedPW = await axios.get(`http://${process.env.AUTH_ADDRESS}/hashed-password/` + password);
///
//  const response = await axios.get('http://auth/token/' + hashedPassword + '/' + password  );
//const response = { status:200,data:{token:'abc'}};
    // const response = await axios.get(`http://${process.env.AUTH_ADDRESS}/token/` + hashedPassword + '/' + password  );
    //const response = await axios.get(`http://${process.env.AUTH_SERVICE_SERVICE_HOST}/token/` + hashedPassword + '/' + password  );
    const response = await axios.get(`http://${process.env.AUTH_ADDRESS}/token/` + hashedPassword + '/' + password  );
```
the exact format is "\<service name>" + "." + "\<namespace>"

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: users-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: users 
    template:
        metadata:
            labels:
                app: users
        spec:
            containers:
            - name: users
              image: benjaminshinar/kub-network_users:0.4
              env:
              - name: AUTH_ADDRESS
                value: "auth-service.default"
```

#### Which Approach Is Best? And a Challenge!

this of course depends on whether the containers belong in the same pods or not.

if they are, then we can use 'localhost'.

if not, we must have a service, and we can either use the environment variables auto-generated or the CoreDNS name.

now we should create the task app, which should run on it's own pod, connect to the auth API and receive outside requests.

**tasks-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: tasks-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: tasks 
    template:
        metadata:
            labels:
                app: tasks
        spec:
            containers:
            - name: tasks
              image: benjaminshinar/kub-network_tasks:0.1
              env:
              - name: AUTH_ADDRESS
                value: "auth-service.default"
              - name: TASKS_FOLDER
                value: tasks
            
```

**tasks-service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
    name: tasks-service
spec:
    selector:
        app: tasks
    type: LoadBalancer
    ports:
        - protocol: TCP
          port: 8000
          targetPort: 8000
```

build and push the image, then apply and check with postman
```sh
docker compose build
docker image tag kub-network_tasks benjaminshinar/kub-network_tasks
docker image tag kub-network_tasks benjaminshinar/kub-network_tasks:0.1
docker image push benjaminshinar/kub-network_tasks
docker image push benjaminshinar/kub-network_tasks:0.1

kubectl apply -f kubernetes/users-deployment.yaml -f kubernetes/users-service.yaml -f kubernetes/auth-deployment.yaml -f kubernetes/auth-service.yaml -f kubernetes/tasks-deployment.yaml -f kubernetes/tasks-service.yaml

minikube service tasks-service
```

we need to provide the authorization header key,

#### Challenge Solution

we need to change the `GET` request that talks to the authentication api, we use an environment variable, we add it to the docker-compost file.

we then create a 'tasks-deployment.yaml' and 'tasks-service.yaml' file, we need port 8000 and to use 'LoadBalancer' as the type.


#### Adding a Containerized Frontend

next we want to add a frontend, inside the "frontend" folder. it is built in react. this will allow us to test directly without using postman.

we have function that use 'fetch to grab stuff. we have a multistage build setup, because react app require a build.

we can change the url to what we used in postman, add to docker-compose, build the image and try it locally.

**docker-compose.yaml:**
```yaml
version: "3"
services:
  auth:
    build: ./auth-api
  users:
    build: ./users-api
    ports: 
      - "8080:8080"
    environment:
      AUTH_ADDRESS: auth
  tasks:
    build: ./tasks-api
    ports: 
      - "8000:8000"
    environment:
      TASKS_FOLDER: tasks
      AUTH_ADDRESS: auth
    volumes:
      - /app/tasks
  frontend:
    build: ./frontend
    ports:
        - "80:80"
```

we now have a CORS (cross origin resource sharing) violation. we need to somehow fix this. we need to update the tasks-api code and add a some headers.

```js
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  next();
})
```
so now we have to rebuild the image and push it...

```sh
docker compose build
docker image tag kub-network_tasks benjaminshinar/kub-network_tasks
docker image tag kub-network_tasks benjaminshinar/kub-network_tasks:0.2
docker image push benjaminshinar/kub-network_tasks
docker image push benjaminshinar/kub-network_tasks:0.2

kubectl apply -f kubernetes/users-deployment.yaml -f kubernetes/users-service.yaml -f kubernetes/auth-deployment.yaml -f kubernetes/auth-service.yaml -f kubernetes/tasks-deployment.yaml -f kubernetes/tasks-service.yaml
```

now we should see things crushing because of authorization issues. we add the options object to the fetch request with the 'authorization' header.

```js
  const fetchTasks = useCallback(function () {
    fetch(str, {
      headers: {
        'Authorization': 'Bearer abc'
      }
    })
```

(this didn't work for me)

but what if we want to host the code on the cloud?

#### Deploying the Frontend with Kubernetes

we want our react application to run on the cloud
we want a new pod, so that means a new deployment file

**frontend-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: frontend-deployment
spec: 
    replicas: 1
    selector:
        matchLabels:
            app: frontend 
    template:
        metadata:
            labels:
                app: frontend
        spec:
            containers:
            - name: frontend
              image: benjaminshinar/kub-network_frontend:0.1
```
and a service file

**frontend-service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
    name: frontend-service
spec:
    selector:
        app: frontend
    type: LoadBalancer
    ports:
        - protocol: TCP
          port: 80
          targetPort: 80
```

we build and push the image before using it.

```sh
docker compose build
docker image tag kub-network_frontend benjaminshinar/kub-network_frontend
docker image tag kub-network_frontend benjaminshinar/kub-network_frontend:0.1
docker image push benjaminshinar/kub-network_frontend
docker image push benjaminshinar/kub-network_frontend:0.1

kubectl apply -f kubernetes/users-deployment.yaml -f kubernetes/users-service.yaml -f kubernetes/auth-deployment.yaml -f kubernetes/auth-service.yaml -f kubernetes/tasks-deployment.yaml -f kubernetes/tasks-service.yaml -f kubernetes/frontend-deployment.yaml -f kubernetes/frontend-service.yaml

minikube service frontend-service
```


we don't want to hard code the address, even though it usually works.

#### Using a Reverse Proxy for the Frontend

we can avoid hard-coding with a 'reverse proxy'. we want to send the request to the same service that services the application, which is ourselves. we do this by fixing the the nginx.conf file. we set a rule that controls what happens to requests that target a certain access point

```
server {
  listen 80;
  
  # this is new
  location /api {
      proxy_pass http://127.0.0.1:63764;
  }

  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    try_files $uri $uri/ /index.html =404;
  }
  
  include /etc/nginx/extra-conf.d/*.conf;
}
```

and we change the fetch code again...

```js
  const fetchTasks = useCallback(function () {
    fetch('/api/tasks', {
      headers: {
          ///....
```
remove the old deployment

```sh
kubectl delete -f kubernetes/frontend-deployment.yaml
```

still not working, because the configuration runs on the server, not on the computer running the browser. so we use the core DNS stuff to use the domain name.

don't forget the trailing slashes and the port
```
server {
  listen 80;
  
  # this is new
  location /api/ {
      proxy_pass http://tasks-service.default:8000/;
  }

  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    try_files $uri $uri/ /index.html =404;
  }
  
  include /etc/nginx/extra-conf.d/*.conf;
}
```

now things should work.

#### Module Summary

we looked at containers and pods communicating, between pods in the same containers, between the outside world and the pods, and between containers in different pods. we practiced yaml files and discovered some automatically generated configurations to get the services.

</details>

### Kubernetes - Deployment (AWS EKS)

<details>
<summary>
Running Kubernetes on AWS EKS.
</summary>

in this section we will deploy kubernetes to a real remote machine, which means AWS. not just with minikube.

#### Deployment Options & Steps

> What kubernetes will do:
> - Create your objects (e.g. Pods) and manage them
> - Monitor Pods and re-create them, scale Pods, etc
> - Kubernetes utilizes the provided (cloud) resources to apply your configuration/goals
>  
> What you need to do/setup (i.e. what kubernetes requires)
> - Create the cluster and the node instances
> - Setup API Server, kubelet and other kubernetes services/software on nodes.
> - Create other (cloud) provider services that might be needed (e.g. Load Balancer, FileSystems)

minikube is a dummy cluster that we can use locally. but now we want to play with a real thing. we must choose between using a custom data center and using a cloud provider.

custom data center requires us to install and configure everything on our own, that includes the kubernetes software.

if we go with a cloud provider, we can use low-level resources to create a cluster, that means we get remote machines, but we are responsible to install and setup everything kubernetes, this can be done manually or with a tool such as Kops.\
we can also use a managed service, where the cloud provider sets everything for us, and we can start right away.

#### AWS EKS vs AWS ECS

> AWS ECS: elastic **Containers** Service. managed service for container deployment,Aws-specific syntax and philosophy applies. use AWS-specific configuration and concepts.
> 
> AWS EKS: elastic **Kubernetes** Service. managed service for kubernetes deployment. No AWS-specific syntax or philosophy required, use standard kubernetes configuration and resources.


#### Preparing the Starting Project

as usual, we need a project to work with, under the folder "kub-deploy". it has two parts, auth-api and users-api, as well as docker-compose and kubernetes configuration files (each with a service and deployment).

we need to adjust some stuff if we want to follow along, like a mongodb atlas url. we need to create one of our own and then update the connection string in the docker-compose and the deployment configuration files.

```yaml
      MONGODB_CONNECTION_URI: 'mongodb+srv://maximilian-doublecolons-wk4nFupsbntPbB3l@cluster0.ntrwp.mongodb.net/users?retryWrites=true&w=majority'
```

we also need to change the images in the kubernetes deployment and push them to our personal registry.

```sh
docker-compose build .
docker login
docker image tag kub-deploy_users benjaminshinar/kub-deploy_users:0.1
docker image tag kub-deploy_auth benjaminshinar/kub-deploy_auth:0.1
docker image push benjaminshinar/kub-deploy_users:0.1
docker image push benjaminshinar/kub-deploy_auth:0.1
```

we can also play with it locally on minikube.

#### Diving Into AWS

AWS is used only as an example. other cloud providers also have kubernetes support, such as AKS (Azure Kubernetes service) from microsoft. we

#### Creating & Configuring the Kubernetes Cluster with EKS

we start by adding a cluster, we give it a name, decide on the kubernetes version, and the cluster service role. this controls permissions, and uses a different AWS service, called IAM (Identity and Access Management). we might create a role for eks.\
we now specify the network, we need to provide access from the outside world, we can search for **cloud formation** and then <kbd>create stack</kbd>, we gran the link from this [page](https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html#create-vpc) as a template for our network. we simple give the stack a name (no need for anything else). with the stack created, we use it as the VPC in out networking page. for <kbd>cluster endpoint access</kbd>, we choose *public and private*.\
there isn't much to do for now in the logging tab, so we leave them as they were,and we create the cluster.

we take a small break while the cluster is being created.

#### Configuring Kubectl To talk with AWS
we currently have kubectl configured on the minikube, when we write `kubectl`, it's actually being directed at minikube. so we need to go the user files, the hidden folder "*.kube*", the file *config*.

```sh
cd ~
ls 
cd .kube
# use any editor available
code config
```

if we have minikube running, the file will have all sorts of data. which will be gone once we 'minikube delete`

we need to override this file to direct kubectl commands to the AWS, we first create a backup the of the file, and then use the [AWS CLI](https://aws.amazon.com/cli/) tool to configure the command line to work with AWS. once installed, we need to enable the use of it from aws.
><kbd>Account</kbd> - > "<kbd>My Security / Credentials</kbd> - > <kbd>Access Keys</kbd> - > <kbd>Create New Access Key</kbd> (download).

now that we have the file, we run `aws configure` and use the key and secret key values from the file. we provide a region name.

once the cluster is active we can enter the command to update the configuration file and make it talk with aws.

```sh
aws eks --region <region> update-kubeconfig --name <cluster name>
```
#### Adding Worker Nodes

now we need to add the nodes. on the cluster, we go to <kbd>Compute</kbd> tab, and then click on <kbd>Add Node Group</kbd>, we give the node group a name, and choose a <kbd>node IAM role</kbd>. we open the IAM console and create a new role, we need the following permissions:
- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- AmazonEC2ContainerRegistryReadOnly

with this role created, we can use it for the node group.
under the <kbd>Set compute and scaling configuration</kbd> and we choose *t3.small* as <kbd>instance type</kbd>, we can also specify the scaling configuration. this is scaling in terms of nodes, not pods. in minikube we had only one node, but cloud providers can give us more than a single work node.

we finish up with the networks and start running the pods, EKS will not only launch the nodes, it will also install the required kubernetes software and add them to the same network.

we can look at our instances from EC2 dashboard, we currently don't have any load balancers.

#### Applying Our Kubernetes Config

now we can start. our cluster is up, the `kubectl` command is configured to work against AWS.

```sh
cd kubernetes
kubectl apply -f auth.yaml -f users.yaml
kubectl get deployments
kubectl get services
```
when we look at the services, the External-IP column is not pending like it was with minikube, it's showing a real address, we don't need `minikube service` to get a functioning ip address. we can use this for postman like before. we sign up, then login, and we get actual responses.

we now can see a load balancer on the instances page, which was created by kubernetes.

we can now change the deployment files (increase replicas) and apply the file again and see how the pods are being created.

#### Getting Started with Volumes

the application is running, we already covered volumes when we used minikube, we looked at *emptyDir* and *hostPath*, but also mentioned *csi* without diving into it. now we finally get to use it.

the code currently doesn't write files, but if it was, we would have needed volumes to make the data persistent.

in the local world, we would add a volume into the docker-compose file. in kubernetes we can add a volume for each container, or use a persistent volume and persistent volume claims.

emptyDir creates a new directory for each pod, hostPath creates a path on the node, so we could share the same volume for pods on the same node, it the data outlived the pods lifecycle. however, this won't work for multi-node setup, we want all the pods to share data, regardless of which node they use.

the csi (container storage interface) is a standard interface the can connect to other services to give us volumes. we will use at AWS EFS (elastic file system)

#### Adding EFS as a Volume (with the CSI Volume Type)

our first task is to install the driver to the cluster, we look at the [github page](https://github.com/kubernetes-sigs/aws-efs-csi-driver) and find the command to install the plugin.

```sh
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"
```

next we need to create the volume storage, so we open EFS browser.
we also need an EC2 and to create a security group, we care about the vpc and the <kbd>inbound rules</kbd> *NFS* and a custom ip. back to efs
<kbd>Create file system</kbd>, choose the correct VPC, <kbd>customize</kbd>, the <kbd>network access</kbd> tab, replace the security groups with the one we created. we finish the creation and we have a file system to use as the volume.

#### Creating a Persistent Volume for EFS

we add a section in "users.yaml" to create a persistent volume. we should also create folder under users to ensure there is where to write the files.
we also need a storage class resource, which goes above the persistent volume resource. we copy it from the documentation.

```yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: efs-sc
provisioner: efs.csi.aws.com
---
apiVersion: v1
kind: PersistentVolume
metadata: 
    name: efs-pv
spec:
    capacity:
        storage: 5Gi
    volumeMode: Filesystem
    accessModes:
        - ReadWriteMany
    storageClassName: efs-sc
    csi:
        driver: efs.csi.aws.com
        volumeHandle: <file system id>
```
in aws efs, the capacity key doesn't matter actually, so we can write whatever. 

we also need to use the volume, so we fix open the **users.yaml** and add to the spec section a new key (under containers, same level). as well as a persistent volume claim.
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: efs-pvc
spec:
    accessModes:
        - ReadWriteMany
    storageClassName: efs-sc
    resources:
        requests:
            storage: 5Gi

```
we need to use this claim, and add volume Mounts to tell the containers where to store the files
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: users-deployment
spec:
    replicas: 1
    selector:
        matchLabels:
            app: users
template:
    metadata:
        labels:
            app: users
    spec:
        containers:
            - name: users-api
              image: benjaminshinar/kub-deploy_users:0.1
              env:
                - name: MONGODB_CONNECTION_URI
                  value: 'mongodb+srv://maximilian-doublecolons-wk4nFupsbntPbB3l@cluster0.ntrwp.mongodb.net/users?retryWrites=true&w=majority'
                - name: AUTH_API_ADDRESS
                  value: 'auth-service.default:3000'
              volumeMounts:
                - name: efs-vol
                  mountPath: /app/users
        volumes:
            - name: efs-vol
              persistentVolumeClaim:
              claimName: efs-pvc
```

#### Using the EFS Volume

with everything setup, we need to change the code in user-actions.js and user-routes.js to read and write files. we rebuild the image, and push it, and we can also use our new deployment.

we test this with postman, we create a user and login, and then get the logs from the "/logs" route. we can also look at the aws-efs dashboard and see the data being transferred and the client connection number. we can change the number of replicas to zero to destroy all pods, and then see that the data outlives the pods if we set the replicas back to 1.

we could use any volume type, the csi provides a standard interface for us to use

#### A Challenge!

now we practice with a new application, "kub-challenge", which we should create on our own and push to the cloud. it has a tasks application as well, so we need to set up a deployment. make sure it connects to the auth service and the database and that it has connection to the outside world.

tasks.yaml
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: tasks-service
spec:
  selector:
    app: tasks
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tasks-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tasks
  template:
    metadata:
      labels:
        app: tasks
    spec:
      containers:
        - name: tasks-api
          image: benjaminshinar/kub-challenge-tasks:latest
          env:
            - name: MONGODB_CONNECTION_URI
              value: 'mongodb+srv://maximilian-doublecolons-wk4nFupsbntPbB3l@cluster0.ntrwp.mongodb.net/users?retryWrites=true&w=majority'
            - name: AUTH_API_ADDRESS
              value: 'auth-service.default:3000'
```

(I can't do the aws parts)

#### Challenge Solution

we create the yaml file to hold the service and the deployment. we build it similar to the "users.yaml". the ports are "80:3000". 
we build and push the images (all of them are slightly different now) and apply our configurations.

we use postman to try to get the tasks, it first fails because we don't have an authentication service, which we get if we send a login request to the users application, we add the token to the header, and try again, we can also add tasks. everything will be stored in the mongo db. each user has it's own tasks.
we can also delete tasks, all via the capabilities we get from mongoDB.

</details>

### Round Up and Next Steps

<details>
<summary>
Summary of what we learned and what's ahead
</summary>

> - You know what docker is and why use it
> - Docker can used locally (development) and in production - you can do both or just one.
> - Docker = Images + Containers
> - Docker-compose helps with complex, multi-container projects, especially locally.
> - Kubernetes helps with multi-machine container orchestration and deployment

if we want to learn more, we can look into more topics, which we didn't go over.

> - using applications from other programming languages. not just nodejs, python and php. we would have different images setup.
> - CI-CD (continues integration, continues deployment). complex pipelines with external tools (jenkins, github, Travis).
> - deeper dive into AWS, other services and more detailed learning of the tools we used.
> - other cloud providers, google, amazon, etc...
> - advanced cluster or docker administration. the side of using docker that is less used by developers.

we can learn those topics and improve our skills:\
first by using docker and practicing it (putting it into use in real projects). we can learn from the official documentations of docker, kubernetes or the cloud provider. we can also look at stuff like *vs Code Docker Support* and see how docker is used in different ways.

</details>
