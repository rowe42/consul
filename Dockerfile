# Use Ruby 2.4.9 as base image
FROM ruby:2.5

ENV DEBIAN_FRONTEND noninteractive

# Install essential Linux packages
RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev postgresql-client nodejs imagemagick sudo libxss1 libappindicator1 libindicator7 unzip memcached

# Files created inside the container repect the ownership
#RUN adduser --shell /bin/bash --disabled-password --gecos "" consul \
#  && adduser consul sudo \
#  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN adduser --shell /bin/bash --disabled-password --gecos "" consul 
RUN adduser consul root 

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

COPY --chown=consul:root scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/consul

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY --chown=consul:root Gemfile Gemfile 

COPY --chown=consul:root Gemfile.lock Gemfile.lock

COPY --chown=consul:root Gemfile_custom Gemfile_custom

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Finish establishing our Ruby environment
RUN bundle install --full-index

# Install Chromium for E2E integration tests
RUN apt-get update -qq && apt-get install -y chromium

# Copy the Rails application into place
COPY  --chown=consul:root . .

#RUN adduser consul root
RUN groupmod -g 0 root 
RUN usermod -g 0 consul
RUN chown -R consul:root /var/www/consul
RUN chmod -R ug+rw /var/www/consul

#delete pem so we can overwrite it
RUN rm /usr/local/bundle/gems/httpclient-2.8.3/lib/httpclient/cacert.pem

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
# CMD [ "config/containers/app_cmd.sh" ]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
