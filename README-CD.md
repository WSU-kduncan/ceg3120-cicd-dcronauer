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


## References Part 2

1. chatgpt prompt - to install docker on AWS ubuntu instance
```
how do i install docker on ubuntu aws instance
```

# Part 3 - Project Description & Diagram
