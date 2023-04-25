nthreads=1
ntables=2
nscale=2
runtime=10

logdir="./logs/th-$nthreads-tb-$ntables-sc-$nscale-tm-$runtime"
echo "Creating $logdir"
rm -rf "$logdir"
mkdir "$logdir"

sudo systemctl start mysql
mysql -u root -ppassword -e "SELECT @@datadir;"

sudo systemctl stop mysql

sudo rsync -av /var/lib/mysql /mnt/btrfs
sudo rsync -av /var/lib/mysql /mnt/ext4
sudo rsync -av /var/lib/mysql /mnt/zfs
sudo rsync -av /var/lib/mysql /mnt/xfs

sudo mv /var/lib/mysql /var/lib/mysql_bak

engines=(InnoDB MyISAM ARCHIVE)

for engine in "${engines[@]}"; do
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

    chmod +x ./change_engine.sh
    ./change_engine.sh sbtest $engine

    sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > "$logdir/btrfs.log"

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

    chmod +x ./change_engine.sh
    ./change_engine.sh sbtest $engine

    sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > "$logdir/ext4.log"

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

    chmod +x ./change_engine.sh
    ./change_engine.sh sbtest $engine

    sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > "$logdir/zfs.log"

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

    chmod +x ./change_engine.sh
    ./change_engine.sh sbtest $engine
    
    sysbench --test=/usr/share/sysbench/tpcc.lua --threads=$nthreads --tables=$ntables --scale=$nscale --time=$runtime --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' run > "$logdir/xfs.log"

    sysbench --test=/usr/share/sysbench/tpcc.lua --tables=$ntables --scale=$nscale --db-driver=mysql --mysql-db=sbtest --mysql-user=root --mysql-password='password' cleanup
    # End test run
done

mysql -u root -ppassword -e "SELECT @@datadir;"

echo "Script finished"
