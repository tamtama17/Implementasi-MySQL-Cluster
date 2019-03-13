cd ~
wget https://dev.mysql.com/get/Download/MySQL-Cluster-7.6/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar
mkdir install
tar -xvf mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/

sudo apt update
sudo apt install libaio1 libmecab2

sudo dpkg -i install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-cluster-community-server_7.6.9-1ubuntu18.04_amd64.deb
sudo dpkg -i install/mysql-server_7.6.9-1ubuntu18.04_amd64.deb

sudo cp /vagrant/server/my.cnf /etc/mysql/

sudo systemctl restart mysql
sudo systemctl enable mysql
