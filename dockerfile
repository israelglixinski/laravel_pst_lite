# Use uma imagem PHP com Apache já embutido para ocupar menos espaço
FROM php:8.2-apache

# Instale dependências essenciais
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev && \
    docker-php-ext-install zip pdo pdo_mysql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilite o mod_rewrite do Apache
RUN a2enmod rewrite

# Configure o diretório de trabalho
WORKDIR /var/www/html

# Copie os arquivos
COPY . .

# Instale o Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instale dependências do Laravel
RUN composer install --optimize-autoloader --no-dev

# Ajuste permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Exponha a porta
EXPOSE 80

CMD ["apache2-foreground"]
