#!/bin/bash

service postgresql start
Xvfb :99 -ac &

exec "$@"
