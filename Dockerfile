# Ubuntu has the necessary framework to start from    
FROM ubuntu:16.04

# Run as root
USER root

# Create Distelli user
RUN useradd -ms /bin/bash distelli 

# Set /home/distelli as the working directory
WORKDIR /home/distelli
    
# Install prerequisites. This provides me with the essential tools for building with.
# Note. You don't need git. software-properties-common is needed for add-apt-repository
RUN apt-get update -y \
    && apt-get -y install build-essential checkinstall unzip git \
    && apt-get -y install libssl-dev openssh-client openssh-server \
    && apt-get -y install curl apt-transport-https ca-certificates \
    && apt-get -y install python3-dev python-virtualenv \
    && apt-get -y install postgresql libpq-dev postgresql-client postgresql-client-common


RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

## install chromedriver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port for chrome / firefox
ENV DISPLAY=:99

# Update the .ssh/known_hosts file:
RUN sh -c "ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts"

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh 

# Install node version manager as distelli user
USER distelli

ENV NVM_DIR /home/distelli/.nvm
ENV NODE_VERSION 6

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && npm install -g bower grunt-cli

COPY pg_hba.conf /etc/postgresql/9.5/main/

# Setup postgres user / role for distelli
USER postgres
RUN service postgresql start \
    && createuser distelli --createdb --createrole \
    && psql template1 -c "CREATE EXTENSION citext;"

# Ensure the final USER statement is "USER root"
USER root

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash"]
