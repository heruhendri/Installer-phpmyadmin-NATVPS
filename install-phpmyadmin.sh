#!/bin/bash

echo "=== Installer phpMyAdmin + Nginx + MySQL + HTTPS by Hendri ==="

# Input domain & password
read -p "Masukkan domain untuk phpMyAdmin (contoh: my.hendri.site): " DOMAIN
read -s -p "Masukkan password MySQL root yang ingin digunakan: " MYSQL_ROOT_PASS
echo ""

echo "Updating system..."
apt update && apt upgrade -y

echo "Install Nginx..."
apt install nginx -y
systemctl enable nginx
systemctl start nginx

echo "Install PHP + Extensions..."
apt install -y php php-fpm php-mysql php-mbstring php-zip php-gd php-json php-curl php-xml php-cli unzip

# AUTO DETECT PHP-FPM SOCKET
PHPVER=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
SOCK="/run/php/php${PHPVER}-fpm.sock"

if [ ! -S "$SOCK" ]; then
    echo "PHP-FPM socket tidak ditemukan, mencari otomatis..."
    SOCK=$(find /run/php -name "php*-fpm.sock" | head -n 1)
fi

echo "PHP-FPM socket digunakan: $SOCK"

echo "Restart PHP-FPM..."
systemctl restart php${PHPVER}-fpm || systemctl restart php-fpm

echo "Install MariaDB Server..."
apt install mariadb-server -y
systemctl enable mariadb
systemctl start mariadb

echo "=== Mengatur password MySQL root (compatible mode) ==="
mysql -e "UPDATE mysql.user SET authentication_string = PASSWORD('$MYSQL_ROOT_PASS') WHERE User='root';"
mysql -e "UPDATE mysql.user SET plugin='' WHERE User='root';"
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASS');"
mysql -e "FLUSH PRIVILEGES;"

echo "Password root MySQL telah diatur!"
echo "$MYSQL_ROOT_PASS" > /root/mysql-root-password.txt
echo "Disimpan ke /root/mysql-root-password.txt"

# HAPUS phpMyAdmin lama bila ada
rm -rf /usr/share/phpmyadmin
mkdir -p /usr/share

echo "Download phpMyAdmin..."
cd /usr/share
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O pma.zip
unzip pma.zip
rm pma.zip
mv phpMyAdmin-*/ phpmyadmin

echo "Konfigurasi phpMyAdmin..."
mkdir -p /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp

cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

# RANDOM BLOWFISH SECRET
SECRET=$(openssl rand -base64 32)
sed -i "s|\$cfg\['blowfish_secret'\] = ''|\$cfg['blowfish_secret'] = '$SECRET'|g" /usr/share/phpmyadmin/config.inc.php

chown -R www-data:www-data /usr/share/phpmyadmin

echo "Membuat konfigurasi NGINX untuk domain..."

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

echo "Install Certbot..."
apt install certbot python3-certbot-nginx -y

echo "Generate HTTPS untuk $DOMAIN ..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo ""
echo "=== INSTALL SELESAI ==="
echo "phpMyAdmin dapat diakses di: https://$DOMAIN"
echo "MySQL Root Password: $MYSQL_ROOT_PASS"
echo "Lokasi penyimpanan password: /root/mysql-root-password.txt"
echo ""
echo "Installer by Hendri selesai!"

# ----------- HAPUS FILE INSTALLER ----------
SCRIPT_NAME=$(basename "$0")

echo "Menghapus file installer: $SCRIPT_NAME"
rm -f "$SCRIPT_NAME"

echo "Installer telah dihapus!"
