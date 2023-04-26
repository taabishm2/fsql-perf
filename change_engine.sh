#!/bin/bash

# Set the database name and new storage engine
database_name=$1
engine_name=$2

# Change the storage engine for the database
mysql -u root -ppassword -e "ALTER DATABASE ${database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -ppassword -e "USE ${database_name};"

# Generate a list of SQL statements to change the storage engine for each table
tables=$(mysql -u root -ppassword -Nse "SHOW TABLES" ${database_name})
if [ "$engine_name" != "InnoDB" ]; then
  for table in $tables; do
    echo "Dropping FK for ${engine_name} engine for table ${table}..."
    FOREIGN_KEYS=$(mysql -u root -ppassword -Nse "USE ${database_name}; SELECT constraint_name FROM information_schema.table_constraints WHERE table_schema = '${database_name}' AND table_name = '${table}' AND constraint_type = 'FOREIGN KEY';")
    for FOREIGN_KEY in $FOREIGN_KEYS
    do
      mysql -u root -ppassword -e "USE ${database_name}; ALTER TABLE ${table} DROP FOREIGN KEY $FOREIGN_KEY;"
    done
  done
fi  
if [ "$engine_name" = "ARCHIVE" ]; then
  for table in $tables; do
    INDEXES=$(mysql -u root -ppassword -Nse "SELECT INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '${database_name}' AND TABLE_NAME = '${table}'")
    for INDEX in $INDEXES
    do
      echo "Dropping INDEX for ${engine_name} engine for table ${table}..."
      mysql -u root -ppassword -e "ALTER TABLE ${database_name}.${table} DROP INDEX $INDEX"
    done
  done
  for table in $tables; do
    sql_statement="ALTER TABLE ${table} DROP PRIMARY KEY;"
    echo "Dropping PK for ${engine_name} engine for table ${table}..."
    mysql -u root -ppassword -e "${sql_statement}" ${database_name} 
  done   
fi
for table in $tables; do
  sql_statement="ALTER TABLE ${table} ENGINE='${engine_name}';"
  echo "Changing engine for table ${table}..."
  mysql -u root -ppassword -e "${sql_statement}" ${database_name}
done

echo "Engine Change Done."
