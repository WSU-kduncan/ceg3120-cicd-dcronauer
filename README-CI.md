# Part 1 Dockerize

## CI Project Overview

The intent of this project is to step away from AWS for a brief second in order to learn how to use Docker. 
This tool provides another way to spin up builds quickly and efficiently. Docker allows you to build up images,
define setup and then save that image for yourself and others to use. You or others can layer their own builds on top of 
this image and expand it out for other purposes. Docker containers are nice since they do not use the same process
as Virtual Instance machines that allocate CPU and RAM specifically for that instance. This allows Docker to be more
lightweight, easy to share and spin up, as well as more efficient to run.

## Setting up your Docker application

### Installing Docker on macOS

[Install Docker macOS](https://docs.docker.com/desktop/setup/install/mac-install/)

The link above can be used to install docker desktop. Once you install and run this app, you can use the terminal once 
Docker desktop is running. It is fairly easy to use when installing using the Docker app. Remember that in order to use terminal,
Docker desktop app needs to be running. 

### Verify Docker Installed and Running

After you run docker go to terminal and type this command, from the result you can determine if docker is running and also what
docker images are available for use.
```
danielcronauer@Daniel-2 ceg3120-cicd-dcronauer % docker ps -a
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                    PORTS     NAMES
565baa7206c4   ubuntu         "/bin/bash"              44 hours ago   Up 44 hours                         awesome_spence
3e8008e40372   firstimage     "/bin/bash"              6 days ago     Exited (0) 6 days ago               confident_hugle
4b163b1bf30d   ubuntu         "/bin/bash"              7 days ago     Exited (127) 7 days ago             brave_thompson
3cdda882b59f   ubuntu         "/bin/bash"              7 days ago     Exited (0) 7 days ago               priceless_banzai
c644f9c74ad8   ubuntu         "/bin/bash"              7 days ago     Exited (0) 7 days ago               hardcore_kalam
b60037561a48   ubuntu         "/bin/bash"              8 days ago     Exited (1) 8 days ago               ecstatic_nobel
d74f56cffddd   ubuntu         "/bin/bash"              8 days ago     Exited (0) 8 days ago               sad_lehmann
0fa316fb8bfc   d79336f4812b   "/docker-entrypoint.…"   9 days ago     Exited (0) 9 days ago               cranky_ganguly
ecb020c6d613   d79336f4812b   "/docker-entrypoint.…"   9 days ago     Exited (2) 9 days ago               relaxed_lovelace
b5dbe2c7e7fb   7e1a4e2d11e2   "/hello"                 9 days ago     Exited (0) 9 days ago               jovial_morse
```

### How to manually set up a container

1. Get docker image for node:18 from docker hub
```
danielcronauer@Daniel-2 ceg3120-cicd-dcronauer % docker pull node:18
18: Pulling from library/node
43b3ca1db9e3: Pull complete 
62cad2f6aff7: Pull complete 
ebf144460616: Pull complete 
0e3cee1fc214: Pull complete 
71daa2c787b0: Pull complete 
002e18bd5659: Pull complete 
9d81c6467275: Pull complete 
e171895483c6: Pull complete 
Digest: sha256:df9fa4e0e39c9b97e30240b5bb1d99bdb861573a82002b2c52ac7d6b8d6d773e
Status: Downloaded newer image for node:18
docker.io/library/node:18
```



