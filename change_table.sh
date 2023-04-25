#!/bin/bash

MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_HOST="localhost"
MYSQL_DATABASE="database_name"

# Get a list of tables in the database
TABLES=$(mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST} ${MYSQL_DATABASE} -e "SHOW TABLES;" | awk '{print $1}' | grep -v '^Tables')

# Set the default storage engine for the database
mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST} ${MYSQL_DATABASE} -e "ALTER DATABASE ${MYSQL_DATABASE} DEFAULT STORAGE ENGINE = InnoDB;"

# Change the storage engine for each table
for TABLE in ${TABLES}; do
    mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST} ${MYSQL_DATABASE} -e "ALTER TABLE ${TABLE} ENGINE = InnoDB;"
done
