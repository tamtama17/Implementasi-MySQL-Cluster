# Implementasi MySQL Cluster

### 1. Arsitektur Server
Dalam tutorial ini kita akan menggunakan 6 server dengan rincian sebagai berikut :   
1. 1 buah server Cluster Manager dengan IP : 192.168.100.100
2. 3 buah server Data Node dengan IP : 192.168.100.2, 192.168.100.3, dan 192.168.100.4
3. 2 buah server Service Node dengan IP :  192.168.100.11 dan 192.168.100.12

### 2. Config Virtual Machine
Untuk membuat semua server kita hanya perlu melakukan command `vagrant up` pada folder dimana kita menyimpan file `Vagrantfile`. Semua machine otomatis akan terbuat dengan spesifikasi yang tertera pada file `Vagrantfile`.

### 3. Installing Cluster Manager
Untuk installing Cluster Manager sebenarnya sudah dijalankan ketika kita melakukan `vagrant up` karena masuk dalam provisioning. Namun, saya akan menjelaskan tahapan kerjanya.
1. Yang pertama adalah kita harus menginstall paket MySQL Cluster yang sudah ada di folder `manager`, kita tinggal menginstall dengan cara :
```sh
sudo dpkg -i /vagrant/manager/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb
```
2. Melakukan konfigurasi pada file `config.ini` yang berada pada `/var/lib/mysql-cluster`. Kita hanya tinggal meng-copy file `config.ini` yang sudah disediakan di folder `manager` dengan cara :
```sh
sudo mkdir /var/lib/mysql-cluster
sudo cp /vagrant/manager/config.ini /var/lib/mysql-cluster/
```
3. Menjalankan cluster manager
Untuk menjalankan cluster manager tinggal menjalakan perintah :
```sh
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini
```
4. Otomasi cluster manager
Agar cluster manager siap diguanakan setelah booting, kita harus menyeting beberapa hal. Pertama kita harus memastikan bahwa proses sudah mati, selanjutnya baru kita bisa menyeting otomasi dengan cara :
```sh
sudo pkill -f ndb_mgmd
sudo cp /vagrant/manager/ndb_mgmd.service /etc/systemd/system/ndb_mgmd.service
sudo systemctl daemon-reload
sudo systemctl enable ndb_mgmd
sudo systemctl start ndb_mgmd
<<<<<<< Updated upstream
```
=======
```   
![Service Node running](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/gambar/manager_running.jpg "Service Node running")   
>>>>>>> Stashed changes

### 4. Installing Data Node
Untuk installing Data Node sebenarnya sudah dijalankan ketika kita melakukan `vagrant up` karena masuk dalam provisioning. Namun, saya akan menjelaskan tahapan kerjanya.
1. Install dependensi dari `data node binary` yaitu `libclass-methdmaker-perl` dengan cara :
```sh
sudo apt update -y
sudo apt install libclass-methodmaker-perl -y
```
2. Install `data node binary` yang disediakan MySQL yang sudah ada pada folder `datanodes` dengan cara :
```sh
sudo dpkg -i /vagrant/datanodes/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb
```
3. Konfigurasi data node
Untuk membuat configurasi Data Node kita harus membuat file `my.cnf` yang berisi alamat manager yang sudah kita buat sebelumnya pada folder `/etc/`. Karena sudah ada yang jadi, maka kita tinggal meng-copy nya dengan cara :
```sh
sudo cp /vagrant/datanodes/my.cnf /etc/
sudo mkdir -p /usr/local/mysql/data
```
4. Menjalankan data node
Untuk menjalankan data node tinggal menjalakan perintah :
```sh
sudo ndbd
```
5. Otomasi data node
Sama seperti otomasi pada cluster manager, kita bisa menyetingnya dengan menjalakan perintah seperti ini :
```sh
sudo pkill -f ndbd
sudo cp /vagrant/datanodes/ndbd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ndbd
sudo systemctl start ndbd
```
### 5. Installing Service Node
1. Install dependensi dari `MySQL Server binary` yaitu `libaio1` dan `libmecab2` dengan cara :
```sh
sudo apt update
sudo apt install libaio1 libmecab2
```
2. Install dependensi dari `MySQL Cluster` yang disediakan MySQL yang sudah ada pada folder `server` dengan cara mengekstraknya terlebih dahulu dari file `mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar` dengan cara :
```sh
mkdir install # membuat folder untuk penyimpanan package bundle hasil extract
tar -xvf /vagrant/server/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/

sudo dpkg -i install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-cluster-community-server_7.6.9-1ubuntu18.04_amd64.deb
```
p.s : saat menginstall paket yang terakhir anda akan diminta password untuk akun root MySQL database anda.

3. Install `MySQL server binary` dengan cara :
```sh
sudo dpkg -i install/mysql-server_7.6.9-1ubuntu18.04_amd64.deb
```
4. Konfigurasi service node
Untuk membuat configurasi Service Node kita harus membuat file `my.cnf` yang berisi alamat manager yang sudah kita buat sebelumnya dan engine apa yang kita gunakan(dalam kasus ini ndbcluster) pada folder `/etc/mysql/`. Karena sudah ada yang jadi, maka kita tinggal meng-copy nya dengan cara :
```sh
sudo cp /vagrant/server/my.cnf /etc/mysql/
```
5. Me-restart MySQL agar me-load settingan yang sudah kita jalankan dengan syntax :
```sh
sudo systemctl restart mysql
sudo systemctl enable mysql
```
Untuk instalasi Service Node tidak dimasukkan provisioning dan berjalan saat `vagrant up` karena ada instalasi yang butuh input user sedangkan provisioning tidak mendukung hal itu. Oleh karena itu, saya membuat file bash siap pakai agar semua konfigurasi tinggal dijalankan sekali perintah dengan cara :
```sh
sudo bash /vagrant/server/bootstrap-server.sh
```
### 6. Testing Service Node
1. Untuk mengetahui Service Node sudah bisa dipakai kita bisa menjalankan perintah :
```sh
ndb_mgm
```
<<<<<<< Updated upstream
   Lalu ketik perintah `show`. Jika muncul gambar seperti dibawah maka Service Node sudah siap pakai.   
   ![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Service Node running")   
=======
Lalu ketik perintah `show`. Jika muncul gambar seperti dibawah maka Service Node sudah siap pakai.   
![Service Node running](https://github.com/tamtama17/Implementasi-MySQL-Cluster/blob/master/gambar/manager_running.jpg "Service Node running")   
>>>>>>> Stashed changes
2. Create database