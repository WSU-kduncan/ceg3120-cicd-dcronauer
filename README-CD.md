# Part 3 - Project Description & Diagram

## Project Overview

### Goal of the project

  - The goal of project 5 is to have students to apply an implementation CI and CD working together.
  - The idea is to allow github repository changes to push updated docker images automatically to a remote AWS EC2 instance.
  - This docker image will include a copy of the most recent website built in the GitHUb repository.
  - The developer does not need to worry about anything, just push the tag that they are working on to the remote github repository.
  - This allows the developer to focus on development knowing that their changes will reliably push to
    the remote server that is serving the website content.

### Tools used

  - **GitHub Workflows** There is a .yml file in .github/workflows that will be used to trigger github actions.
  This trigger will pull the current repository, log into dockerhub, create several dockerhub images and push them to dockerhub.
  - **DockerHub / Docker** Docker Hub will be used to create a public repository to hold docker images for the project
  - **DockerHub Webhook trigger** You provide a name and URL for where to push the webhook request to the AWS EC2 instance.
  DockerHub will send for every tag pushed, but will filter for only latest on the EC2 end.
  - **AWS EC2 instance with public ip** This instance will have several tools loaded onto it in order to handle the CI/CD process
  - **adnanh Webhook** This is a lightweight GitHub repository that enables the use of webhooks. We install the library on EC2 instance
    - This webhook library listens on port 9000 and will trigger if latest tag is pushed as part of HTTP request over this port.
    - You definine a json file, which is the hook that listens for the request and responds by runing the script that repalces
    current docker image on EC2 instance with the most recent docker image tagged latest.
    - This json file defines what command will be executed and provides ID to reference for service. 
  - **Webhook Service file** This file sets up a service for webhook, it ensures that webhook stays available. It waits for docker and network
  to be avaialable before running. It restarts if it stops for any reason. This way the hook is always on the EC2 waiting for a deployment push.
  - **SSH bash script to run from webhook trigger** This bash script stops and removes current running docker image. Then it pulls the latests
  docker image which should reflect your current angular project state in github. Then it will run and deploy that new docker image so the
  website is updated with the changes.
  - **Public GitHub repository** This will house the angular project and provide the actions that push a new image to DockerHub which will
  trigger the DockerHub to send a request on port 9000 to the AWS EC2 webhook.

## Mermaid Diagram

```mermaid
flowchart TD
    A[Developer pushes Git tag (vX.X.X)] --> B[GitHub Actions Workflow Triggered]
    B --> C[Build Docker Image using Buildx]
    C --> D[Tag Docker Image<br>vX.X.X, vX.X, vX, latest]
    D --> E[Push Tagged Image to DockerHub]

    E --> F[DockerHub Webhook Triggered on 'latest' Tag]
    F --> G[HTTP POST to EC2 Webhook Listener (port 9000)]

    G --> H[Webhook Handler (adnanh/webhook)]
    H --> I[Execute deploy-docker.sh Script]

    I --> J[Stop & Remove Old Docker Container]
    J --> K[Pull Latest Docker Image from DockerHub]
    K --> L[Run New Docker Container]
    L --> M[Updated Website Live on EC2]

    subgraph EC2 Instance
        G
        H
        I
        J
        K
        L
        M
    end

    subgraph GitHub Repository
        A
        B
        C
        D
    end

    subgraph DockerHub
        E
        F
    end
```

## Part 3 References

1. chatgpt prompt for diagram
```
after this prompt I will paste my github repository readme, can you review it and provide a mermaid mardown code to anwer the following Include a diagram (or diagrams) of the continuous deployment process configured in this project. It should (at minimum) address how the developer changing code results in a new container process running on the server running the container application.
(contents of readme-cd.md)
```
```
you did not make a mermaid diagram that i requested
```

# Part 1 - Semantic Versioning

## Git Tag Documentation

### How to see tags 

```
git tag
```
### Make tag current commit using semantic versioning

```
git tag -a vx.x.x -m "message for tag"
```

### Push Tag to GitHub

```
git push origin (name of tag)
```

## Semantic Versioning Container Images with GitHub Actions

### Summary of Workflow

This GitHub Actions workflow automates the building and pushing of Docker images using semantic versioning. It ensures images are only pushed for specific tags and follows a CI/CD model using best practices for Docker and GitHub Actions.


###  Summary Workflow Steps

- **Runs on every pull request** for Docker build validation (but doesn’t push images).
- **Pushes Docker images to Docker Hub** when a Git tag matching `v*.*.*` is pushed (e.g., `v1.2.3`).
- Runs using ubuntu-latest
- allowed to write packages and read contents of github repo
- Check out GitHub repository using actions/checkout
- Uses GitHub secrets and docker login action.
- Sets up QEMU
- Sets up Buildx
- Builds and pushes docker image based on the tags defined below
- Tags Docker images semantically using:
  - Full version: `v1.2.3`
  - Minor version: `v1.2`
  - Major version: `v1`
  - `latest` tag for releases
- Builds images using Docker Buildx with support for cross-platform builds.

### How to change .yml file fors new GitHub/DockerHub repository if needed

1. Add secrets review the structure in .yml file. 
```
username: ${{ secrets.DOCKER_USERNAME }}
password: ${{ secrets.DOCKER_TOKEN }}
```
  - The new github repository will have to name two secrets matching the names here with the DockerHub repository credentials that you want to access and push an image to
2. Ensure that branch main is the branch of origin on the new repo, otherwise you will have to change to the one that you want commits to trigger the action on.
  - This might not affect project 5 as we only cared about tags vx.x.x and latest. 
3. Update the context, your Dockerfile might be in a different spot in the new repository. You will have to provide path from github repo root if it changes.
4. Pay attention to the dockerhub repository. If it changed you will need to update this, in the with section for your images in docker/metadata action. Reference your username/repository name.
  - We will continue to use latest, but also want the different tag versions (major, major.minor and major.minor.patch)
5. Double check and verify that your tags and latest are pushed to dockerhub for testing.    

### Location of .yml file
[Path to cdBuild.yml](.github/workflows/cdBuild.yml)

## Testing and Validation

### GitHub Workflow Verification

1. ***Image terminal making new tag and pushing to GitHub v0.8.1***
![Terminal tag push](/Project4/images/pushTag.png)<br>
2. ***GitHub action tag showing workflow action that worked***
![GitHub Action](/Project4/images/githubAction.png)<br>
3. ***Image showing three tag version and latest updated in DockerHub***
![DockerHub Tags](/Project4/images/dockerTagVersions.png)<br>

### Docker container, pulled and run

1. ***Terminal image, pulling container and running***
![Image pull](/Project4/images/dockerPull.png)<br>
2.***Compiled and running container***
![Image compile](/Project4/images/compiledContainer.png)<br>
3. ***Local Browser web page served***
[Browser Image](/Project4/images/eagle.png)<br>

### Note

On above, macOS gave me issues when pulling specific tags, when I start setting up EC2 instances, will check to see if error is not there. You will see in Ubuntu EC2 instance that this goes away as we wanted AMD64 and my system is ARM64.

## References Part 1

1. [docker mange tags GitHub actions](https://docs.docker.com/build/ci/github-actions/manage-tags-labels/)
2. [metadata-action](https://github.com/docker/metadata-action?tab=readme-ov-file#semver)
3. chatgpt prompt ```can you explain this workflows file to me? (copied file from reference 2)
4. chaggpt prompt off first above ```what if i want to send to dockerhub instead of ghcr```
5. [Found this when troubleshooting](https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/publishing-docker-images)
6. chat gpt prompt
```
i am going to pass you some code at end, can you write me some documentation in github markdown format that addresses the following bullet points?
Semantic Versioning Container Images with GitHub Actions

    Summary of what your workflow does and when it does it
    Explanation of workflow steps
    Explanation / highlight of values that need updated if used in a different repository
        changes in workflow
        changes in repository
    Link to workflow file in your GitHub repository
```

## Problems Part 1

I ran into problems with authorization. Turns out that my docker username was wrong. It took a little while to figure out. First I thought my token didnt have the right scope so i changed to read, write, delete. Then I thought the permisions section in the workflow needed more items aded. It ended up being much simpler. I just typed my username in right for dockerhub user/repo to push to! 

# Part 2 - Continous Deployment

## EC2 Instance Details

### Cloud Formation Template used Project 2 and modified from there

  - ***AMI*** ami-04b4f1a9cf54c11d0
  - ***Instance type*** t2.medium
  - ***Volume Size*** 30GB
  - ***Security Group*** Did not change from project 2 (minus adding port 9000), code below
  ```
  SecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      VpcId: !Ref VPC
      GroupDescription: Enable SSH access via port 22 and open HTML port.
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 130.108.0.0/16  # WSU CIDR SSH
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 74.139.93.82/32 #home network SSH
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 172.18.0.0/23 #local network SSH both public and maybe eventually private subnets
        - IpProtocol: tcp #allow HTTP but not HTTPS
          FromPort: '80'
          ToPort: '80'
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp 
          FromPort: '9000'
          ToPort: '9000'
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: CRONAUER-CF-SecurityGroup
  ```
  - This sets up SSH to work from my house, WSU and local network
  - We allow HTTP, since our webserver will be serving HTTP website, we allow all IPs to request
  - Webhook uses port 9000 by default. We will add here.
  - If I wanted to be ultra snazy rather than out of time and exhausted from work and school I would have
     added all ip's that dockerhub would have sent out for port 9000.

## Docker Setup EC2 on Ubuntu

### Install Docker Unbuntu and Dependencies
 
  - I added the following code to the EC2 setup script. This was suggested by CHAPGPT and works without me having to do anything. Captures dependencies and install at the same time.
```
apt-get update && \
apt-get install -y \
ca-certificates \
curl \
lsb-release && \
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o \            etc/apt/keyrings/docker.gpg
echo \
"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
docker-compose-plugin -y
```

### Confirm Install docker

1. Command line use docker --version
```
ubuntu@Cronauer-Ubuntu-24:~$ docker --version
Docker version 28.1.1, build 4eba377
```
2. Confirm you can run docker container, I already have one loaded through script. I killed the runing process in order to open port. Then ran this command.
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker run -it -p  80:4200 dcronauer2025/cronauer-ceg3120:latest
Warning: This is a simple server for use in testing or debugging Angular applications
locally. It hasn't been reviewed for security issues.

Binding this server to an open connection can result in compromising your application or
computer. Using a different host than the one passed to the "--host" flag might result in
websocket connection issues. You might need to use "--disable-host-check" if that's the
case.
✔ Browser application bundle generation complete.

Initial Chunk Files   | Names         |  Raw Size
vendor.js             | vendor        |   2.34 MB | 
polyfills.js          | polyfills     | 234.35 kB | 
styles.css, styles.js | styles        | 145.32 kB | 
main.js               | main          |  96.33 kB | 
runtime.js            | runtime       |   6.50 kB | 

                      | Initial Total |   2.81 MB

Build at: 2025-04-22T12:07:35.539Z - Hash: edd52c0d9c75996c - Time: 18421ms

** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-22T12:07:36.253Z - Hash: edd52c0d9c75996c - Time: 562ms

✔ Compiled successfully.
```
- Checking web browser to public IP address confirmed that it is available to outside world on port 80.

## Testing on EC2 Instance

### Pull from DockerHub repository

1. Go to docker hub, identify the containe you want from repository and click copy. Here is command for v0.9.0. You will want to use sudo with the command. Not that pulling a tag name works here, vs locally on my mac for tags.
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker pull dcronauer2025/cronauer-ceg3120:v0.9.0
v0.9.0: Pulling from dcronauer2025/cronauer-ceg3120
23b7d26ef1d2: Already exists 
07d1b5af933d: Already exists 
1eb98adba0eb: Already exists 
b617a119f8a2: Already exists 
ee496386c5de: Already exists 
058db40e5342: Already exists 
04deb1529fda: Already exists 
3b3ca5178f3e: Already exists 
b3498f8efd54: Pull complete 
3262a782ee46: Pull complete 
141ff8251eca: Pull complete 
fa1d8e742164: Pull complete 
4f4fb700ef54: Pull complete 
bd1fba00a32c: Pull complete 
Digest: sha256:89455364705f8ba26316044458029b3e13d2b614710c2f62c01b4ea0c8953f66
Status: Downloaded newer image for dcronauer2025/cronauer-ceg3120:v0.9.0
docker.io/dcronauer2025/cronauer-ceg3120:v0.9.0
```

### Run Image tag pulled

- ```-it``` will run interactively and you be inside the docker instance as it runs. When the angular app starts it will run in foreground and you will just see the compile successful and nothing else. If you use ```-d``` flag it will run in the background freeing up the terminal to do other things as the angular app runs. Once complete we will stop using -it and use -d since we have confirmed that everything works and we do not need to see it anymore. Running in the background makes more sense for services like docker container images. That way you can have more than one running on the AWS instance at the same time if needed.
- Code to run interactively below
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker run -it -p  80:4200 dcronauer2025/cronauer-ceg3120:v0.9.0
Warning: This is a simple server for use in testing or debugging Angular applications
locally. It hasn't been reviewed for security issues.

Binding this server to an open connection can result in compromising your application or
computer. Using a different host than the one passed to the "--host" flag might result in
websocket connection issues. You might need to use "--disable-host-check" if that's the
case.
✔ Browser application bundle generation complete.

Initial Chunk Files   | Names         |  Raw Size
vendor.js             | vendor        |   2.34 MB | 
polyfills.js          | polyfills     | 234.35 kB | 
styles.css, styles.js | styles        | 145.32 kB | 
main.js               | main          |  96.33 kB | 
runtime.js            | runtime       |   6.50 kB | 

                      | Initial Total |   2.81 MB

Build at: 2025-04-22T12:24:32.639Z - Hash: edd52c0d9c75996c - Time: 18618ms

** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-22T12:24:33.278Z - Hash: edd52c0d9c75996c - Time: 495ms

✔ Compiled successfully
```

### Verify that angular is serving from docker instance
  
  - Container side verification is listed above. We ran interactively and saw the results in the docker instance terminal.

### Verify that angular is serving from AWS instance

  - Run docker kill any running instances (use docker ps -a to identify running images)
   - Run in detached mode. This will let you be inside AWS instance with docker container running in background. We use docker ps -a to confirm that v0.9.0 is running (up 18 seconds) for thirsty_euler. Also confirmed that web browser works. 
  ```
  ubuntu@Cronauer-Ubuntu-24:~$ sudo docker run -d -p  80:4200 dcronauer2025/cronauer-ceg3120:v0.9.0
0d3eaac317108ea1224d5dcb473c24a93e7596e25f95d72df1a076401c33c33b
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker ps -a
CONTAINER ID   IMAGE                                   COMMAND                  CREATED          STATUS                            PORTS                                     NAMES
0d3eaac31710   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   19 seconds ago   Up 18 seconds                     0.0.0.0:80->4200/tcp, [::]:80->4200/tcp   thirsty_euler
625ef0fc848c   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   10 minutes ago   Exited (137) About a minute ago                                             intelligent_lovelace
51401c88438a   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   11 minutes ago   Created                                                                     dreamy_fermi
a5d06c4fc009   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   27 minutes ago   Exited (137) 10 minutes ago                                                 sad_spence
f9d7e5e74035   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   56 minutes ago   Exited (137) 29 minutes ago                                                 CI-CD-DOCKER
  ```

### Verify from outside system
  - I have posted the bird so many times. I can confirm that it runs from local webbrowser and serves the bird. 

## Scripting Container App Refresh for webhook to call

### Script created

### Test Script

1. Check docker ps -a (remember sudo), kill any running (we have v0.9.0 running), so if this works (CI-CD-DOCKER) at bottom will now be running and a new container ID.
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker ps -a
CONTAINER ID   IMAGE                                   COMMAND                  CREATED             STATUS                        PORTS                                     NAMES
0d3eaac31710   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   7 minutes ago       Up 7 minutes                  0.0.0.0:80->4200/tcp, [::]:80->4200/tcp   thirsty_euler
625ef0fc848c   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   17 minutes ago      Exited (137) 9 minutes ago                                              intelligent_lovelace
51401c88438a   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   18 minutes ago      Created                                                                 dreamy_fermi
a5d06c4fc009   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   34 minutes ago      Exited (137) 17 minutes ago                                             sad_spence
f9d7e5e74035   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   About an hour ago   Exited (137) 36 minutes ago                                             CI-CD-DOCKER
```
2. Run script
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo ./deploy-docker.sh
```
3. Run docker ps -a again, note that CI-CD-DOCKER is not running and container ID changed. Script worked!
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker ps -a
CONTAINER ID   IMAGE                                   COMMAND                  CREATED          STATUS                            PORTS                                     NAMES
20f162ec73d6   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   39 seconds ago   Up 38 seconds                     0.0.0.0:80->4200/tcp, [::]:80->4200/tcp   CI-CD-DOCKER
0d3eaac31710   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   11 minutes ago   Exited (137) About a minute ago                                             thirsty_euler
625ef0fc848c   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   21 minutes ago   Exited (137) 12 minutes ago                                                 intelligent_lovelace
51401c88438a   dcronauer2025/cronauer-ceg3120:v0.9.0   "docker-entrypoint.s…"   22 minutes ago   Created                                                                     dreamy_fermi
a5d06c4fc009   09b767330c78                            "docker-entrypoint.s…"   38 minutes ago   Exited (137) 21 minutes ago                                                 sad_spence
```
4. Check browser locally to see if bird is still staring can confirm it is.

### Link to script

[SH script automation](deployment/deploy-docker.sh)

## Configuring webhook listener EC2 instance

### How to install webhooks Ubuntu instance

```
sudo apt-get install webhook
```

### How to verify webhook installation

```
ubuntu@Cronauer-Ubuntu-24:~$ webhook --version
webhook version 2.8.0
```

### Summary Webhook definition file

 - **id** this will be used to identify your hook to use if you have multiple hooks 
 - **execute-command** this is the script that we are telling the hook to run when triggered (in our case, stop and remove current docker container, pull the latest tag and run it.
 - **command-working-directory"** this tells us the directory to search for hooks in, it will pick hook based on id
 - **pass-arguments-to-command** this is the message and payload to pass
 - **response-message** sends response back to calling machine
 - **trigger-rule** Use this section to only allow value latests to trigger my docker script. Parameter passes my tag to the trigger for matching.
```
[
{
  "id": "CI-CD",
  "execute-command": "/home/ubuntu/deploy-docker.sh",
  "pass-arguments-to-command": [
    {
      "source": "payload",
      "name": "push_data.tag"
    }
  ],
  "trigger-rule": {
    "match": {
      "type": "value",
      "value": "latest",
      "parameter": {
        "source": "payload",
        "name": "push_data.tag"
      }
    }
  }
}
]
```

### Verify that webhook loaded definition file

- Run this command and it should run in the background sending logging to webhook.log for troubleshooting if needed
```
ubuntu@Cronauer-Ubuntu-24:~$ nohup webhook -hooks /home/ubuntu/webhook-definition.json -verbose > webhook.log 2>&1 &
[1] 1633
```
details from log file
```
ubuntu@Cronauer-Ubuntu-24:~$ cat webhook.log
nohup: ignoring input
[webhook] 2025/04/22 13:37:39 version 2.8.0 starting
[webhook] 2025/04/22 13:37:39 setting up os signal watcher
[webhook] 2025/04/22 13:37:39 attempting to load hooks from /home/ubuntu/webhook-definition.json
[webhook] 2025/04/22 13:37:39 found 1 hook(s) in file
[webhook] 2025/04/22 13:37:39 	loaded: CI-CD
[webhook] 2025/04/22 13:37:39 serving hooks on http://0.0.0.0:9000/hooks/{id}
[webhook] 2025/04/22 13:37:39 os signal watcher ready
```
### Verify webhook receiving loads
  
  - monitor logs running webhook checked webhooks service
  ```
  ubuntu@Cronauer-Ubuntu-24:~$ sudo systemctl status webhook.service
● webhook.service - Webhook Service
     Loaded: loaded (/etc/systemd/system/webhook.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-04-23 17:16:49 UTC; 2h 8min ago
   Main PID: 1185 (webhook)
      Tasks: 8 (limit: 4676)
     Memory: 9.8M (peak: 20.2M)
        CPU: 356ms
     CGroup: /system.slice/webhook.service
             └─1185 /usr/bin/webhook -hooks /home/ubuntu/webhook-definition.json -verbose

Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: 49c844a6557f: Pull complete
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: 4f4fb700ef54: Pull complete
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: ec7fb3870843: Pull complete
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: Digest: sha256:300ddb5e88d46f0b11d7b70f3a70eff6a0bd99ad97be49d365286fd2fbc1b8c8
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: Status: Downloaded newer image for dcronauer2025/cronauer-ceg3120:latest
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: docker.io/dcronauer2025/cronauer-ceg3120:latest
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: Running the new container...
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: 30cfae8ce7d2ff4869e948b5349f6cb7cf1b87c3fa8f80f32822a6c1ac40ed1f
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: Container is running successfully!
Apr 23 18:34:39 Cronauer-Ubuntu-24.04-LTS webhook[1185]: [webhook] 2025/04/23 18:34:39 [2412ad] finished handling CI-CD
  ```
  - look for in docker process views
```
ubuntu@Cronauer-Ubuntu-24:~$ sudo docker ps -a
CONTAINER ID   IMAGE                                   COMMAND                  CREATED          STATUS                      PORTS                                     NAMES
30cfae8ce7d2   dcronauer2025/cronauer-ceg3120:latest   "docker-entrypoint.s…"   50 minutes ago   Up 50 minutes               0.0.0.0:80->4200/tcp, [::]:80->4200/tcp   CI-CD-DOCKER
b7b812f494ca   dcronauer2025/cronauer-ceg3120:v1.1.0   "docker-entrypoint.s…"   27 hours ago     Exited (137) 27 hours ago                                             quirky_bhabha
eef959f2304a   dcronauer2025/cronauer-ceg3120:v1.1.0   "docker-entrypoint.s…"   27 hours ago     Exited (137) 27 hours ago                                             suspicious_leakey
e109518942e7   dcronauer2025/cronauer-ceg3120:v1.1.0   "docker-entrypoint.s…"   28 hours ago     Created         
```

### Link to definition file

[Github definition file](webhook-definition.json)


## Configure Payload Sender

### Why I chose DockerHub

I chose DockerHub for the simple reason that GitHub action might fail, or we might choose another remote repository using Git at some point. For this reason, I think it is better to listen on DockerHub side, since that is where the changes and storage of containers is happening. I learned that DockerHub sends each tag that pushes, but by triggering on latest, I solved my issues. I like to rely on the last part of the chain to ensure that the container will be available when pulled.

### How to enable DockerHub to send payloads to EC2 webhook listener

1. Go to repository on DockerHub
2. Click webhooks tab
3. Type in webhook name
4. Type in url that will trigger webhook on ec2 instance

### What triggers will send paylord to EC2 webhook listener

This is simple, any time that an image is pushed to this DockerHub repository will cause the webhook to trigger.
This will then cause the EC2 instance to download latest image. I used some triggers in the webhook json file to only allow 
the latest tag to trigger the script to stop and remove old latest, then pull and run current latest.

### How to verify payload delivered
See webhook section as that section confirms the same thing. Just on the webhook end. 

## Configure a webhook Service on EC2 instance

### Summary webservice contents
First make sure that you add webhook.service file to this location ```/etc/systemd/system/```
 - **Unit**
   - **Description** - just gives description that we can understand for the service involved
   - **After=network.target** - this tells us that the service will only start once the network is up
 - **Service**
   - **ExecStart=/usr/bin/webhook -hooks /home/ubuntu/webhook-definition.json -verbose**
     This is the meat of the service, tells us where the app is located and where the hook file to run is.
   - **WorkingDirectory=/home/ubuntu** Tells us where the root directory for service will be
   - **User** user to run in our case ubuntu
   - **Group** group to run in our case ubuntu
   - **Restart=always** Tells us that the webhook service will restart if it stops for any reason
  - **Install**
   - **WantedBy=multi-user.target** Tells tells us to start during boot process

### How to enable,start,stop,retart the webhook service
   
   - **Restart daemon if you changed webhook.service file*** ```sudo systemctl daemon-reload```
   - **Enable** ```sudo systemctl enable webhook.service```
   - **Start** ```sudo systemctl start webhook.service```
   - **Stop** ```sudo systemctl stop webhook.service```
   - **Restart** ```sudo systemctl restart webhook.service```
   - **Get Status** ``sudo systemctl status webhook.service```

### How to verify webhook.service is working

### Link to service file

[Link to webhook.service](webhook.service)

## References Part 2

1. chatgpt prompt - to install docker on AWS ubuntu instance
```
how do i install docker on ubuntu aws instance
```
2. chatgpt prompt - making script
```
can you make me a bash script 
Craft a bash script that will:

    stop and remove the formerly running container
    pull the latest tagged image from your DockerHub repository
    run a new container process with the pull'ed image
    ADD bash script to folder named deployment in your GitHub repository
```
4. chaggpt prompt - improving script if docker container does not exists, fixed script above first so it ran, then realized, what if container does not exist yet?
```
can this handle the case if the docker image does not exists
#!/bin/bash

# Set variables (adjust these to your needs)
CONTAINER_NAME="CI-CD-DOCKER"      # The name of your Docker container
IMAGE_NAME="dcronauer2025/cronauer-ceg3120" # DockerHub image name (replace with your actual image)

# Step 1: Stop and remove the formerly running container
echo "Stopping the running container..." >> /home/ubuntu/ci-cd.txt
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
echo "Container stopped and removed."

# Step 2: Pull the latest image from DockerHub
echo "Pulling the latest image from DockerHub..." >> /home/ubuntu/ci-cd.txt
sudo docker pull $IMAGE_NAME:latest
echo "Latest image pulled."

# Step 3: Run a new container with the pulled image
echo "Running the new container..." >> /home/ubuntu/ci-cd.txt
sudo docker run -d --name $CONTAINER_NAME -p 80:4200 $IMAGE_NAME:latest 
echo "New container is running."
```
5. Webhook reference - sudo apt-get install webhook (added to cloud formation) - also doc references port 9000 (add to security group!)
[Class Reference](https://github.com/adnanh/webhook)
6. Chatgpt prompts
```
can you do the following things for me?
Configuring a webhook Listener on EC2 Instance

    How to install adnanh's webhook to the EC2 instance
    How to verify successful installation
    Summary of the webhook definition file
    How to verify definition file was loaded by webhook
    How to verify webhook is receiving payloads that trigger it
        how to monitor logs from running webhook
        what to look for in docker process views
    LINK to definition file in repository
```
prompt below provided information on how to set up service file for webhooks
```
can this webhook be run in the background
```
7. chatgpt prompts - just want dockerhub to send http request over port 9000 that will trigger the script
```
how to have dockerhub sent webhook request to ec2 instance
```
# Part 3 - Project Description & Diagram
