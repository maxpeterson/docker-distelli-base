#!/bin/bash

# Stop the container
docker container stop docker-build-container

# Remove the named container
docker container rm docker-build-container

# Build the image
docker build -t docker-build-base .

# Run the image (creates a container)
docker run -dit --name docker-build-container docker-build-base

# Run bash in the container
#docker exec -it docker-build-container /bin/bash
