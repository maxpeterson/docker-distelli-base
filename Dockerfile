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
    && apt-get -y install build-essential checkinstall git \
    && apt-get -y install libssl-dev openssh-client openssh-server \
    && apt-get -y install curl apt-transport-https ca-certificates \
    && apt-get -y install python3-dev python-virtualenv \
    && apt-get -y install postgresql libpq-dev postgresql-client postgresql-client-common

# Update the .ssh/known_hosts file:
RUN sh -c "ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts"

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh 

# Install docker
# Note. This is only necessary if you plan on building docker images
#RUN apt-get -y install software-properties-common \
#    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
#    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
#    && apt-get update -y \
#    && apt-get install -y docker-ce \
#    && sh -c 'curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose' \
#    && chmod +x /usr/local/bin/docker-compose \
#    && docker -v

# Setup a volume for writing docker layers/images
#VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && chmod +x /bin/gosu

# Install node version manager as distelli user
USER distelli

ENV NVM_DIR /home/distelli/.nvm
ENV NODE_VERSION 6

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && npm install -g bower grunt-cli

# Setup postgres user / role for distelli
USER postgres
RUN service postgresql start && createuser distelli --createdb --createrole

# Ensure the final USER statement is "USER root"
USER root

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash"]
