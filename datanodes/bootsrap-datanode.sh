sudo apt update -y
sudo apt install libclass-methodmaker-perl -y

sudo dpkg -i /vagrant/datanodes/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb

sudo cp /vagrant/datanodes/my.cnf /etc/

sudo mkdir -p /usr/local/mysql/data

sudo ndbd

sudo ufw allow from 192.168.100.100
sudo ufw allow from 192.168.100.2
sudo ufw allow from 192.168.100.3
sudo ufw allow from 192.168.100.4
sudo ufw allow from 192.168.100.11
sudo ufw allow from 192.168.100.12

sudo pkill -f ndbd

sudo cp /vagrant/datanodes/ndbd.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable ndbd

sudo systemctl start ndbd

sudo systemctl status ndbd
