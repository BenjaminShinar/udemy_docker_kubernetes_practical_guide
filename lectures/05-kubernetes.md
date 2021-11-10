<!--
ignore these words in spell check for this file
// cSpell:ignore Kubermatic
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

it doesn't know anything about the machines that it will use, and requires us to create them and install the required software. we also might need the other resources such as the load balancer and file systems.

kubernetes will create the objects and monitor them.

there are tools for creating resources, such as [Kubermatic](https://www.kubermatic.com/) and the cloud providers have some good presets.


#### Kubernetes: Required Setup & Installation Steps
#### macOS Setup
#### Windows Setup
#### Understanding Kubernetes Objects (Resources)
#### The "Deployment" Object (Resource)
#### A First Deployment - Using the Imperative Approach
#### Kubectl: Behind The Scenes
#### The "Service" Object (Resource)
#### Exposing a Deployment with a Service
#### Restarting Containers
#### Scaling in Action
#### Updating Deployments
#### Deployment Rollbacks & History
#### The Imperative vs The Declarative Approach
#### Creating a Deployment Configuration File (Declarative Approach)
#### Adding Pod and Container Specs
#### Working with Labels & Selectors
#### Creating a Service Declaratively
#### Updating & Deleting Resources
#### Multiple vs Single Config Files
#### More on Labels & Selectors
#### Liveness Probes
#### A Closer Look at the Configuration Options
#### Summary


</details>
