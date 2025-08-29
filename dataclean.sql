USE laptops;
 # 1. Create backup  for dataset

CREATE TABLE laptops_backup LIKE laptops;
INSERT INTO laptops_backup
SELECT * FROM laptops;


# 2. Check number of rows

SELECT COUNT(*) FROM laptop;

# 3. Check memory consumption for reference

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'laptops'
AND TABLE_NAME = 'laptop';

# 4. Drop non important columns

-- ALTER TABLE laptop DROP COLUMN `Unnamed: 0`;
-- we dont have any non important columns we will rename `Unnamed: 0` to index1

ALTER TABLE laptop CHANGE `Unnamed: 0` Index1 INT;

# 5. Drop null values

SELECT * FROM laptop
WHERE index1 IS NULL 
AND Company IS NULL 
AND TypeName IS NULL 
AND Inches IS NULL
AND ScreenResolution IS NULL 
AND Cpu IS NULL 
AND Ram IS NULL
AND Memory IS NULL 
AND Gpu IS NULL
AND OpSys IS NULL 
AND WEIGHT IS NULL 
AND Price IS NULL;

SET @sql = (
    SELECT CONCAT(
        'SELECT * FROM laptop WHERE ',
        GROUP_CONCAT(CONCAT('`', column_name, '` IS NULL') SEPARATOR ' OR ')    -- SELECT * FROM laptop WHERE ,  'column1' is null OR 'column2' is null OR ,column n is null
    )
    FROM information_schema.columns
    WHERE table_name = 'laptop' AND table_schema = 'laptops'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DELETE FROM laptop
WHERE index1 IS NULL 
AND Company IS NULL 
AND TypeName IS NULL 
AND Inches IS NULL
AND ScreenResolution IS NULL 
AND Cpu IS NULL 
AND Ram IS NULL
AND Memory IS NULL 
AND Gpu IS NULL
AND OpSys IS NULL 
AND WEIGHT IS NULL 
AND Price IS NULL;

SET SQL_SAFE_UPDATES = 0;

# 6. Drop duplicates

SELECT * ,COUNT(*)
FROM laptop
GROUP BY Index1, Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
HAVING COUNT(*) >1;

SET @sql = CONCAT('SELECT *, COUNT(*) FROM your_table_name GROUP BY ',
    (SELECT GROUP_CONCAT(column_name) FROM information_schema.columns WHERE table_name = 'your_table_name' AND table_schema = 'your_database_name')
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


# 7. Handle Numerical columns

--  Inches Column

ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1);

DESCRIBE laptop;

-- Ram column

SELECT REPLACE(Ram,'GB','') FROM laptop;

UPDATE laptop
SET Ram =  REPLACE(Ram,'GB','');

ALTER TABLE laptop MODIFY COLUMN Ram INTEGER;

-- Weight column
SELECT REPLACE(Weight,'kg','')  FROM laptop;

UPDATE laptop
SET Weight =  REPLACE(Weight,'kg','') ;

-- Price Column
	SELECT ROUND(Price) FROM laptop;
           
UPDATE laptop
SET Price = ROUND(Price) ;
			            
ALTER TABLE laptop MODIFY COLUMN Price INTEGER;

# 	8. Handle Categorical Columns

-- OpSys Column

SELECT DISTINCT OpSys FROM laptops;

-- mac
-- windows
-- linux
-- no os
-- Android chrome(others)

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END AS 'os_brand'
FROM laptop;

UPDATE laptop
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

-- Gpu Column

ALTER TABLE laptop
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

SELECT SUBSTRING_INDEX(Gpu,' ',1) 	FROM laptop;

UPDATE laptop
SET gpu_brand = SUBSTRING_INDEX(Gpu,' ',1) ;
				
                
SELECT REPLACE(Gpu,gpu_brand,'') FROM laptop;

UPDATE laptop
SET gpu_name =  REPLACE(Gpu,gpu_brand,'') ;			
             

ALTER TABLE laptop DROP COLUMN Gpu;

-- Cpu Column

ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

SELECT SUBSTRING_INDEX(Cpu,' ',1)  FROM laptop;


UPDATE laptop
SET cpu_brand = SUBSTRING_INDEX(Cpu,' ',1) ;
				 

SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','') AS DECIMAL(10,2)) FROM laptop ;

UPDATE laptop
SET cpu_speed =  CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','')	AS DECIMAL(10,2)) ;
 
SELECT	REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'')	FROM laptop;

UPDATE laptop
SET cpu_name = 	REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'');



					                    

