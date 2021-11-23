<!--
ignore these words in spell check for this file
// cSpell:ignore udemy hyperv kubeconfig
-->

# Docker & Kubernetes: The Practical Guide

based on the udemy course [Docker & Kubernetes: The Practical Guide](https://www.udemy.com/course/docker-kubernetes-the-practical-guide/) or the [CheckPoint Version](https://checkpoint.udemy.com/course/docker-kubernetes-the-practical-guide) of the same course. 


[Introduction](lectures/01-introduction.md) 

- Introduction to Docker

[Foundations](lectures/02-foundations.md)

- Images and Containers
- Managing Data and Volumes
- Networking and Containers Communications

[Practical Application Usage](lectures/03-practical.md)

- Building a Multi Container Application
- Using Docker-Compose
- Utility Containers
- Complex PHP project

[Docker Container Deployment](lectures/04-deployment.md)

- Deploying
  - Un-manage Manual Deployment (AWS EC2)
  - Managed Deployment (AWS ECS)
  - Multi-Stage Build
- Summary

[Kubernetes](lectures/05-kubernetes.md)

- Kubernetes Concepts
- Kubernetes in Action - Diving into the Core Concepts
- Persistent Data in Kubernetes
- Networking in Kubernetes
- Kubernetes deployment (AWS EKS)
- Round Up



## Special Takeaways

- when trying to get live server in windows with nodemon we need to add *-L* to the script to make it work.
  ```json 
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start":"nodemon -L app.js"
  },
  ```
- for the MYSQL service, i might have to add an environment variable "MYSQL_ALLOW_EMPTY_PASSWORD=true" to make it not exit immediately.

## Docker Cli

<details>
<summary>
docker commands
</summary>

docker container run
- *--pull "always|missing|never"*  - the quotes don't matter, we can skip them. "missing" is default.
- *--workdir,-w "folder path"* - overwrite working directory

</details>


## Dockerfile 

<details>
<summary>
Dockerfile
</summary>

[Reference](https://docs.docker.com/engine/reference/builder/)

Stanza | format | usages | note
------------|---------|--------|----
FROM | image:tag | base image | add `as` to label step
WORKDIR | directory | move to folder | create if needed
COPY | source destination | copy contents | NA
RUN | shell command | installing packages, | NA
ENV | name=value | environment variables | NA
ARG | name=default value | build time variables | *--build-arg* in docker image build
EXPOSE | port number | expose port | optional?
VOLUME | location inside image | anonymous volume?| optional
CMD | ["shell","command"] | image starting command | `--from=step`
ENTRYPOINT | ["shell","command"] | entry point when passing a command | limit what we can do with the container. similar to `CMD` in some ways
ADD |
USER |
ONBUILD |
STOPSIGNAL |
HEALTHCHECK |
SHELL |


</details>

## Docker-Compose

<details>
<summary>
docker-compose.yaml file
</summary>

[Reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)
- version:
- services:
  - \<service name>:
    - image:
    - build:
      - context:
      - dockerfile:
      - args:
        - key:value format
    - stdin_open: \<boolean>
    - tty: \<boolean>
    - volumes:
      - list of volume patterns (anonymous, named, bind mounts)
      - can be suffixed with ":ro" or ":delegated"
    - environment:
      - variable:value (key:value format) OR list of variable=value entires
    - env_file:
      - list of \<file location>
    - ports
      - list of "\<external>:\<internal>" ports
    - networks
      - list of networks
    - depends on
      - list of services that need to be up before this one
    - working_dir: override dockerfile 
    - entrypoint: override dockerfile
- networks:
  - \<network name>:
- volumes:
  - named volumes \<volume name>:

commands
- up
  - *--detach,-d*
  - *--build*
  - *--no-build*
  - *--no-start*
- down
- run \<service name> \<arguments>
- exec
- ps
- top
</details>


## Kubectl

<details>
<summary>
kubectl commands
</summary>

- *create \<resource> \<name>* 
  - *deployment*
    - *--image*
- *expose deployment \<name>*
  - *--port=*
  - *--type=* - ClusterIP, NodePort, LoadBalancer
- *get*
  - *deployment*
  - *pods*
  - *services*
  - *all*
- *scale*
  - *--replicas=5*
- *rollout*
  - *undo*
    - *--to-revision*
  - *history*
    - *revision=1*
- *apply*
  - *--filename, -f* - which file to use

*--selector, -l* - select with key:value, we can limit to kind.

Resource (kind) | APIVersion | usage | spec fields|selector match | values?
-------|-----------|----|-----|------|---
Deployment | apps/v1 | define pods |selector,replicas, template | \[same-file]template:metadata |...
Service | v1 |  stable IP and connection to the outside| selector,type,ports | deployment:template |type: "ClusterIP\NodePort\LoadBalancer"
ConfigMap | v1 | environment variables |data |none |key-value pairs
PersistentVolume | v1 | define data storage on the cluster |capacity, volumeMode, storageClassName, accessModes, hostPath |none | volumeMode: "Filesystem, Block", 
PersistentVolumeClaim | v1 | use storage |volumeName, StorageClassName, accessModes, Resources, |none|accessModes:  "ReadWriteOnce\ReadOnlyManyReadWriteMany"
StorageClass | storage.k8s.io/v1| volume/storage plug-in | **no spec, but has provisioner**| none | none

</details>


## Minikube

<details>
<summary>
minikube commands
</summary>

- *start*
  - *--driver=docker|hyperv*
- *delete*
- *status*
- *dashboard*
- *service* - get ip to use
</details>

## Shell

<details>
<summary>
shell commands
</summary>

```sh
$env:path

# curl get
curl --location --request GET 'localhost/story'
# curl alternative
Invoke-RestMethod 'localhost/story' -Method 'GET' -Headers $headers | ConvertTo-Json 
```
</details>

## AWS EKS

<details>
<summary>
Setting up aws eks cluster
</summary>

EKS - elastic kubernetes cluster

### Create Cluster

**steps:**

#### Configure cluster
create cluster, give it a *name*, kubernetes version.

cluster service roles (IAM):

configure eks roles:
- <kbd>Create Role</kbd> -> <kbd>EKS</kbd> - > <kbd>EKS-Cluster</kbd> -> <kbd>Next: Permission</kbd>
- give name such as '*eksClusterRole*', and <kbd>Create Role</kbd>

back in the eks, use the newly created role.

#### Specify networking

we want it to also private and also accessible,

search for *aws CloudFormation* service.\
<kbd>Create Stack</kbd>, then use [this link](https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html#create-vpc) to grab the template for the **Amazon S3 URL**
> "https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml"

click next and give the stack a name. create the stack.

back in the eks cluster page, choose this stack as the VPC.

for **Cluster endpoint access**, choose <kbd>Public and Private</kbd>.

#### Configure Logging
nothing here.
#### review and create
nothing here.


now we need to wait for the cluster to be created, and then add nodes.

to set kubectl to use this cluster (and not minikube), we need to change the *config* file at the *.kube* hidden folder.

we want it to talk to the eks cluster, so we copy backup the file, and then we use the *aws-cli* tool to configure the cluster.

click on <kbd>account</kbd>
security credentials. <kbd>Create new access key</kbd>, download it. this file has *AWSAccessKeyId* and *AWSSecretKey* variables


(couldn't find this!)

and then run `aws configure` with those values. this will set the config folder.

```sh
#aws eks --region <region> update-kubeconfig --name <cluster name>
aws eks --region us-east-2 update-kubeconfig --name FirstCluster
```

now if we inspect this file we would see some aws things

### Add Nodes To Cluster

now we want to add Nodes

so we move to the <kbd>compute tab</kbd> and click <kbd>add node group</kbd>

#### Configure Node Group

assign name: *whatever*

Node IAM role: open IAM:\
<kbd>Create Role</kbd>, then select use case <kbd>EC2</kbd> and choose policies:
- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- AmazonEC2ContainerRegistryReadOnly

create this role and pick it for the node group.

#### Set Compute and scaling configuration

for instance type use *t3.small*.
choose scaling policy, start with two nodes.

#### Specify networking
nothing here
#### Review and Create
nothing here

now we should wait until the node group is created.

we will use EC2 service later.

[connect to amazon eks cluster](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-connection/)

[creating IAM admin user and user group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)

</details>