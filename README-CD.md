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

On above, macOS gave me issues when pulling specific tags, when I start setting up EC2 instances, will check to see if error is not there. 

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
  - ***Security Group*** Did not change from project 2, code below
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
      Tags:
        - Key: Name
          Value: CRONAUER-CF-SecurityGroup
  ```
  - This sets up SSH to work from my house, WSU and local network
  - We allow HTTP, since our webserver will be serving HTTP website, we allow all IPs to rwuest
  - For now this works for the purposes of this project, might need to add more for the webhook and I will update here when I do. 
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

# Part 3 - Project Description & Diagram
