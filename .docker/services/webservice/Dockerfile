ARG IMG_DB_VERSION=20.04
FROM ubuntu:${IMG_DB_VERSION}

LABEL MAINTAINER="Ton Gomes"

## ARGs
ARG DOCKER_ENV
ARG WORK_DIR=/var/www
ARG NODE_LTS_VERSION=16
ARG DOCKER_USER_ID=1337
ARG DOCKER_GROUP_ID=1337
ARG DOCKER_USER=duser
ARG DEBIAN_FRONTEND=noninteractive

## Set ENV variables
ENV TZ America/Sao_Paulo
ENV COMPOSER_MEMORY_LIMIT -1

## Set Timezone to UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Update package list and install main sytem utils
RUN apt-get update && apt-get install -f -y --no-install-recommends gnupg gosu nano curl wget gnupg2 ca-certificates lsb-release \
  apt-transport-https software-properties-common \
  zip unzip gzip git supervisor sqlite3 libpng-dev python2

## Install Nginx
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key  | gpg --dearmor -o /usr/share/keyrings/nginx-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/nginx-keyring.gpg] https://nginx.org/packages/$(lsb_release -is | sed -e 's/\(.*\)/\L\1/') $(lsb_release -cs) nginx" \
  | tee /etc/apt/sources.list.d/nginx.list \
  && apt-get update && apt-get install -f -y --no-install-recommends nginx

## Install Node JS
RUN curl -sL "https://deb.nodesource.com/setup_${NODE_LTS_VERSION}.x" | bash - \
  && apt-get update && apt-get install -f -y --no-install-recommends nodejs && npm install -g npm@latest

## Install YARN
RUN  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
  && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" \
  | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get install yarn

# Install PostgreSQL Client
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update && apt-get install -f -y --no-install-recommends postgresql-client

## Install MySQL Client
# Get key from pgp.mit.edu or keyserver.ubuntu.com
RUN echo "deb https://repo.mysql.com/apt/$(lsb_release -is | sed -e 's/\(.*\)/\L\1/')/ $(lsb_release -cs) mysql-8.0" >> /etc/apt/sources.list.d/mysql.list \
  && apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29 \
  && apt-get update && apt-get install -f -y --no-install-recommends mysql-client

# Install PHP
RUN add-apt-repository ppa:ondrej/php \
  && apt-get update && apt-get install -f -y --no-install-recommends \
  php8.1 php8.1-cli php8.1-fpm \
  php8.1-pgsql php8.1-sqlite3 php8.1-gd php8.1-mongodb \
  php8.1-curl \
  php8.1-opcache \
  php8.1-mcrypt php8.1-uuid \
  php8.1-imap php8.1-mysql php8.1-mbstring \
  php8.1-xml php8.1-zip php8.1-bz2 php8.1-bcmath php8.1-soap \
  php8.1-intl php8.1-readline \
  php8.1-ldap \
  php8.1-msgpack php8.1-igbinary php8.1-redis \
  php8.1-memcached php8.1-pcov \
  php-pear

## Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

## Clear APT cache
RUN apt-get -f -y --no-install-recommends autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Create default user for this image
RUN groupadd --force -g ${DOCKER_GROUP_ID} ${DOCKER_USER}
RUN useradd -ms /bin/bash --no-user-group -g ${DOCKER_GROUP_ID} -u ${DOCKER_USER_ID} ${DOCKER_USER}

## Create required folders and files
RUN mkdir -p /run/nginx  \
  && mkdir -p /run/php  \
  && mkdir -p /run/supervisor  \
  && mkdir -p /var/log/php \
  && ls /var/log \
  && chown -R ${DOCKER_USER_ID}:${DOCKER_USER} /var/log/* \
  && chmod -R 775 /var/log/*

## Loading PHP ini
COPY .docker/services/webservice/php/fpm/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY .docker/services/webservice/php/fpm/pool.d/www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY .docker/services/webservice/php/php.ini /etc/php/8.1/cli/php.ini
COPY .docker/services/webservice/php/php.ini /etc/php/8.1/fpm/php.ini

## Nginx config files
COPY .docker/services/webservice/nginx/nginx.conf /etc/nginx/nginx.conf
COPY .docker/services/webservice/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

## Set working directory, this is where it all happens.
RUN rm -rf ${WORK_DIR}/html
WORKDIR ${WORK_DIR}

# Configure Supervisor
COPY .docker/scripts/docker-entry-point.sh /usr/local/bin/docker-entry-point
COPY .docker/services/webservice/supervisor/ /etc/supervisor/
RUN ls /etc/supervisor
RUN chmod +x /usr/local/bin/docker-entry-point

# Additional scripts
COPY .docker/scripts/reload-permissions.sh /usr/bin/reload-permissions
COPY .docker/scripts/before-start.sh /usr/bin/before-start
RUN chmod +x /usr/bin/reload-permissions \
  && chmod +x /usr/bin/before-start

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["docker-entry-point"]
