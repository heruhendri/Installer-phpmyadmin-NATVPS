#!/bin/bash

DOMAIN="my.hendri.site"
PMA_PATH="/var/www/$DOMAIN/phpmyadmin"
MYSQL_USER="hendri"
MYSQL_PASS="rembulan"

echo "[*] Install dependencies..."
apt update -y
apt install -y nginx wget unzip php php-fpm php-mysql php-zip php-json php-mbstring php-cli php-xml php-curl certbot python3-certbot-nginx

# =====================================================
# AMBIL VERSI TERBARU VIA API RESMI PHPMyAdmin
# =====================================================
echo "[*] Mengambil versi phpMyAdmin terbaru..."
LATEST=$(wget -qO- https://www.phpmyadmin.net/home_page/version.json | grep -oP '"version":\s*"\K[^"]+')

if [ -z "$LATEST" ]; then
    echo "[ERROR] Gagal mengambil versi terbaru!"
    exit 1
fi

echo "[OK] Versi terbaru: $LATEST"

# =====================================================
# DOWNLOAD & EXTRACT FILE
# =====================================================
URL="https://files.phpmyadmin.net/phpMyAdmin/$LATEST/phpMyAdmin-$LATEST-all-languages.zip"

echo "[*] Download phpMyAdmin dari: $URL"
wget -O pma.zip "$URL"

echo "[*] Extract phpMyAdmin..."
unzip pma.zip
rm -f pma.zip

mv "phpMyAdmin-$LATEST-all-languages" "$PMA_PATH"
mkdir -p "$PMA_PATH/tmp"
chmod 777 "$PMA_PATH/tmp"

echo "[*] Set ownership..."
chown -R www-data:www-data "$PMA_PATH"

# =====================================================
# BUAT USER MYSQL
# =====================================================
echo "[*] Membuat user MySQL admin..."
mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

echo "[OK] User MySQL admin: $MYSQL_USER"

# =====================================================
# BUAT KONFIGURASI NGINX
# =====================================================
echo "[*] Membuat konfigurasi Nginx..."

cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root $PMA_PATH;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
nginx -t && systemctl reload nginx

# =====================================================
# ENABLE HTTPS CERTBOT
# =====================================================
echo "[*] Mengaktifkan HTTPS..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "============================================"
echo "phpMyAdmin berhasil diinstal!"
echo "URL: https://$DOMAIN"
echo "User MySQL admin: $MYSQL_USER"
echo "Password: $MYSQL_PASS"
echo "Directory: $PMA_PATH"
echo "============================================"
