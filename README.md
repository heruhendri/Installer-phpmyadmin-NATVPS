Siap Hendri! Saya buatkan **installer otomatis** yang lengkap:

✔ Install Nginx
✔ Install PHP & ekstensi
✔ Install MySQL server
✔ Install phpMyAdmin manual (tidak pakai paket apt, jadi anti-error)
✔ Setup domain (contoh: `my.hendri.site`)
✔ Setup HTTPS Certbot
✔ Membuat **user MySQL khusus untuk phpMyAdmin (admin penuh)**
✔ Auto konfigurasi Nginx + folder phpmyadmin

Cukup copy–paste script ini.

---
# 📌LINK INSTALL AUTO

```bash
wget https://raw.githubusercontent.com/heruhendri/Installer-phpmyadmin-NATVPS/main/install-phpmyadmin.sh
chmod +x install-phpmyadmin.sh
./install-phpmyadmin.sh
```

## 🚀 **INSTALLER phpMyAdmin + NGINX + HTTPS + USER ADMIN**

> **Sebelum menjalankan, ganti `DOMAINKU` menjadi domain kamu (contoh: my.hendri.site)**



---

# 🎉 SELESAI

Setelah selesai, phpMyAdmin bisa diakses di:

👉 **[https://my.hendri.site](https://my.hendri.site)**

User admin MySQL yang dibuat:

* **Username:** sesuai input
* **Password:** sesuai input
* Akses: FULL ROOT PRIVILEGE

---
