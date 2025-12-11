USE master;
GO

-- 1. Создание логинов для разных ролей
CREATE LOGIN TourAdmin WITH PASSWORD = 'Admin@Secure123';
CREATE LOGIN TourManager WITH PASSWORD = 'Manager@Secure456';
CREATE LOGIN TourAnalyst WITH PASSWORD = 'Analyst@Secure789';
CREATE LOGIN ReportUser WITH PASSWORD = 'Report@Secure012';

-- 2. Проверка созданных логинов
SELECT name, type_desc, create_date, is_disabled
FROM sys.server_principals 
WHERE type IN ('S', 'U') AND name LIKE 'Tour%';

-- 3. Назначение серверных ролей
ALTER SERVER ROLE dbcreator ADD MEMBER TourAdmin;
ALTER SERVER ROLE processadmin ADD MEMBER TourAdmin;

-- 4. Создание серверной роли для мониторинга
CREATE SERVER ROLE TourMonitorRole;
GRANT VIEW ANY DATABASE TO TourMonitorRole;
GRANT VIEW SERVER STATE TO TourMonitorRole;
ALTER SERVER ROLE TourMonitorRole ADD MEMBER TourAnalyst;

-- 5. Просмотр ролей и их членов
SELECT 
    sp.name AS RoleName,
    sp.type_desc AS RoleType,
    sp2.name AS MemberName
FROM sys.server_principals sp
JOIN sys.server_role_members srm ON sp.principal_id = srm.role_principal_id
JOIN sys.server_principals sp2 ON srm.member_principal_id = sp2.principal_id
WHERE sp.name LIKE '%Tour%' OR sp2.name LIKE 'Tour%';

GO

-- УПРАВЛЕНИЕ УЧАСТНИКАМИ УРОВНЯ БАЗЫ ДАННЫХ

USE TourAgency;
GO

-- 1. Создание пользователей базы данных из логинов
CREATE USER Admin_User FOR LOGIN TourAdmin;
CREATE USER Manager_User FOR LOGIN TourManager;
CREATE USER Analyst_User FOR LOGIN TourAnalyst;
CREATE USER Report_User FOR LOGIN ReportUser;

-- 2. Создание ролей базы данных
CREATE ROLE db_admin;
CREATE ROLE db_manager;
CREATE ROLE db_analyst;
CREATE ROLE db_report;

-- 3. Назначение пользователей ролям
ALTER ROLE db_admin ADD MEMBER Admin_User;
ALTER ROLE db_manager ADD MEMBER Manager_User;
ALTER ROLE db_analyst ADD MEMBER Analyst_User;
ALTER ROLE db_report ADD MEMBER Report_User;

-- 4. Создание специализированных ролей
CREATE ROLE SalesManagerRole;
CREATE ROLE FinanceRole;
CREATE ROLE HRRole;

-- 5. Пример: назначение менеджера в несколько ролей
ALTER ROLE SalesManagerRole ADD MEMBER Manager_User;
ALTER ROLE FinanceRole ADD MEMBER Admin_User;

-- 6. Просмотр всех пользователей и их ролей
SELECT 
    dp.name AS DatabaseUser,
    dp.type_desc AS UserType,
    ISNULL(r.name, 'No Role') AS RoleName
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.type IN ('S', 'U')
ORDER BY dp.name;

-- 7. Создание пользователя без логина для приложения
CREATE USER AppUser WITHOUT LOGIN;
ALTER ROLE db_report ADD MEMBER AppUser;

-- 8. Создание схемы и пользователя схемы
CREATE SCHEMA Security AUTHORIZATION Admin_User;
CREATE USER SchemaUser WITHOUT LOGIN;
ALTER AUTHORIZATION ON SCHEMA::Security TO SchemaUser;

GO
