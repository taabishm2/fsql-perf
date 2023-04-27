DELIMITER $$

CREATE PROCEDURE ChangeAllTablesToCSV2(IN database_name VARCHAR(64))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE table_name VARCHAR(64);
  DECLARE alter_stmt VARCHAR(4096);
  DECLARE cur CURSOR FOR
    SELECT TABLE_NAME
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = database_name
      AND ENGINE <> 'CSV';

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO table_name;

    IF done THEN
      LEAVE read_loop;
    END IF;

    SET @alter_stmt = CONCAT('ALTER TABLE ', database_name, '.', table_name, ' ');

    -- Set default values for nullable columns
    SELECT GROUP_CONCAT(CONCAT('MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' NOT NULL DEFAULT ', IF(COLUMN_DEFAULT IS NULL, COALESCE(QUOTE(COLUMN_DEFAULT), '""'), '""')))
    INTO @modify_columns
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = database_name
      AND TABLE_NAME = table_name
      AND IS_NULLABLE = 'YES';

    IF @modify_columns IS NOT NULL THEN
      SET @alter_stmt = CONCAT(@alter_stmt, @modify_columns, ', ');
    END IF;

    -- Change the storage engine to CSV
    SET @alter_stmt = CONCAT(@alter_stmt, 'ENGINE = CSV');

    -- Execute the generated ALTER TABLE statement
    PREPARE stmt FROM @alter_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;

  CLOSE cur;
END$$

DELIMITER ;

CALL ChangeAllTablesToCSV2('sbtest');
