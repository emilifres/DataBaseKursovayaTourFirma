-- 3.6 РЕЗЕРВНОЕ КОПИРОВАНИЕ БАЗ ДАННЫХ
USE master;
GO

-- Создание процедуры для полного резервного копирования
CREATE OR ALTER PROCEDURE sp_FullBackupTourAgency
AS
BEGIN
    DECLARE @BackupFile NVARCHAR(500);
    DECLARE @DateStr NVARCHAR(50) = REPLACE(CONVERT(NVARCHAR, GETDATE(), 120), ':', '-');
    
    SET @BackupFile = 'D:\Backup\TourAgency_FULL_' + @DateStr + '.bak';
    
    BACKUP DATABASE TourAgency 
    TO DISK = @BackupFile
    WITH 
        NAME = N'TourAgency-Full Backup',
        COMPRESSION,
        STATS = 10;
    
    PRINT 'Полная резервная копия создана: ' + @BackupFile;
END;
GO

-- Создание процедуры для дифференциального копирования
CREATE OR ALTER PROCEDURE sp_DiffBackupTourAgency
AS
BEGIN
    DECLARE @BackupFile NVARCHAR(500);
    DECLARE @DateStr NVARCHAR(50) = REPLACE(CONVERT(NVARCHAR, GETDATE(), 120), ':', '-');
    
    SET @BackupFile = 'D:\Backup\TourAgency_DIFF_' + @DateStr + '.bak';
    
    BACKUP DATABASE TourAgency 
    TO DISK = @BackupFile
    WITH 
        DIFFERENTIAL,
        NAME = N'TourAgency-Diff Backup',
        COMPRESSION,
        STATS = 10;
    
    PRINT 'Дифференциальная копия создана: ' + @BackupFile;
END;
GO

-- Создание процедуры для копирования журналов транзакций
CREATE OR ALTER PROCEDURE sp_LogBackupTourAgency
AS
BEGIN
    DECLARE @BackupFile NVARCHAR(500);
    DECLARE @DateStr NVARCHAR(50) = REPLACE(CONVERT(NVARCHAR, GETDATE(), 120), ':', '-');
    DECLARE @TimeStr NVARCHAR(50) = REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-');
    
    SET @BackupFile = 'D:\Backup\TourAgency_LOG_' + @DateStr + '_' + @TimeStr + '.trn';
    
    BACKUP LOG TourAgency 
    TO DISK = @BackupFile
    WITH 
        NAME = N'TourAgency-Log Backup',
        COMPRESSION,
        STATS = 10;
    
    PRINT 'Копия журнала транзакций создана: ' + @BackupFile;
END;
GO