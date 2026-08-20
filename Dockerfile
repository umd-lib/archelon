# syntax=docker/dockerfile:1
# check=error=true

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
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
# UMD Customization
WORKDIR /opt/archelon
# End UMD Customization

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
# UMD Customization
# Customized to add "libpq-dev" which is necessary for bundler to run
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config && \
    apt-get install --no-install-recommends -y libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
# End UMD Customization

# UMD Customization
# Install JavaScript dependencies
ARG NODE_VERSION=18.19.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master
# End UMD Customization

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# UMD Customization
# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
# End UMD Customization

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

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

# Run and own only the runtime files as a non-root user for security
# UMD Customization
# Set UID and GID to 2200 to match "plastron" user in "Dockerfile.sftp"
# which also needs to write to the directories in the container.
ARG USERNAME=rails
ARG UID=2200
ARG GID=2200
RUN groupadd -g $GID -o $USERNAME && \
   useradd $USERNAME -u $UID -g $GID --create-home --shell /bin/bash
USER $USERNAME:$USERNAME
# End UMD Customization

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"

# UMD Customization
COPY --chown=rails:rails --from=build /opt/archelon /opt/archelon
# End UMD Customization

# Entrypoint prepares the database.
# UMD Customization
ENTRYPOINT ["/opt/archelon/bin/docker-entrypoint"]
# End UMD Customization

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

# UMD Customization
CMD ["bin/docker_start.sh"]
# End UMD Customization
