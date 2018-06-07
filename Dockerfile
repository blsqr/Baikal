FROM php:apache
MAINTAINER martin scharm <https://binfalse.de/contact>

# we're working from /var/www, not /var/www/html
# the html directory will come with baikal
WORKDIR /var/www

# install tools necessary for the setup
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    unzip \
    git \
    ssmtp \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/* \
&& a2enmod expires headers

# for mail configuration see https://binfalse.de/2016/11/25/mail-support-for-docker-s-php-fpm/



# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && mkdir -p composer/packages \
 && php composer-setup.php --install-dir=composer \
 && php -r "unlink('composer-setup.php');" \
 && chown -R www-data: composer


# prepare destination
RUN rm -rf /var/www/html && chown www-data /var/www/
ADD composer.json /var/www/
ADD Core html /var/www/Core/
ADD html /var/www/html/

# install dependencies etc
USER www-data
RUN composer/composer.phar install


USER root



