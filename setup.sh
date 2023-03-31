# btrfs 	-> sdb
# ext4 		-> sdc
# zfs 		-> sdd
# xfs 		-> sde

cd ~

sudo apt-get update
sudo apt-get upgrade -y

sudo apt install mysql-server -y
sudo apt install btrfs-progs -y
sudo apt-get install zfsutils-linux -y

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"

sudo modprobe zfs

sudo mkdir /mnt/btrfs
sudo mkdir /mnt/ext4
sudo mkdir /mnt/zfs
sudo mkdir /mnt/xfs

sudo mkfs.btrfs /dev/sdb -f
sudo mkfs.ext4 /dev/sdc
sudo zpool create zfspool /dev/sdd
sudo mkfs.xfs /dev/sde -f

sudo mount -t btrfs /dev/sdb /mnt/btrfs -o compress-force=zstd:1,noatime,autodefrag
sudo mount /dev/sdc /mnt/ext4
sudo zfs set mountpoint=/mnt/zfs zfspool
sudo mount /dev/sde /mnt/xfs

curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench

sudo git clone https://github.com/Percona-Lab/sysbench-tpcc /usr/share/sysbench/percona
sudo cp /usr/share/sysbench/percona/* /usr/share/sysbench/

mysql_secure_installation

df -T | tail -4

echo "Finished setup!"