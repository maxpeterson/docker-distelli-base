# docker-distelli-base

Create a Docker build image for Distelli / pipelines.puppet.com.

Based on steps in https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html

## Updating the Image

If the Dockerfile is updated then it will trigger distelli / pipelines.puppet.com to generate a new image. This image will need to be [set as a *Build Image*](https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html#set-build-image).

Any distelli / pipelines.puppet.com builds that should use the image will then need to have the [*Build Options* updated to use the new image](https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html#using-custom-docker-images-to-build-in-pipelines)

## Running locally

### Build the image

```
docker build -t docker-build-base .
```

### Creates a container with project folder mapped (edit `~/Projects/gfgp-website` to match your checkout of the project)

```
docker run -dit -v ~/Projects/gfgp-website:/home/distelli/project --name docker-build-container docker-build-base
```

### Run the bash in the container as distelli

```
docker exec -u distelli -it docker-build-container /bin/bash
```


### In the container either run the `docker-run-tests.sh` script or run the individual commands from this script

```
/usr/local/bin/docker-run-tests.sh
```

#### View the display

##### Using VNC

You may be able to use VNC to view the firefox session using VNC https://stackoverflow.com/questions/12050021/how-to-make-xvfb-display-visible

##### Take a screenshot

Alternatively you can use `imagemagick` or similar to take a screenshot

Connect to the container as root to install `imagemagick`
```
docker exec -it docker-build-container /bin/bash
```

Install `imagemagick` in the container
```
apt-get install imagemagick
```

Disconnect and reconnect as distelli

```
docker exec -u distelli -it docker-build-container /bin/bash
```

Capture the screen using `import` in the container

```
DISPLAY=:99 import -window root ~/project/xvfb_screenshot.png
```

## Helper scripts


### Recreate the image and container 

*(change `/path/to/project` to the local path where the project was cloned)*

```
PROJECT_PATH=/path/to/project ./recreate-container.sh
```


### Run the tests in the container (rebuilds the container and executes docker-run-tests.sh)

*(change `/path/to/project` to the local path where the project was cloned)*

```
PROJECT_PATH=/path/to/project ./run-tests.sh
```
