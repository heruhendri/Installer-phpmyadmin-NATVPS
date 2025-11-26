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

User admin MySQL yang dibuat:

* **Username:** sesuai input
* **Password:** sesuai input
* Akses: FULL ROOT PRIVILEGE

---
