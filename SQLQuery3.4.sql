-- 3.4 УПРАВЛЕНИЕ УЧАСТНИКАМИ УРОВНЯ БАЗЫ ДАННЫХ
USE TourAgency;
GO

-- Создание пользователей из логинов
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_admin')
    CREATE USER db_admin FOR LOGIN TourAdmin;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_manager')
    CREATE USER db_manager FOR LOGIN TourManager;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_analyst')
    CREATE USER db_analyst FOR LOGIN TourAnalyst;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'report_user')
    CREATE USER report_user FOR LOGIN ReportUser;
GO

-- Создание ролей БД
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_admin_role' AND type = 'R')
    CREATE ROLE db_admin_role;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_manager_role' AND type = 'R')
    CREATE ROLE db_manager_role;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_analyst_role' AND type = 'R')
    CREATE ROLE db_analyst_role;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_report_role' AND type = 'R')
    CREATE ROLE db_report_role;
GO

-- Назначение пользователей ролям
ALTER ROLE db_admin_role ADD MEMBER db_admin;
ALTER ROLE db_manager_role ADD MEMBER db_manager;
ALTER ROLE db_analyst_role ADD MEMBER db_analyst;
ALTER ROLE db_report_role ADD MEMBER report_user;
GO

-- Создание специализированных ролей
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'booking_manager' AND type = 'R')
    CREATE ROLE booking_manager;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'payment_operator' AND type = 'R')
    CREATE ROLE payment_operator;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'document_controller' AND type = 'R')
    CREATE ROLE document_controller;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'client_service' AND type = 'R')
    CREATE ROLE client_service;
GO

-- Назначение пользователей специализированным ролям
ALTER ROLE booking_manager ADD MEMBER db_manager;
ALTER ROLE payment_operator ADD MEMBER db_manager;
ALTER ROLE document_controller ADD MEMBER db_admin;
ALTER ROLE client_service ADD MEMBER db_manager;
GO