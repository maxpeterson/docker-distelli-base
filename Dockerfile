# Ubuntu has the necessary framework to start from    
FROM ubuntu:16.04

# Run as root
USER root

# Create Distelli user
RUN useradd -ms /bin/bash distelli 

# Set /home/distelli as the working directory
WORKDIR /home/distelli
    
# Install prerequisites. This provides me with the essential tools for building with.
RUN apt-get update -y \
    && apt-get -y install build-essential checkinstall git \
    && apt-get -y install libcurl4-openssl-dev libssl-dev openssh-client openssh-server \
    && apt-get -y install curl apt-transport-https ca-certificates \
    && apt-get -y install poppler-utils \
    && apt-get -y install python3-dev python3-pip python-virtualenv \
    && apt-get -y install postgresql libpq-dev postgresql-client postgresql-client-common postgresql-contrib postgis \
    && apt-get -y install xvfb firefox

# Downland the linux64 geckodriver
RUN wget -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v0.18.0/geckodriver-v0.18.0-linux64.tar.gz \
    && tar -C /usr/local/bin/ -xaf /tmp/geckodriver.tar.gz geckodriver

# Install the AWS-CLI
RUN pip3 --no-cache-dir install --upgrade pip awscli

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
    && nvm install $NODE_VERSION

COPY pg_hba.conf /etc/postgresql/9.5/main/

# Setup postgres user / role for distelli
USER postgres
RUN service postgresql start \
    && createuser distelli --createdb --createrole \
    && psql template1 -c "CREATE EXTENSION citext; CREATE EXTENSION postgis;"

# Ensure the final USER statement is "USER root"
USER root

COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-run-tests.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash"]
