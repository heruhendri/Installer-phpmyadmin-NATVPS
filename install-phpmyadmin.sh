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

echo "Restart PHP-FPM..."
systemctl restart php8.2-fpm || systemctl restart php-fpm

echo "Download phpMyAdmin..."
mkdir -p /usr/share/phpmyadmin
cd /usr/share/phpmyadmin

wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip
unzip phpMyAdmin-latest-all-languages.zip
rm phpMyAdmin-latest-all-languages.zip

mv phpMyAdmin-*/ phpmyadmin

echo "Membuat folder temp & config..."
mkdir -p /usr/share/phpmyadmin/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/phpmyadmin/tmp

cp /usr/share/phpmyadmin/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/phpmyadmin/config.inc.php

# Random blowfish secret
SECRET=$(openssl rand -base64 32)
sed -i "s|\$cfg\['blowfish_secret'\] = ''|\$cfg['blowfish_secret'] = '$SECRET'|g" /usr/share/phpmyadmin/phpmyadmin/config.inc.php

echo "Setting permission..."
chown -R www-data:www-data /usr/share/phpmyadmin

echo "Membuat konfigurasi NGINX untuk domain $DOMAIN..."

cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /usr/share/phpmyadmin/phpmyadmin;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        try_files \$uri =404;
    }
}
EOF

ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

nginx -t && systemctl reload nginx

echo "Install certbot..."
apt install certbot python3-certbot-nginx -y

echo "Generate HTTPS untuk $DOMAIN ..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "Selesai! phpMyAdmin dapat diakses di:"
echo "https://$DOMAIN"
