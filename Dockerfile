FROM nginx

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install PHP 7 Repo
RUN apt-get update
RUN apt-get install -my wget apt-transport-https lsb-release ca-certificates gnupg
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c "echo 'deb https://packages.sury.org/php/ $(lsb_release -sc) main' > /etc/apt/sources.list.d/php.list"
RUN wget https://nginx.org/keys/nginx_signing.key -O - | apt-key add -

# Install Packages
RUN apt-get update && apt-get install -my \
  libssl-dev \
  supervisor \
  curl \
  php7.1-common \
  php7.1-cli \
  php7.1-curl \
  php7.1-fpm \
  php7.1-mysql \
  php7.1-mcrypt \
  php7.1-sqlite \
  php7.1-xdebug \
  php7.1-mbstring \
  php7.1-dev


RUN pecl channel-update pecl.php.net
RUN pecl install apcu

# Ensure that PHP7 FPM is run as root.
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.1/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php/7.1/fpm/pool.d/www.conf

# Prevent PHP Warning: 'xdebug' already loaded. XDebug loaded with the core
RUN sed -i '/.*xdebug.so$/s/^/;/' /etc/php/7.1/mods-available/xdebug.ini

# Add configuration files
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.1/fpm/conf.d/40-custom.ini
COPY conf/my.cnf /etc/mysql/my.cnf
