/*
ORIGINAL OUTPUT 
***************
CREATE LOGIN [user1] WITH PASSWORD=N'mypassword' MUST_CHANGE, 
	DEFAULT_DATABASE=[master], 
	DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON

USE [db1]; CREATE USER [user1] FOR LOGIN [user1]
USE [db1]; EXEC sp_addrolemember 'db_datareader', 'user1'
USE [db1]; EXEC sp_addrolemember 'db_datawriter', 'user1'
USE [db2]; CREATE USER [user1] FOR LOGIN [user1]
USE [db2]; EXEC sp_addrolemember 'db_datareader', 'user1'
USE [db2]; EXEC sp_addrolemember 'db_datawriter', 'user1'

MODIFICATIONS
*************

CREATE LOGIN [user1] WITH PASSWORD=N'user1', 
	DEFAULT_DATABASE=[master], 
	DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON

USE [db1]; CREATE USER [user1] FOR LOGIN [user1]
USE [db1]; EXEC sp_addrolemember 'db_datareader', 'user1'
USE [db1]; EXEC sp_addrolemember 'db_datawriter', 'user1'
USE [db2]; CREATE USER [user1] FOR LOGIN [user1]
USE [db2]; EXEC sp_addrolemember 'db_datareader', 'user1'
USE [db2]; EXEC sp_addrolemember 'db_datawriter', 'user1'

GRANT PROCEDURE EXECUTION
*************************
grant execute on dbo.sp_test to user1

*/

SET NOCOUNT ON;

DECLARE @UserString VARCHAR(8000)
DECLARE @DatabaseString VARCHAR(8000)
DECLARE @DefaultDatabase VARCHAR(255)
DECLARE @RolesString VARCHAR(8000)
DECLARE @delimiter CHAR(1)

-- for more info go to https://msdn.microsoft.com/en-us/library/ms189121.aspx
SET @UserString = '[user1]'
SET @DatabaseString = '[db1],[db2]'
SET @DefaultDatabase = '[db1]'
SET @RolesString = 'db_datareader,db_datawriter' --db_ddladmin, db_datareader, db_datawriter
SET @delimiter = ','
BEGIN TRY
    DROP TABLE #Users
    DROP TABLE #Databases
    DROP TABLE #Roles
END TRY BEGIN CATCH END CATCH

    ;WITH Substr(num, firstchar, lastchar) AS (
      SELECT 1, 1, CHARINDEX(@delimiter, @UserString)
      UNION ALL
      SELECT num + 1, lastchar + 1, CHARINDEX(@delimiter, @UserString, lastchar + 1)
      FROM Substr
      WHERE lastchar > 0
    )
    SELECT
        num,
        UserName = SUBSTRING(@UserString, firstchar, CASE WHEN lastchar > 0 THEN lastchar-firstchar ELSE 8000 END)
    INTO #Users
    FROM Substr
       
    ;WITH Substr(num, firstchar, lastchar) AS (
      SELECT 1, 1, CHARINDEX(@delimiter, @DatabaseString)
      UNION ALL
      SELECT num + 1, lastchar + 1, CHARINDEX(@delimiter, @DatabaseString, lastchar + 1)
      FROM Substr
      WHERE lastchar > 0
    )
    SELECT
        num,
        DatabaseName = SUBSTRING(@DatabaseString, firstchar, CASE WHEN lastchar > 0 THEN lastchar-firstchar ELSE 8000 END)
    INTO #Databases
    FROM Substr
   
    ;WITH Substr(num, firstchar, lastchar) AS (
      SELECT 1, 1, CHARINDEX(@delimiter, @RolesString)
      UNION ALL
      SELECT num + 1, lastchar + 1, CHARINDEX(@delimiter, @RolesString, lastchar + 1)
      FROM Substr
      WHERE lastchar > 0
    )
    SELECT
        num,
        RoleName = SUBSTRING(@RolesString, firstchar, CASE WHEN lastchar > 0 THEN lastchar-firstchar ELSE 8000 END)
    INTO #Roles
    FROM Substr    

DECLARE @NumUsers INT
DECLARE @NumDBs INT
DECLARE @NumRoles INT
DECLARE @UserIter INT
DECLARE @DBIter INT
DECLARE @RoleIter INT
DECLARE @UserName VARCHAR(255)
DECLARE @RoleUserName VARCHAR(255)
DECLARE @DBName VARCHAR(255)
DECLARE @RoleName VARCHAR(255)
DECLARE @SQL VARCHAR(MAX)

SET @NumUsers   = (SELECT MAX(num) FROM #Users)
SET @NumDBs     = (SELECT MAX(num) FROM #Databases)
SET @NumRoles   = (SELECT MAX(num) FROM #Roles)
SET @UserIter   = 1
SET @SQL        = ''
 
 WHILE @UserIter <= @NumUsers
BEGIN
    SET @DBIter = 1
    SET @UserName = (SELECT UserName FROM #Users WHERE num = @UserIter)
    --SET @SQL = 'CREATE LOGIN ' + @UserName + ' FROM WINDOWS WITH DEFAULT_DATABASE = ' + @DefaultDatabase
    SET @SQL = 'CREATE LOGIN ' + @UserName + ' WITH PASSWORD=N''mypassword'' MUST_CHANGE, DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
    PRINT (@SQL)
    SET @UserIter = @UserIter + 1
    -- Add user to the databases
    WHILE @DBIter <= @NumDBs
    BEGIN
        SET @RoleIter = 1
        SET @DBName = (SELECT DatabaseName FROM #Databases WHERE num = @DBIter)
        SET @SQL = 'USE ' + @DBName + '; CREATE USER ' + @UserName + ' FOR LOGIN ' + @UserName
        PRINT (@SQL)
        SET @DBIter = @DBIter + 1
        WHILE @RoleIter <= @NumRoles
        BEGIN
            SET @RoleName = (SELECT RoleName FROM #Roles WHERE num = @RoleIter)
            -- Must remove brackets for addrolemember procedure
            SET @RoleUserName = REPLACE(REPLACE(@UserName, '[', ''), ']', '')
            SET @SQL = 'USE ' + @DBName + '; EXEC sp_addrolemember ''' + @RoleName + ''', ''' + @RoleUserName + ''''
            PRINT (@SQL)
            SET @RoleIter = @RoleIter + 1
        END
    END
	SELECT 'No olvides los comandos que están en Messages' as Warning
	SELECT 'GRANT EXECUTE ON OBJECT::' + p.name + ' TO ' + @UserName FROM sys.procedures p
END

