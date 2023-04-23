# fsql-perf
MySQL engine performance analysis on Linux filesystems (ext4, btrfs, zfs, xfs)

# Generating queries for the workload
Example Command : python3 generate_queries.py --queries 20 --C 25 --R 25 --U 25 --D 25

flags :

queries : total number of queries\n
C : percentage of create queries\n
R : percentage of read queries\n
U : percentage of update queries\n
D : percentage of delete queries\n

