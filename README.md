# 🚀 **INSTALLER phpMyAdmin + NGINX + HTTPS + USER ADMIN**
* ✔ Install Nginx
* ✔ Install PHP & ekstensi
* ✔ Install MySQL server
* ✔ Install phpMyAdmin manual (tidak pakai paket apt,    jadi anti-error)
* ✔ Setup domain (contoh: `my.hendri.site`)
* ✔ Setup HTTPS Certbot
* ✔ Membuat **user MySQL khusus untuk phpMyAdmin (admin penuh)**
* ✔ Auto konfigurasi Nginx + folder phpmyadmin

Cukup copy–paste script ini.

---
### 📷SCRENSHOOT ![](https://github.com/heruhendri/Installer-phpmyadmin-NATVPS/blob/main/ss.png)
---

> **Sebelum menjalankan, ganti `DOMAINKU` menjadi domain kamu (contoh: phpmyadmin.hendri.site)**

## 📌 LINK INSTALL AUTO

```bash
wget https://raw.githubusercontent.com/heruhendri/Installer-phpmyadmin-NATVPS/main/install-phpmyadmin.sh
chmod +x install-phpmyadmin.sh
./install-phpmyadmin.sh
```

## ⚠️ INSTALASI MANUAL
#### 1️⃣ Download Link Install
```bash
git clone https://github.com/heruhendri/Installer-phpmyadmin-NATVPS.git
```
#### 2️⃣ Masuk Direktori 
```bash
cd installer-phpmyadmin-NATVPS
```
### 3️⃣ Install

```bash
chmod +x install-phpmyadmin.sh
./install-phpmyadmin.sh
```




# 🎉 SELESAI

Setelah selesai, phpMyAdmin bisa diakses di:

👉 **[https://Domain.com](https://Domain.com)**



## BUAT USER NAME DATABES

# ✅ **DISARANKAN: Buat user admin khusus untuk phpMyAdmin**

Tidak disarankan pakai `root`. Buat user baru:

### 1. Masuk MySQL sebagai root:

```bash
sudo mysql
```

### 2. Buat user admin:

```sql
CREATE USER 'hendri'@'localhost' IDENTIFIED BY 'passwordku123';
```

### 3. Beri akses penuh:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'hendri'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

### 4. Login di phpMyAdmin:

```
username: hendri
password: passwordku123
```

Langsung bisa masuk.

---

# 🔥 **SOLUSI 2: Izinkan root login via password (tidak aman)**

Kalau kamu tetap mau login root dari phpMyAdmin, lakukan:

### 1. Masuk MySQL:

```bash
sudo mysql
```

### 2. Ubah root ke mode password:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password_root_baru';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Restart MySQL:

```bash
sudo systemctl restart mysql
```

### 4. Login di phpMyAdmin:

```
username: root
password: password_root_baru
```

---

# ⚠ Keamanan untuk NATVPS

Jika phpMyAdmin diakses via domain publik (seperti **my.hendri.site**):

✓ Jangan gunakan user **root**
✓ Gunakan user terpisah seperti `hendri`
✓ Bisa batasi IP, misalnya hanya kamu yang bisa akses:

```nginx
allow 1.2.3.4;
deny all;
```

Kalau mau saya bisa buatkan installer phpMyAdmin versi **aman dengan firewall IP**.

---


User admin MySQL yang dibuat:

* **Username:** sesuai input
* **Password:** sesuai input
* Akses: FULL ROOT PRIVILEGE

---
