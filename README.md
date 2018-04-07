# docker-distelli-base

Create a Docker build image for Distelli / pipelines.puppet.com.

Based on steps in https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html

## Updating the Image

If the Dockerfile is updated then it will trigger distelli / pipelines.puppet.com to generate a new image. This image will need to be [set as a *Build Image*](https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html#set-build-image).

Any distelli / pipelines.puppet.com builds that should use the image will then need to have the [*Build Options* updated to use the new image](https://puppet.com/docs/pipelines-for-apps/free/docker-build-image.html#using-custom-docker-images-to-build-in-pipelines)

