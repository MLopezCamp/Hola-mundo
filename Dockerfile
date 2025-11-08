FROM php:8.2-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
      libzip-dev zip unzip git curl \
  && docker-php-ext-install pdo pdo_mysql mysqli zip \
  && a2enmod rewrite \
  && rm -rf /var/lib/apt/lists/*

# Permitir .htaccess en /var/www/html
RUN { \
      echo '<Directory /var/www/html/>'; \
      echo '  AllowOverride All'; \
      echo '  Require all granted'; \
      echo '</Directory>'; \
    } > /etc/apache2/conf-available/allowoverride.conf \
 && a2enconf allowoverride

WORKDIR /var/www/html


COPY . /var/www/html/

EXPOSE 80
CMD ["apache2-foreground"]
