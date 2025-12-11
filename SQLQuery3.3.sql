-- 3.3 УПРАВЛЕНИЕ БЕЗОПАСНОСТЬЮ УРОВНЯ СЕРВЕРА
USE master;
GO

-- 1. Создание логинов (удалите старый блок с @Secure паролями)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TourAdmin')
    CREATE LOGIN TourAdmin WITH PASSWORD = 'AdminP@ssw0rd123!';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TourManager')
    CREATE LOGIN TourManager WITH PASSWORD = 'ManagerP@ssw0rd456!';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TourAnalyst')
    CREATE LOGIN TourAnalyst WITH PASSWORD = 'AnalystP@ssw0rd789!';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ReportUser')
    CREATE LOGIN ReportUser WITH PASSWORD = 'ReportP@ssw0rd321!';
GO

-- 2. Назначение серверных ролей
ALTER SERVER ROLE sysadmin ADD MEMBER TourAdmin;
ALTER SERVER ROLE processadmin ADD MEMBER TourManager;
GO

-- 3. Создание пользовательских серверных ролей
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'server_monitor' AND type = 'R')
    CREATE SERVER ROLE server_monitor;

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'backup_operator' AND type = 'R')
    CREATE SERVER ROLE backup_operator;
GO

-- 4. Предоставление прав для мониторинга
GRANT VIEW SERVER STATE TO server_monitor;
GRANT VIEW ANY DEFINITION TO server_monitor;
GO

-- 5. Предоставление прав на резервное копирование
GRANT BACKUP DATABASE TO backup_operator;
GRANT BACKUP LOG TO backup_operator;
GO

-- 6. Добавление логинов в пользовательские серверные роли
ALTER SERVER ROLE server_monitor ADD MEMBER TourAnalyst;
ALTER SERVER ROLE backup_operator ADD MEMBER TourManager;
GO

-- 7. Просмотр созданных объектов
SELECT 
    sp.name AS RoleName,
    sp.type_desc AS RoleType,
    sp2.name AS MemberName
FROM sys.server_principals sp
LEFT JOIN sys.server_role_members srm ON sp.principal_id = srm.role_principal_id
LEFT JOIN sys.server_principals sp2 ON srm.member_principal_id = sp2.principal_id
WHERE sp.name IN ('sysadmin', 'processadmin', 'server_monitor', 'backup_operator')
   OR sp2.name LIKE 'Tour%';
GO