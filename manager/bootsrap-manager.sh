sudo dpkg -i /vagrant/manager/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb

sudo mkdir /var/lib/mysql-cluster

sudo cp /vagrant/manager/config.ini /var/lib/mysql-cluster/

sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini

sudo pkill -f ndb_mgmd

sudo cp /vagrant/manager/ndb_mgmd.service /etc/systemd/system/ndb_mgmd.service

sudo systemctl daemon-reload

sudo systemctl enable ndb_mgmd

sudo systemctl start ndb_mgmd

sudo ufw allow from 192.168.100.2

sudo ufw allow from 192.168.100.3

sudo ufw allow from 192.168.100.4

sudo ufw allow from 192.168.100.11

sudo ufw allow from 192.168.100.12

sudo systemctl status ndb_mgmd
