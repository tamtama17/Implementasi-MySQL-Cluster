# Implementasi Aplikasi (Wordpress) pada MySQL Cluster dengan ProxySQL

### 1. Model Arsitektur
Cluster yang akan digunakan pada kali ini ada 7 buah server dengan spesifikasi seperti berikut

id | Hostname | IP Adrress | Deskripsi
--- | --- | --- | ---
1 | manager | 192.168.100.100 | Sebagai cluster manager
2 | data1 | 192.168.100.2 | Sebagai data node
3 | data1 | 192.168.100.3 | Sebagai data node
4 | data1 | 192.168.100.4 | Sebagai data node
11 | service1 | 192.168.100.11 | Sebagai service node (API)
12 | service1 | 192.168.100.12 | Sebagai service node (API)
|-| proxy | 192.168.100.21 | Sebagai proxySQL (Load Balancer) dan web server wordpress

### 2. Instalasi Wordpress
#### 1. Membuat database baru bernama `uts` dan berikan akses terhadap user `pguser`
```sql
CREATE DATABASE uts;
GRANT ALL PRIVILEGES ON uts.* TO 'pguser'@'%';
FLUSH PRIVILEGES;
```
#### 2. Install apache pada web server wordpress (proxy), dan kebutuhan php dari wordpress
```bash
sudo apt-get update
sudo apt install php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-imap php-ldap php-odbc php-pear php-snmp php-soap php-tidy
```
#### 3. Mendapatkan wordpress, lalu extract ke web root (/var/www/)
```bash
wget https://wordpress.org/latest.tar.gz
cd /var/www
sudo tar xpf ~/latest.tar.gz
sudo chown www-data:www-data /var/www/wordpress
```
#### 4. Konfigurasi web server
1. Meng-copy configurasi default untuk configurasi wordpress
```bash
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
```
2. Mengubah DocumentRoot dan ServerName
```bash
sudo nano /etc/apache2/sites-available/wordpress.conf
```
gambar1   

3. Mengaktifkan configurasi wordpress
```bash
sudo a2ensite wordpress.conf
```
4. Restart apache
```bash
sudo systemctl reload apache2
```
#### 5. Instalasi wordpress via browser
Jika konfigurasi web server sudah berhasil, kita bisa membuka wordpress yang sudah konfigurasi melalui browser menggunakan ip dari web server (192.168.100.21). Akan muncul tampilan seperti ini :   
gambar2   
Tinggal ikuti saja langkah-langkah instalasi yang ditentukan. Jika sudah selesai maka akan muncul tampilan login, lalu tinggal login sesuai akun yang sudah dibuat tadi.   
gambar3   
Schema dari wordpress terbuat otomatis pada `service1` dan `service2`   
gambar4   
### 3. Testing Fail Over
#### 1. Mematikan salah satu service node (service1)
```bash
sudo systemctl stop mysql
```
#### 2. Mengecek service1 sudah mati
gambar5
#### 3. Membuat postingan baru dari wordpres (insert data)
gambar6   

Ternyata ketika salah satu service node mati, wordpress masih bisa berjalan dengan lancar
### 4. Pengukuran Response Time menggunakan JMeter
