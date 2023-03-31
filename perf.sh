nthreads = 1
ntables=1
nscale=1
runtime=10

sudo systemctl start mysql
mysql -u root -ppassword -e "SELECT @@datadir;"

sudo systemctl stop mysql

sudo rsync -av /var/lib/mysql /mnt/btrfs
sudo rsync -av /var/lib/mysql /mnt/ext4
sudo rsync -av /var/lib/mysql /mnt/zfs
sudo rsync -av /var/lib/mysql /mnt/xfs

sudo mv /var/lib/mysql /var/lib/mysql_bak

# 1. Run on btrfs
sudo systemctl stop mysql
sudo sed -i '22s/.*/datadir = \/mnt\/btrfs\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '16s/.*/alias \/var\/lib\/mysql\/ -> \/mnt\/btrfs\/mysql\/\,/' /etc/apparmor.d/tunables/alias
sudo systemctl restart apparmor
sudo systemctl start mysql

# Run tests
mysql -u root -ppassword -e "DROP SCHEMA IF EXISTS sbtest;"
mysql -u root -ppassword -e "CREATE SCHEMA sbtest;"

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' prepare

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > btrfs.log

sysbench --test=/usr/share/sysbench/tpcc.lua --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' cleanup
# End test run

mysql -u root -ppassword -e "SELECT @@datadir;"

# 2. Run on ext4
sudo systemctl stop mysql
sudo sed -i '22s/.*/datadir = \/mnt\/ext4\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '16s/.*/alias \/var\/lib\/mysql\/ -> \/mnt\/ext4\/mysql\/\,/' /etc/apparmor.d/tunables/alias
sudo systemctl restart apparmor
sudo systemctl start mysql

# Run tests
mysql -u root -ppassword -e "DROP SCHEMA IF EXISTS sbtest;"
mysql -u root -ppassword -e "CREATE SCHEMA sbtest;"

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' prepare

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > ext4.log

sysbench --test=/usr/share/sysbench/tpcc.lua --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' cleanup
# End test run

mysql -u root -ppassword -e "SELECT @@datadir;"

# 3. Run on zfs
sudo systemctl stop mysql
sudo sed -i '22s/.*/datadir = \/mnt\/zfs\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '16s/.*/alias \/var\/lib\/mysql\/ -> \/mnt\/zfs\/mysql\/\,/' /etc/apparmor.d/tunables/alias
sudo systemctl restart apparmor
sudo systemctl start mysql

# Run tests
mysql -u root -ppassword -e "DROP SCHEMA IF EXISTS sbtest;"
mysql -u root -ppassword -e "CREATE SCHEMA sbtest;"

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' prepare

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > zfs.log

sysbench --test=/usr/share/sysbench/tpcc.lua --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' cleanup
# End test run

mysql -u root -ppassword -e "SELECT @@datadir;"

# 4. Run on xfs
sudo systemctl stop mysql
sudo sed -i '22s/.*/datadir = \/mnt\/xfs\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '16s/.*/alias \/var\/lib\/mysql\/ -> \/mnt\/xfs\/mysql\/\,/' /etc/apparmor.d/tunables/alias
sudo systemctl restart apparmor
sudo systemctl start mysql

# Run tests
mysql -u root -ppassword -e "DROP SCHEMA IF EXISTS sbtest;"
mysql -u root -ppassword -e "CREATE SCHEMA sbtest;"

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' prepare

sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > xfs.log

sysbench --test=/usr/share/sysbench/tpcc.lua --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' cleanup
# End test run

mysql -u root -ppassword -e "SELECT @@datadir;"

echo "Script finished"
