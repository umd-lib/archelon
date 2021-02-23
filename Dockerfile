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

EXPOSE 3000
CMD ["bin/archelon.sh"]
