#!/bin/bash

# Set the database name and new storage engine
database_name=$1
engine_name=$2

# Change the storage engine for the database
mysql -u root -ppassword -e "ALTER DATABASE ${database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -ppassword -e "USE ${database_name};"

# Generate a list of SQL statements to change the storage engine for each table
tables=$(mysql -u root -ppassword -Nse "SHOW TABLES" ${database_name})
for table in $tables; do
  if [ "$engine_name" = "ARCHIVE" ]; then
    sql_statement="ALTER TABLE ${table} DROP PRIMARY KEY;"
    echo "Dropping PK for ARCHIVE engine for table ${table}..."
    mysql -u root -ppassword -e "${sql_statement}" ${database_name}  
  fi
  sql_statement="ALTER TABLE ${table} ENGINE='${engine_name}';"
  echo "Changing engine for table ${table}..."
  mysql -u root -ppassword -e "${sql_statement}" ${database_name}
done

echo "Engine Change Done."
