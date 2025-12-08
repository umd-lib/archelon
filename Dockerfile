# syntax = docker/dockerfile:1

# UMD Customization
# Dockerfile for the generating the Archelon Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/archelon:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
# End UMD Customization

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.9
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
# UMD Customization
WORKDIR /opt/archelon
# End UMD Customization

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
# UMD Customization
# Customized to add "libpq-dev" which is necessary for bundler to run
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libvips node-gyp pkg-config python-is-python3 && \
    apt-get install --no-install-recommends -y libpq-dev libyaml-dev
# End UMD Customization

# Install JavaScript dependencies
ARG NODE_VERSION=18.19.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# UMD Customization
#
# There are several environment variables that must be defined when running
# the "assets:precompile" Rake task, but will have no effect on the application
# when it is actually run.
# XXX: ideally, the Rails initializers should be tweaked so that this is not necessary
RUN SECRET_KEY_BASE_DUMMY=1 \
    ARCHELON_DATABASE_ADAPTER=postgresql \
    IIIF_VIEWER_URL_TEMPLATE=x \
    ./bin/rails assets:precompile
# End UMD Customization


# Final stage for app image
FROM base

# Install packages needed for deployment
# UMD Customization - install netcat, for checking if the database is available,
#                     npm (so Node is available as the JavaScript runtime),
#                     libpq-dev for Postgres (required by the "pg" gem),
#                     and libyaml-dev (required by the "psych" gem).
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    apt-get install --no-install-recommends -y libpq-dev npm netcat-openbsd libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
# End UMD Customization

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle

# UMD Customization
COPY --from=build /opt/archelon /opt/archelon
# End UMD Customization

# Run and own only the runtime files as a non-root user for security
# Set UID and GID to 2200 to match "plastron" user in "Dockerfile.sftp"
# which also needs to write to the directories in the container.
ARG USERNAME=rails
ARG UID=2200
ARG GID=2200
RUN groupadd -g $GID -o $USERNAME
RUN useradd $USERNAME -u $UID -g $GID --create-home --shell /bin/bash && \
    chown -R $USERNAME:$USERNAME db log storage tmp
USER $USERNAME:$USERNAME

# Entrypoint prepares the database.
# UMD Customization
ENTRYPOINT ["/opt/archelon/bin/docker-entrypoint"]
# End UMD Customization

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

# UMD Customization
CMD ["bin/docker_start.sh"]
# End UMD Customization
