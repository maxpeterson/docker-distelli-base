#!/bin/bash

# Run with specific make target
# ./run-tests.sh make test-live

project_path=${PROJECT_PATH:-~/Projects/gfgp-website}

# Stop the container
docker container stop docker-build-container

# Remove the named container
docker container rm docker-build-container

docker run -dit -v $project_path:/home/distelli/project --name docker-build-container docker-build-base

# Run docker-run-tests.sh in the container
docker exec -u distelli -it docker-build-container /usr/local/bin/docker-run-tests.sh $@
