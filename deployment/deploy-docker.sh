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


