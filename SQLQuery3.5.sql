-- 3.5 УПРАВЛЕНИЕ РАЗРЕШЕНИЯМИ УРОВНЯ БАЗЫ ДАННЫХ
USE TourAgency;
GO

-- GRANT разрешений на таблицы для администратора
GRANT CONTROL ON DATABASE::TourAgency TO db_admin_role;
GRANT ALTER ON SCHEMA::dbo TO db_admin_role;
GO

-- GRANT разрешений для менеджера
GRANT SELECT, INSERT, UPDATE ON Client TO db_manager_role;
GRANT SELECT, INSERT, UPDATE ON Booking TO db_manager_role;
GRANT SELECT, INSERT, UPDATE ON Booking_Participant TO db_manager_role;
GRANT SELECT, INSERT, UPDATE ON Payment TO db_manager_role;
GRANT SELECT, INSERT, UPDATE ON Document TO db_manager_role;
GO

-- GRANT разрешений для аналитика
GRANT SELECT ON Tour TO db_analyst_role;
GRANT SELECT ON Tour_Operator TO db_analyst_role;
GRANT SELECT ON Booking TO db_analyst_role;
GRANT SELECT ON Payment TO db_analyst_role;
GRANT SELECT ON Client TO db_analyst_role;
GO

-- GRANT разрешений для отчетного пользователя
GRANT SELECT ON SCHEMA::dbo TO db_report_role;
GO

-- REVOKE прав на удаление для менеджеров
REVOKE DELETE ON Client FROM db_manager_role;
REVOKE DELETE ON Booking FROM db_manager_role;
REVOKE DELETE ON Payment FROM db_manager_role;
GO

-- DENY доступа к системным представлениям
DENY VIEW DEFINITION TO db_report_role;
GO

-- Создание представлений с разными уровнями доступа
CREATE VIEW vw_BookingDetails AS
SELECT b.Booking_ID, b.Booking_Date, b.Status, b.Total_Price,
       c.Full_Name AS Client_Name, c.Phone, c.Email,
       t.Title AS Tour_Title, t.Country, t.City
FROM Booking b
JOIN Client c ON b.Client_ID = c.Client_ID
JOIN Tour t ON b.Tour_ID = t.Tour_ID;
GO

CREATE VIEW vw_BookingAnalytics AS
SELECT b.Booking_ID, b.Booking_Date, b.Status, b.Total_Price,
       t.Country, t.City, e.Position
FROM Booking b
JOIN Tour t ON b.Tour_ID = t.Tour_ID
JOIN Employee e ON b.Employee_ID = e.Employee_ID;
GO

-- Предоставление прав на представления
GRANT SELECT ON vw_BookingDetails TO db_manager_role;
GRANT SELECT ON vw_BookingAnalytics TO db_analyst_role;
GO

-- Динамическое маскирование данных
ALTER TABLE Client
ALTER COLUMN Phone ADD MASKED WITH (FUNCTION = 'partial(2,"XXX-XX",2)');

ALTER TABLE Client
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE Client
ALTER COLUMN Passport_Data ADD MASKED WITH (FUNCTION = 'partial(4,"******",0)');
GO

-- Права на просмотр немасскированных данных
GRANT UNMASK TO db_admin_role;
GRANT UNMASK TO db_manager_role;
DENY UNMASK TO db_report_role;
GO