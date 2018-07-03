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
# Test back-end
DEFAULT_FILE_STORAGE=storages.backends.s3boto.S3BotoStorage \
AWS_STORAGE_BUCKET_NAME=gfgp-media \
AWS_LOCATION=gfgp-website-dev \
AWS_ACCESS_KEY_ID=AKIAJOQABE7KQ5W4OEBQ \
AWS_SECRET_ACCESS_KEY=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 \
exec $cmd
