# Dockerfile for the generating the Archelon Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/archelon:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
FROM ruby:2.6.3
WORKDIR /opt/archelon

# Install npm, to enable "yarn" to be installed
RUN apt update && \
    apt install -y npm && \
    apt install -y openssh-server && \
    rm -rf /var/lib/apt/lists/*


# Workaround until https://login.umd.edu gets a better SSL certificate
# This is intended to fix an "OpenSSL::SSL::SSLError (SSL_connect returned=1 errno=0 state=error: dh key too small)"
# error when connecting to https://login.umd.edu
RUN sed '/CipherString = DEFAULT@SECLEVEL=2/d' /etc/ssl/openssl.cnf > /etc/ssl/openssl.cnf.fixed && \
    mv /etc/ssl/openssl.cnf.fixed /etc/ssl/openssl.cnf

COPY ./Gemfile ./Gemfile.lock /opt/archelon/
RUN bundle install --deployment
COPY . /opt/archelon

RUN npm install --global yarn && \
    yarn

ENV RAILS_RELATIVE_URL_ROOT=
ENV SCRIPT_NAME=

# The following SECRET_KEY_BASE variable is used so that the
# "assets:precompile" command will run run without throwing an error.
# It will have no effect on the application when it is actually run.
#
# Similarly, the PROD_DATABASE_ADAPTER variable is needed for the
# "assets:precompile" Rake task to complete, but will have no effect
# on the application when it is actually run.
ENV SECRET_KEY_BASE=IGNORE_ME
RUN cd /opt/archelon/ && \
    PROD_DATABASE_ADAPTER=postgresql bundle exec rails assets:precompile && \
    cd .

# Add "plastron" user from SFTP
RUN useradd -ms /bin/bash plastron

# Set up directories for import/export
RUN mkdir -p /data/imports
RUN mkdir -p /data/exports
# Note: /data directory must be owned by root:root, and subdirectories
# should be owned by plastron
RUN chown -R plastron /data/*

# Set up SFTP
RUN echo "\
AllowGroups plastron \n\
\n\
Match Group plastron \n\
 ForceCommand internal-sftp \n\
 ChrootDirectory /data/ \n\
 PermitTunnel no \n\
 AllowAgentForwarding no \n\
 AllowTcpForwarding no \n\
 X11Forwarding no \n\
\n\
AuthorizedKeysCommand /opt/archelon/get_plastron_authorized_keys.sh \n\
AuthorizedKeysCommandUser nobody\
" >> /etc/ssh/sshd_config

EXPOSE 3000 22

CMD ["bin/docker_start.sh"]

