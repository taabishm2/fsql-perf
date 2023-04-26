#!/bin/bash

# Set the database name and new storage engine
database_name="database_name"
engine_name="InnoDB"

# Change the storage engine for the database
mysql -u root -p password -e "ALTER DATABASE ${database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p password -e "USE ${database_name};"

# Generate a list of SQL statements to change the storage engine for each table
tables=$(mysql -u root -p password -Nse "SHOW TABLES" ${database_name})
for table in $tables; do
  sql_statement="ALTER TABLE ${table} ENGINE=${engine_name};"
  echo "Changing engine for table ${table}..."
  mysql -u root -p password -e "${sql_statement}" ${database_name}
done

echo "Done."
