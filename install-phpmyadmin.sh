#!/bin/bash

echo "=== Installer phpMyAdmin Nginx + HTTPS (By Hendri) ==="
sleep 1

read -p "Masukkan domain untuk phpMyAdmin (contoh: my.hendri.site): " DOMAIN
read -p "Masukkan password user MySQL admin: " MYSQLPASS

# -------------------------------------------
# Fix dpkg lock jika ada
# -------------------------------------------
echo "[*] Membersihkan dpkg lock..."
killall apt apt-get dpkg >/dev/null 2>&1
rm -f /var/lib/dpkg/lock-frontend
rm -f /var/lib/dpkg/lock
dpkg --configure -a

# -------------------------------------------
# Install deps
# -------------------------------------------
apt update -y
apt install -y nginx wget unzip curl gnupg php php-fpm php-mbstring php-zip php-gd php-json php-curl php-mysql

mkdir -p /var/www/$DOMAIN

# -------------------------------------------
# Ambil PHPMyAdmin versi terbaru AUTOMATIS
# -------------------------------------------
echo "[*] Mengambil informasi versi phpMyAdmin terbaru..."
LATEST=$(curl -s https://www.phpmyadmin.net/files/ | grep -oP "(?<=phpMyAdmin-)[0-9\.]+(?=/)" | head -1)

echo "Versi terbaru: $LATEST"

cd /tmp
wget https://files.phpmyadmin.net/phpMyAdmin/${LATEST}/phpMyAdmin-${LATEST}-all-languages.zip -O pma.zip

unzip pma.zip
rm -rf /var/www/$DOMAIN/phpmyadmin
mv phpMyAdmin-${LATEST}-all-languages /var/www/$DOMAIN/phpmyadmin

chown -R www-data:www-data /var/www/$DOMAIN/phpmyadmin

# -------------------------------------------
# Konfigurasi user MySQL admin
# -------------------------------------------
echo "[*] Membuat user MySQL admin..."

mysql -e "DROP USER IF EXISTS 'hendri'@'localhost';"
mysql -e "CREATE USER 'hendri'@'localhost' IDENTIFIED BY '${MYSQLPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'hendri'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

echo "[OK] User MySQL admin: hendri"

# -------------------------------------------
# Buat Nginx config
# -------------------------------------------
echo "[*] Membuat konfigurasi Nginx..."

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
# Install HTTPS
# -------------------------------------------
echo "[*] Mengaktifkan HTTPS dengan Certbot..."
apt install -y certbot python3-certbot-nginx

certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

# -------------------------------------------
# Selesai
# -------------------------------------------
echo "============================================"
echo "phpMyAdmin berhasil diinstal!"
echo "URL: https://$DOMAIN"
echo "User MySQL admin: hendri"
echo "Password: $MYSQLPASS"
echo "============================================"
