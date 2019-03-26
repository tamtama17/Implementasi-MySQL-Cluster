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
![Ganti DocumentRoot dan ServerName](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar1.jpg "Ganti DocumentRoot dan ServerName")   

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
![Tampilan awal wordpress](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar2.jpg "Tampilan awal wordpress")   
Tinggal ikuti saja langkah-langkah instalasi yang ditentukan. Jika sudah selesai maka akan muncul tampilan login, lalu tinggal login sesuai akun yang sudah dibuat tadi.   
![Tampilan login wordpress](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar3.jpg "Tampilan login wordpress")   
Schema dari wordpress terbuat otomatis pada `service1` dan `service2`   
![Schema wordpress](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar4.jpg "Schema wordpress")   
### 3. Testing Fail Over
#### 1. Mematikan salah satu service node (service1)
```bash
sudo systemctl stop mysql
```
#### 2. Mengecek service1 sudah mati
![service1 mati](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar5.jpg "service1 mati")
#### 3. Membuat postingan baru dari wordpres (insert data)
![insert data](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar6.jpg "insert data")   

Ternyata ketika salah satu service node mati, wordpress masih bisa berjalan dengan lancar.
### 4. Pengukuran Response Time menggunakan JMeter
#### 1. Instalasi JMeter
1. Download ([link](https://jmeter.apache.org/download_jmeter.cgi)) dan extract file
2. Jalankan Jmeter dengan men-double klik `jmeter.bat` pada folder bin
![run JMeter](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar7.jpg "run JMeter")   
#### 2. Konfigurasi JMeter
1. Menambahkan Thread Group (User)
![tambah thread](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar8.jpg "tambah thread")   
![setup thread](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar9.jpg "setup thread")   
2. Menambahkan Config Element
![tambah config element](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar10.jpg "tambah config element")   
![setup request default](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar11.jpg "setup request default")   
3. Menambahkan Sampler
![tambah sampler](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar12.jpg "tambah sampler")   
![setup request](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar13.jpg "setup request")   
4. Menambahkan Listener
![tambah listener](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar14.jpg "tambah listener")   
#### 3. Hasil JMeter
![hasil JMeter](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/Tugas%20UTS/gambar/gambar15.jpg "hasil JMeter")   