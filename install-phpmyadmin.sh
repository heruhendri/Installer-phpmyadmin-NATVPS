#!/bin/bash

echo "=== Installer phpMyAdmin + Nginx + HTTPS by Hendri ==="

read -p "Masukkan domain untuk phpMyAdmin (contoh: my.hendri.site): " DOMAIN

echo "Updating system..."
apt update && apt upgrade -y

echo "Install Nginx..."
apt install nginx -y
systemctl enable nginx
systemctl start nginx

echo "Install PHP + extensions..."
apt install -y php php-fpm php-mysql php-mbstring php-zip php-gd php-json php-curl php-xml php-cli unzip

# Detect versi PHP-FPM otomatis
PHPVER=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
SOCK="/run/php/php${PHPVER}-fpm.sock"

if [ ! -S "$SOCK" ]; then
    echo "PHP-FPM tidak ditemukan di $SOCK, mencari otomatis..."
    SOCK=$(find /run/php -name "php*-fpm.sock" | head -n 1)
fi

echo "PHP-FPM socket: $SOCK"

echo "Restart PHP-FPM..."
systemctl restart php${PHPVER}-fpm || systemctl restart php-fpm

# Hapus folder phpMyAdmin lama jika ada
rm -rf /usr/share/phpmyadmin
mkdir -p /usr/share

echo "Download phpMyAdmin..."
cd /usr/share
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O pma.zip
unzip pma.zip
rm pma.zip
mv phpMyAdmin-*/ phpmyadmin

echo "Konfigurasi folder dan file..."
mkdir -p /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp

cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

# Random blowfish secret
SECRET=$(openssl rand -base64 32)
sed -i "s|\$cfg\['blowfish_secret'\] = ''|\$cfg['blowfish_secret'] = '$SECRET'|g" /usr/share/phpmyadmin/config.inc.php

echo "Setting permission..."
chown -R www-data:www-data /usr/share/phpmyadmin

echo "Membuat konfigurasi NGINX..."

cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /usr/share/phpmyadmin;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$SOCK;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        try_files \$uri =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

nginx -t && systemctl reload nginx

echo "Install Certbot + plugin NGINX..."
apt install certbot python3-certbot-nginx -y

echo "Generate HTTPS untuk $DOMAIN ..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "=== INSTALL SELESAI ==="
echo "phpMyAdmin dapat diakses di:"
echo "https://$DOMAIN"
