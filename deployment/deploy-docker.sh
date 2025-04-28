#!/bin/bash

# Define container name
CONTAINER_NAME="CI-CD-DOCKER"

echo "Stopping and removing existing container: $CONTAINER_NAME"
sudo docker stop $CONTAINER_NAME
sudo docker rm -f $CONTAINER_NAME

# Pull the latest image (optional if you want to ensure it's the latest)
echo "Pulling the latest image..."
sudo docker pull dcronauer2025/cronauer-ceg3120:latest
if [ $? -ne 0 ]; then
  echo "Error: Failed to pull Docker image."
  exit 1
fi

# Run the new container
echo "Running the new container..."
sudo docker run --rm -d --name $CONTAINER_NAME -p 80:4200 dcronauer2025/cronauer-ceg3120:latest
if [ $? -ne 0 ]; then
  echo "Error: Failed to run the Docker container."
  exit 1
fi

echo "Container is running successfully!"

