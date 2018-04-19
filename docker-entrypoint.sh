#!/bin/bash

service postgresql start
Xvfb -ac :99 -screen 0 1024x768x24 &

exec "$@"
