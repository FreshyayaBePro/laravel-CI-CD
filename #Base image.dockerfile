#Base image
FROM php:8.4


#Defined working directory

WORKDIR /project

#Copy laravel project in /project directory

COPY app .

#Install php and php extensions

RUN apt update && apt-get install -y libfreetype-dev \
	libjpeg62-turbo-dev \
	libpq-dev \
	libpng-dev \
	zip \
	unzip \ 
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer \
&& docker-php-ext-install pgsql pdo pdo_pgsql \
&& composer install
#Start main proccess

EXPOSE 8000

RUN adduser www \
    && usermod -aG www www
   
#Generate key and run migrations



RUN chmod u+x /project/entrypoint.sh \
     && composer install \
     && php artisan key:generate
     
RUN chown -R www:www /project \
    && chmod -R 775 /project/storage


USER www

#ENTRYPOINT ["/bin/bash"]

ENTRYPOINT ["sleep", "100000000000000000000000000000000000000000000"]

#ENTRYPOINT ["php","artisan","serve","--host","0.0.0.0"]



#Définir les services app et db
services:
  app: 
     build: . #Créer une image à partir de Dockerfile courant 
     image: magasincrts
     #entrypoint: /project/entrypoint.sh
     entrypoint: ["/bin/bash","project/entrypoint.sh"]
     restart: unless-stopped 
     ports: 
       - "7000:8000"
     volumes:
     	- ./app:/project 
     depends_on: 
       - db
  db:
    image: postgres:15
    volumes:
      - dbdata:/var/lib/postgresql/data
    env_file:
      - .db.env
      - ./app/.env
        # environment: 
        # - POSTGRES_USER=${DB_USERNAME}
        # - POSTGRES_DB=${DB_DATABASE}
        # - POSTGRES_PASSWORD=${DB_PASSWORD}

volumes:
    dbdata: