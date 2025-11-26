#!/bin/bash

echo "=== Installer phpMyAdmin Nginx + HTTPS (By Hendri) ==="
sleep 1

read -p "Masukkan domain untuk phpMyAdmin (contoh: my.hendri.site): " DOMAIN
read -p "Masukkan password user MySQL admin: " MYSQLPASS

# -------------------------------------------
# Fix dpkg lock
# -------------------------------------------
killall apt apt-get dpkg >/dev/null 2>&1
rm -f /var/lib/dpkg/lock-frontend
rm -f /var/lib/dpkg/lock
dpkg --configure -a

apt update -y
apt install -y nginx wget unzip curl gnupg php php-fpm php-mbstring php-zip php-gd php-json php-curl php-mysql

mkdir -p /var/www/$DOMAIN
cd /tmp

# -------------------------------------------
# AMBIL VERSI TERBARU DARI API RESMI (FIX)
# -------------------------------------------
echo "[*] Mengambil versi terbaru phpMyAdmin dari API..."

LATEST=$(curl -s https://www.phpmyadmin.net/home_page/version.json | grep -oP '(?<="version": ")[^"]+')

echo "Versi terbaru ditemukan: $LATEST"

# -------------------------------------------
# Download File
# -------------------------------------------
FILE=phpMyAdmin-${LATEST}-all-languages.zip
URL=https://files.phpmyadmin.net/phpMyAdmin/${LATEST}/${FILE}

echo "[*] Download dari: $URL"

wget -O pma.zip $URL

if [ ! -f "pma.zip" ]; then
    echo "Download gagal! Periksa koneksi."
    exit 1
fi

unzip pma.zip
rm -rf /var/www/$DOMAIN/phpmyadmin
mv phpMyAdmin-${LATEST}-all-languages /var/www/$DOMAIN/phpmyadmin

chown -R www-data:www-data /var/www/$DOMAIN/phpmyadmin

# -------------------------------------------
# MySQL admin user
# -------------------------------------------
mysql -e "DROP USER IF EXISTS 'hendri'@'localhost';"
mysql -e "CREATE USER 'hendri'@'localhost' IDENTIFIED BY '${MYSQLPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'hendri'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# -------------------------------------------
# Nginx config
# -------------------------------------------
cat >/etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/$DOMAIN/phpmyadmin;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
nginx -t && systemctl reload nginx

# -------------------------------------------
# HTTPS
# -------------------------------------------
apt install -y certbot python3-certbot-nginx
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "============================================"
echo "phpMyAdmin berhasil diinstal!"
echo "URL: https://$DOMAIN"
echo "User MySQL admin: hendri"
echo "Password: $MYSQLPASS"
echo "============================================"
