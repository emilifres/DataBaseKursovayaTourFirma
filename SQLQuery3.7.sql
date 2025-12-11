-- 3.7 ШИФРОВАНИЕ ДАННЫХ БАЗ ДАННЫХ
USE TourAgency;
GO

-- Создание главного ключа базы данных
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'MasterKeyP@ssw0rd!2024';
GO

-- Создание сертификата
CREATE CERTIFICATE TourAgency_Certificate
WITH SUBJECT = 'Certificate for TourAgency Data Encryption',
EXPIRY_DATE = '2030-12-31';
GO

-- Создание симметричного ключа
CREATE SYMMETRIC KEY TourAgency_SymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE TourAgency_Certificate;
GO

-- Добавление столбцов для хранения зашифрованных данных
ALTER TABLE Client
ADD Passport_Data_Encrypted VARBINARY(256) NULL;
GO

ALTER TABLE Booking_Participant
ADD Passport_Data_Encrypted VARBINARY(256) NULL;
GO

-- Триггер для автоматического шифрования при вставке
CREATE OR ALTER TRIGGER trg_EncryptClientData
ON Client
AFTER INSERT, UPDATE
AS
BEGIN
    OPEN SYMMETRIC KEY TourAgency_SymmetricKey
    DECRYPTION BY CERTIFICATE TourAgency_Certificate;
    
    UPDATE c
    SET Passport_Data_Encrypted = 
        CASE 
            WHEN i.Passport_Data IS NOT NULL 
            THEN EncryptByKey(Key_GUID('TourAgency_SymmetricKey'), i.Passport_Data)
            ELSE NULL
        END
    FROM Client c
    INNER JOIN inserted i ON c.Client_ID = i.Client_ID;
    
    CLOSE SYMMETRIC KEY TourAgency_SymmetricKey;
END;
GO

-- Процедура для безопасного доступа к зашифрованным данным
CREATE OR ALTER PROCEDURE sp_GetClientSecureData
    @ClientID INT
AS
BEGIN
    OPEN SYMMETRIC KEY TourAgency_SymmetricKey
    DECRYPTION BY CERTIFICATE TourAgency_Certificate;
    
    SELECT 
        Client_ID,
        Full_Name,
        Phone,
        Email,
        CONVERT(NVARCHAR(100), DecryptByKey(Passport_Data_Encrypted)) AS Passport_Data,
        Birth_Date,
        Registration_Date
    FROM Client
    WHERE Client_ID = @ClientID;
    
    CLOSE SYMMETRIC KEY TourAgency_SymmetricKey;
END;
GO

-- Политика безопасности на уровне строк (RLS)
CREATE SCHEMA Security;
GO

CREATE OR ALTER FUNCTION Security.fn_EmployeeAccessPredicate(@EmployeeID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS access_result
    WHERE @EmployeeID = CAST(SESSION_CONTEXT(N'EmployeeID') AS INT)
       OR IS_MEMBER('db_admin_role') = 1;
GO

CREATE SECURITY POLICY EmployeeDataPolicy
ADD FILTER PREDICATE Security.fn_EmployeeAccessPredicate(Employee_ID)
ON dbo.Employee
WITH (STATE = ON);
GO

-- Предоставление прав на выполнение процедур
GRANT EXECUTE ON sp_GetClientSecureData TO db_admin_role;
GRANT EXECUTE ON sp_GetClientSecureData TO db_manager_role;
GO

-- Обновление существующих данных для шифрования
OPEN SYMMETRIC KEY TourAgency_SymmetricKey
DECRYPTION BY CERTIFICATE TourAgency_Certificate;

UPDATE Client
SET Passport_Data_Encrypted = EncryptByKey(Key_GUID('TourAgency_SymmetricKey'), Passport_Data)
WHERE Passport_Data IS NOT NULL;

UPDATE Booking_Participant
SET Passport_Data_Encrypted = EncryptByKey(Key_GUID('TourAgency_SymmetricKey'), Passport_Data)
WHERE Passport_Data IS NOT NULL;

CLOSE SYMMETRIC KEY TourAgency_SymmetricKey;
GO