FROM ubuntu:16.04
MAINTAINER Arvind Rawat <support.engineer@medma.net>
ENV HTTPD_PREFIX /etc/apache2
RUN apt-get update && apt-get install -y \
    apache2 \
    curl \
    git \
    openssh-server \
    libapache2-mod-php \
    netcat \
    php \
    php-cli \
    php-curl \
    php-dom \
    php-intl \
    php-json \
    php-mbstring \
    php-mcrypt \
    php-mysql \
    php-zip \
    php-gd \
    s3cmd \
    rsyslog-gnutls \
    && phpenmod mcrypt \
    && apt-get clean

# Install extra utils
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && curl -o /usr/local/bin/whenavail https://bitbucket.org/silintl/docker-whenavail/raw/master/whenavail \
    && chmod a+x /usr/local/bin/whenavail

# Remove default site, configs, and mods not needed
WORKDIR $HTTPD_PREFIX
RUN rm -f \
    	sites-enabled/000-default.conf \
    	conf-enabled/serve-cgi-bin.conf \
    	mods-enabled/autoindex.conf \
    	mods-enabled/autoindex.load


RUN sed -i 's/AllowOverride None/AllowOverride All/' $HTTPD_PREFIX/apache2.conf;\
 sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 512M/" /etc/php/7.0/apache2/php.ini ;\
	 chown -R www-data:www-data /var/www/html ;
# Enable additional configs and mods
RUN ln -s $HTTPD_PREFIX/mods-available/expires.load $HTTPD_PREFIX/mods-enabled/expires.load \
    && ln -s $HTTPD_PREFIX/mods-available/headers.load $HTTPD_PREFIX/mods-enabled/headers.load \
	&& ln -s $HTTPD_PREFIX/mods-available/rewrite.load $HTTPD_PREFIX/mods-enabled/rewrite.load

VOLUME /var/www/html

EXPOSE 80
EXPOSE 22

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND
CMD /usr/bin/ssh -D FOREGROUND
