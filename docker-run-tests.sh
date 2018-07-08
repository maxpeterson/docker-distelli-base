#!/bin/bash

cmd=${@:-make test-live}

cd ~/project

# Create the database
createdb gfgp
# Install back-end
virtualenv ~/.venv --python=`which python3`
source ~/.venv/bin/activate
pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput
# Install and build front-end
source $NVM_DIR/nvm.sh
nvm use 6
npm install
bower install
grunt build

exec $cmd
