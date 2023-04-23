# fsql-perf
MySQL engine performance analysis on Linux filesystems (ext4, btrfs, zfs, xfs)

# Generating queries for the workload
Example Command : python3 generate_queries.py --queries 20 --C 25 --R 25 --U 25 --D 25

flags :

queries : total number of queries
C : percentage of create queries
R : percentage of read queries
U : percentage of update queries
D : percentage of delete queries

