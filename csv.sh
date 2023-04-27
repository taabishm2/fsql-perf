#!/bin/bash

# Update these variables with your MySQL credentials
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_HOST="localhost"
DATABASE_NAME="sbtest"

#@echo "SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' ', GROUP_CONCAT('MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' NOT NULL DEFAULT ', COALESCE(QUOTE(COLUMN_DEFAULT), CASE DATA_TYPE >"


DEFAULT_DATE="2010-01-01 00:00:00"

# Run the SQL query
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
"SELECT CONCAT('UPDATE \`', TABLE_NAME, '\` SET \`', COLUMN_NAME, '\` = ''${DEFAULT_DATE}'' WHERE \`', COLUMN_NAME, '\` IS NULL;') AS update_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND DATA_TYPE = 'datetime' AND IS_NULLABLE = 'YES'" \
| while read -r update_query; do
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$update_query"
done

DEFAULT_DATE="0"

# Run the SQL query
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
"SELECT CONCAT('UPDATE \`', TABLE_NAME, '\` SET \`', COLUMN_NAME, '\` = ''${DEFAULT_DATE}'' WHERE \`', COLUMN_NAME, '\` IS NULL;') AS update_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND DATA_TYPE = 'tinyint' AND IS_NULLABLE = 'YES'" \
| while read -r update_query; do
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$update_query"
done

mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
"SHOW TABLES" | while read -r table_name; do
    # Drop foreign keys
    #mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
    #"SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND TABLE_NAME = '${table_name}' AND REFERENCED_TABLE_NAME IS N>"
    #| while read -r fk_name; do
    #    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "ALTER TABLE ${table_name} DROP FOREIGN KEY ${fk_name};"
    #done
    # Drop foreign keys
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
    "SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND TABLE_NAME = '${table_name}' AND REFERENCED_TABLE_NAME IS NOT NULL;" \
    | while read -r fk_name; do
        mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "ALTER TABLE ${table_name} DROP FOREIGN KEY ${fk_name};"
    done    


    # Drop primary keys
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
    "ALTER TABLE ${table_name} DROP PRIMARY KEY;" 2>/dev/null

    # Drop foreign keys
    #mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
    #"SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND TABLE_NAME = '${table_name}' AND REFERENCED_TABLE_NAME IS NOT NULL;" \
    #| while read -r fk_name; do
    #    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "ALTER TABLE ${table_name} DROP FOREIGN KEY ${fk_name};"
    #done

    # Drop index keys
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
    "SHOW INDEX FROM ${table_name} WHERE Key_name != 'PRIMARY';" | awk '{print $3}' | sort -u \
    | while read -r index_name; do
        mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "ALTER TABLE ${table_name} DROP INDEX ${index_name};"
    done
done


mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
"SELECT CONCAT('ALTER TABLE \`', TABLE_NAME, '\` MODIFY \`', COLUMN_NAME, '\` VARCHAR(15000) CHARACTER SET ', CHARACTER_SET_NAME, ' COLLATE ', COLLATION_NAME, ';') AS alter_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND DATA_TYPE = 'text'" \
| while read -r alter_query; do
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$alter_query"
done

mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
"SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' ', GROUP_CONCAT('MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' NOT NULL DEFAULT ', COALESCE(COLUMN_DEFAULT, CASE DATA_TYPE WHEN 'varchar' THEN '\"\"' WHEN 'text' THEN '\"\"' WHEN 'char' THEN '\"\"' WHEN 'int' THEN '0' WHEN 'bigint' THEN '0' WHEN 'tinyint' THEN '0' WHEN 'smallint' THEN '0' WHEN 'decimal' THEN '0' WHEN 'float' THEN '0.0' WHEN 'date' THEN '\"2010-01-01\"' WHEN 'time' THEN '\"00:00:00\"' WHEN 'datetime' THEN '\"2010-01-01 00:00:00\"' WHEN 'timestamp' THEN '\"2010-01-01 00:00:01\"' ELSE '\"\"' END) SEPARATOR ', '), ', ENGINE = CSV;') AS alter_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND IS_NULLABLE = 'YES' GROUP BY TABLE_NAME" \
| while read -r alter_query; do
    echo $alter_query
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$alter_query"
done

# Run the SQL query
# mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
# "SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' ', GROUP_CONCAT('MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' NOT NULL DEFAULT ', IF(COLUMN_DEFAULT IS NULL, COALESCE(QUOTE(COLUMN_DEFAULT), '\"\"'), '\"\"') SEPARATOR ', '), ', ENGINE = CSV;') AS alter_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND IS_NULLABLE = 'YES' GROUP BY TABLE_NAME" \
#| while read -r alter_query; do
#    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$alter_query"

#mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -Bse \
#"SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' ', GROUP_CONCAT('MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' NOT NULL DEFAULT ', COALESCE(QUOTE(COLUMN_DEFAULT), CASE DATA_TYPE WHEN 'date' THEN '1000-01-01' WHEN 'time' THEN '00:00:00' WHEN 'datetime' THEN '1000-01-01 00:00:00' WHEN 'timestamp' THEN '1970-01-01 00:00:01' ELSE '\"\"' END) SEPARATOR ', '), ', ENGINE = CSV;') AS alter_query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${DATABASE_NAME}' AND IS_NULLABLE = 'YES' GROUP BY TABLE_NAME" \
#| while read -r alter_query; do
#    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$DATABASE_NAME" -e "$alter_query"

