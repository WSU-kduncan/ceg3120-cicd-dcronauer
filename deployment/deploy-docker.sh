#!/bin/bash

# Set variables
CONTAINER_NAME="CI-CD-DOCKER"
IMAGE_NAME="dcronauer2025/cronauer-ceg3120"
LOG_FILE="/home/ubuntu/ci-cd.txt"

# Step 1: Stop and remove the formerly running container
echo "[$(date)] Stopping the running container..." >> $LOG_FILE
sudo docker stop $CONTAINER_NAME >> $LOG_FILE 2>&1
sudo docker rm $CONTAINER_NAME >> $LOG_FILE 2>&1
echo "[$(date)] Container stopped and removed." >> $LOG_FILE

# Step 2: Pull the latest image from DockerHub
echo "[$(date)] Pulling the latest image from DockerHub..." >> $LOG_FILE
if ! sudo docker pull $IMAGE_NAME:latest >> $LOG_FILE 2>&1; then
  echo "[$(date)] ERROR: Failed to pull Docker image: $IMAGE_NAME:latest" >> $LOG_FILE
  exit 1
fi
echo "[$(date)] Latest image pulled." >> $LOG_FILE

# Step 3: Run a new container with the pulled image
echo "[$(date)] Running the new container..." >> $LOG_FILE
if ! sudo docker run -d --name $CONTAINER_NAME -p 80:4200 $IMAGE_NAME:latest >> $LOG_FILE 2>&1; then
  echo "[$(date)] ERROR: Failed to run the Docker container." >> $LOG_FILE
  exit 1
fi
echo "[$(date)] New container is running." >> $LOG_FILE
