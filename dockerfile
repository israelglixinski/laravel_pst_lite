# Use imagem PHP com Apache embutido
FROM php:8.2-apache

# Instale dependências essenciais
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libpq-dev && \
    docker-php-ext-install zip pdo pdo_mysql pdo_pgsql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilite o mod_rewrite do Apache
RUN a2enmod rewrite

# Defina o diretório de trabalho
WORKDIR /var/www/html

# Copie os arquivos da aplicação
COPY . .

# Instale o Composer a partir da imagem oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instale as dependências do Laravel
RUN composer install --optimize-autoloader --no-dev || true

# Ajuste permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Copie configuração customizada do Apache (se tiver)
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Exponha a porta 80 (Render redireciona para 10000+ externamente)
EXPOSE 80

# Comando para iniciar o Apache em foreground
CMD ["apache2-foreground"]
