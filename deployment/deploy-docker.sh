#!/bin/bash

# Define container name
CONTAINER_NAME="CI-CD-DOCKER"

# Check if a container with the same name exists (running or stopped)
EXISTING_CONTAINER=$(docker ps -a -q -f name=$CONTAINER_NAME)

# If a container exists, stop and remove it
if [ ! -z "$EXISTING_CONTAINER" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  sudo docker stop $EXISTING_CONTAINER
  sudo docker rm -f $EXISTING_CONTAINER
else
  echo "No existing container with name $CONTAINER_NAME"
fi

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

