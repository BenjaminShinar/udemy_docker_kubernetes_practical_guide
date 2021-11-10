<!--
ignore these words in spell check for this file
// cSpell:ignore Kubermatic systeminfo USERPROFILE mkdir hyperv rootkey
-->

[Menu](../README.md)

## Kubernetes
(includes sections 11,12)

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

<!-- <details> -->
<summary>

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
