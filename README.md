<!--
ignore these words in spell check for this file
// cSpell:ignore udemy
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



Issues:
- when trying to get live server in windows with nodemon we need to add *-L* to the script to make it work.
  ```json 
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start":"nodemon -L app.js"
  },
  ```
- a