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

### How to manually set up a container to run angular program

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
2. Run image we just pulled - used -p 4201:4200 to define port 4201 as the port for localhost and map to 4200 on the docker instance
```
docker run -it -p 4201:4200 node:18 bash
```

3. Navigate to /usr/src/app - use mkdir to create app directory if needed. I use pwd to show
that this was made manually on this image (will have to recreate this everytime)
```
root@58c38ec9e9c0:/usr/src/app# pwd
/usr/src/app
```
4. Copy angular app from 3120 class git hub using raw (changed /blob/ to /raw/)
```
curl -L -o angular.zip https://github.com/pattonsgirl/CEG3120/raw/main/Projects/Project4/angular-bird.zip
```
5. Extract contents of file in place (make sure you are in working directory location of where zip file installed)
   - First need to install unzip
   - Then need to use unzip to unzip the zip file
```
apt-get install unzip
unzip angular.zip
```
6. Install angular
```
npm install -g @angular/cli
```

7. Change directory to folder holding angular.json, do npm install, then do ng serve default port is 4200
```
cd wsu-hw-ng-main
npm install
ng serve --host 0.0.0.0
```
8. Went into web browser typed in localhost:port and web page came up!
![Eagle Image Manual](images/manualEagle.png)
