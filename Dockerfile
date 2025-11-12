# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile works for both development and production
# Development: docker compose up --build
# Production: docker build -t agendamento-medico . && docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value> agendamento-medico

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages for both dev and prod
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Environment can be overridden by docker-compose
ARG RAILS_ENV=production
ENV RAILS_ENV=$RAILS_ENV \
    BUNDLE_PATH="/usr/local/bundle"

# Set bundle config based on environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        bundle config set --local deployment 'true' && \
        bundle config set --local without 'development test'; \
    fi

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Conditional asset precompilation for production only
RUN if [ "$RAILS_ENV" = "production" ]; then \
        SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile; \
    fi

# Create user and set permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x bin/*

# Don't run as root in production, but allow flexibility for development
RUN if [ "$RAILS_ENV" = "production" ]; then \
        chown -R rails:rails /rails; \
    fi

# Use root for development to avoid permission issues
USER root

# Expose port (3000 for dev, 80 for prod)
EXPOSE 3000
EXPOSE 80

# Default command (can be overridden by docker-compose)
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
