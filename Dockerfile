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
RUN apt-get update && \
    apt-get install -y npm openssh-server netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

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
RUN PROD_DATABASE_ADAPTER=postgresql bundle exec rails assets:precompile

# Set up volumes for import/export
VOLUME /var/opt/archelon/imports
VOLUME /var/opt/archelon/exports

EXPOSE 3000

CMD ["bin/docker_start.sh"]
