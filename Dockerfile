# Imagen base de PHP con Apache
FROM php:8.2-apache

# Instala dependencias del sistema y extensiones de PHP necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev zip unzip git curl \
 && docker-php-ext-install pdo pdo_mysql mysqli zip \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Configura Apache para permitir .htaccess
RUN echo '<Directory /var/www/html/>' > /etc/apache2/conf-available/allowoverride.conf \
 && echo '    AllowOverride All' >> /etc/apache2/conf-available/allowoverride.conf \
 && echo '    Require all granted' >> /etc/apache2/conf-available/allowoverride.conf \
 && echo '</Directory>' >> /etc/apache2/conf-available/allowoverride.conf \
 && a2enconf allowoverride

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia el contenido del proyecto al contenedor
COPY . .

# Da permisos adecuados a los archivos (opcional pero recomendado)
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

# Expone el puerto 80
EXPOSE 80

# Comando por defecto para iniciar Apache
CMD ["apache2-foreground"]