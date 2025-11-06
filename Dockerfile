# Base image
FROM php:8.3

# Defined working directory
WORKDIR /projet

# Copy Laravel project into /projet directory
COPY app_laravel/ .

# Install PHP and PHP extensions
RUN apt update && apt-get install -y libfreetype-dev \
    git \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpq-dev \
    zip unzip \
   && curl -sS https://getcomposer.org/installer | php \
   && mv composer.phar /usr/local/bin/composer \
   && docker-php-ext-install bcmath pdo pgsql pdo_pgsql
   


# Expose port  
EXPOSE 8000 


RUN adduser www \
   && usermod -aG www www

RUN chmod u+x /projet/entrypoint.sh \
    && cp .env.example .env \
    && composer install \
    && php artisan key:generate

# RUN composer i && php artisan key:generate

RUN chown -R  www:www /projet \
  && chown -R 775  /projet/storage
 
USER www

# Start main process
#ENTRYPOINT ["/bin/bash"]
# ENTRYPOINT ["sleep", "100000000000000000000000000000000000000000000"]

ENTRYPOINT ["php","artisan","serve","--host","0.0.0.0"]
