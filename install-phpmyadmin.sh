#!/bin/bash
echo "=== Installer phpMyAdmin Full Nginx + HTTPS + User Admin (FIXED VERSION) ==="
sleep 1

# ====== SET DOMAIN ======
read -p "Masukkan domain untuk phpMyAdmin (contoh: my.hendri.site): " DOMAIN

echo "Domain = $DOMAIN"
sleep 1

# ====== UPDATE SERVER ======
apt update && apt upgrade -y

# ====== INSTALL NGINX ======
apt install nginx -y
systemctl enable nginx
systemctl start nginx

# ====== INSTALL PHP ======
apt install -y php php-fpm php-mysql php-mbstring php-gettext php-zip php-gd php-json php-curl php-xml

# ====== INSTALL MYSQL ======
apt install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

# ====== CREATE MYSQL ADMIN USER ======
echo "Membuat user admin MySQL untuk phpMyAdmin"
read -p "Masukkan username admin MySQL (contoh: pmaadmin): " PMAUSER
read -p "Masukkan password admin MySQL: " PMAPASS

mysql -u root <<MYSQL_SCRIPT
CREATE USER '$PMAUSER'@'localhost' IDENTIFIED BY '$PMAPASS';
GRANT ALL PRIVILEGES ON *.* TO '$PMAUSER'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "User admin MySQL berhasil dibuat."

# ====== INSTALL phpMyAdmin MANUAL (FIXED VERSION 5.2.1) ======
mkdir -p /usr/share/phpmyadmin
cd /usr/share/phpmyadmin

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz
mv phpMyAdmin-5.2.1-all-languages/* .
rm -rf phpMyAdmin-5.2.1-all-languages*
mkdir -p tmp
chmod 777 tmp

# ====== NGINX CONFIG ======
cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /usr/share/phpmyadmin;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# ====== INSTALL HTTPS ======
apt install certbot python3-certbot-nginx -y
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

# ====== SELESAI ======
echo "============================================"
echo "phpMyAdmin berhasil diinstal!"
echo "Akses: https://$DOMAIN"
echo "User MySQL admin: $PMAUSER"
echo "Password: $PMAPASS"
echo "============================================"
