-- ============================================================
-- SCRIPT INSERT DỮ LIỆU VIET_SPORT - BULK INSERT
-- Format theo sample.sql
-- ============================================================
USE VIET_SPORT
GO

DROP PROCEDURE IF EXISTS dbo.sp_BulkInsertAllData;
DROP PROCEDURE IF EXISTS dbo.sp_DeleteAllData;
DROP PROCEDURE IF EXISTS dbo.sp_CheckRecordCounts;
GO

CREATE PROCEDURE dbo.sp_BulkInsertAllData
    @CsvPath NVARCHAR(MAX) = 'V:\Generate_Data_VietSport\'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    
    PRINT '========== STARTING BULK INSERT VIET_SPORT ==========';
    PRINT 'CSV Path: ' + @CsvPath;
    
    -- Disable constraints
    ALTER TABLE dbo.EMPLOYEE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SYSTEM_PARAMETER NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.ATTENDANCE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.LEAVEFORM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SPORT_COURT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.BOOKING_FORM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.MEMBER_CARD NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.CANCEL_RULE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.DISCOUNT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.PAYROLL NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.PERSONAL_CLOSET NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.RENTING_EQUIPMENT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.VIP_ROOM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.RENTING_HLV NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SERVICE_BOOKING NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.INVOICE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.CANCELLATION_FORM NOCHECK CONSTRAINT ALL;

    PRINT 'Disabling foreign key constraints...';
    
    BEGIN TRY
        -- 1. SPORT_CENTER
        SET @sql = 'BULK INSERT dbo.SPORT_CENTER FROM ''' + @CsvPath + 'SPORT_CENTER.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into SPORT_CENTER';

        -- 2. EMPLOYEE
        SET @sql = 'BULK INSERT dbo.EMPLOYEE FROM ''' + @CsvPath + 'EMPLOYEE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into EMPLOYEE';

        -- 3. SYSTEM_PARAMETER
        SET @sql = 'BULK INSERT dbo.SYSTEM_PARAMETER FROM ''' + @CsvPath + 'SYSTEM_PARAMETER.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into SYSTEM_PARAMETER';

        -- 4. EMPLOYEE_SCHEDULE
        SET @sql = 'BULK INSERT dbo.EMPLOYEE_SCHEDULE FROM ''' + @CsvPath + 'EMPLOYEE_SCHEDULE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into EMPLOYEE_SCHEDULE';

        -- 5. ATTENDANCE
        SET @sql = 'BULK INSERT dbo.ATTENDANCE FROM ''' + @CsvPath + 'ATTENDANCE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into ATTENDANCE';

        -- 6. LEAVEFORM
        SET @sql = 'BULK INSERT dbo.LEAVEFORM FROM ''' + @CsvPath + 'LEAVEFORM.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into LEAVEFORM';

        -- 7. CUSTOMER
        SET @sql = 'BULK INSERT dbo.CUSTOMER FROM ''' + @CsvPath + 'CUSTOMER.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into CUSTOMER';

        -- 8. COACH
        SET @sql = 'BULK INSERT dbo.COACH FROM ''' + @CsvPath + 'COACH.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into COACH';

        -- 9. COURT_TYPE
        SET @sql = 'BULK INSERT dbo.COURT_TYPE FROM ''' + @CsvPath + 'COURT_TYPE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into COURT_TYPE';

        -- 10. SPORT_COURT
        SET @sql = 'BULK INSERT dbo.SPORT_COURT FROM ''' + @CsvPath + 'SPORT_COURT.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into SPORT_COURT';

        -- 11. BOOKING_FORM
        SET @sql = 'BULK INSERT dbo.BOOKING_FORM FROM ''' + @CsvPath + 'BOOKING_FORM.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into BOOKING_FORM';

        -- 12. MEMBER_CARD
        SET @sql = 'BULK INSERT dbo.MEMBER_CARD FROM ''' + @CsvPath + 'MEMBER_CARD.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into MEMBER_CARD';

        -- 13. CANCEL_RULE
        SET @sql = 'BULK INSERT dbo.CANCEL_RULE FROM ''' + @CsvPath + 'CANCEL_RULE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into CANCEL_RULE';

        -- 14. DISCOUNT
        SET @sql = 'BULK INSERT dbo.DISCOUNT FROM ''' + @CsvPath + 'DISCOUNT.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into DISCOUNT';

        -- 15. PAYROLL
        SET @sql = 'BULK INSERT dbo.PAYROLL FROM ''' + @CsvPath + 'PAYROLL.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into PAYROLL';

        -- 16. SERVICE
        SET @sql = 'BULK INSERT dbo.SERVICE FROM ''' + @CsvPath + 'SERVICE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into SERVICE';

        -- 17. PERSONAL_CLOSET
        SET @sql = 'BULK INSERT dbo.PERSONAL_CLOSET FROM ''' + @CsvPath + 'PERSONAL_CLOSET.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into PERSONAL_CLOSET';

        -- 18. RENTING_EQUIPMENT
        SET @sql = 'BULK INSERT dbo.RENTING_EQUIPMENT FROM ''' + @CsvPath + 'RENTING_EQUIPMENT.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into RENTING_EQUIPMENT';

        -- 19. VIP_ROOM
        SET @sql = 'BULK INSERT dbo.VIP_ROOM FROM ''' + @CsvPath + 'VIP_ROOM.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into VIP_ROOM';

        -- 20. RENTING_HLV
        SET @sql = 'BULK INSERT dbo.RENTING_HLV FROM ''' + @CsvPath + 'RENTING_HLV.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into RENTING_HLV';

        -- 21. SERVICE_BOOKING
        SET @sql = 'BULK INSERT dbo.SERVICE_BOOKING FROM ''' + @CsvPath + 'SERVICE_BOOKING.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into SERVICE_BOOKING';

        -- 22. INVOICE
        SET @sql = 'BULK INSERT dbo.INVOICE FROM ''' + @CsvPath + 'INVOICE.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into INVOICE';

        -- 23. CANCELLATION_FORM
        SET @sql = 'BULK INSERT dbo.CANCELLATION_FORM FROM ''' + @CsvPath + 'CANCELLATION_FORM.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into CANCELLATION_FORM';

        -- 24. ACCOUNT_LOGIN
        SET @sql = 'BULK INSERT dbo.ACCOUNT_LOGIN FROM ''' + @CsvPath + 'ACCOUNT_LOGIN.csv'' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK, MAXERRORS = 1000)';
        EXEC sp_executesql @sql;
        PRINT 'Inserted into ACCOUNT_LOGIN';

        -- Re-enable constraints
        PRINT '';
        PRINT 'Re-enabling foreign key constraints...';
        ALTER TABLE dbo.EMPLOYEE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SYSTEM_PARAMETER CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.ATTENDANCE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.LEAVEFORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SPORT_COURT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.BOOKING_FORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.MEMBER_CARD CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCEL_RULE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.DISCOUNT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PAYROLL CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PERSONAL_CLOSET CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_EQUIPMENT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.VIP_ROOM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_HLV CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SERVICE_BOOKING CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.INVOICE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCELLATION_FORM CHECK CONSTRAINT ALL;

        PRINT '';
        PRINT '========== BULK INSERT COMPLETED SUCCESSFULLY ==========';

    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '========== ERROR OCCURRED ==========';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        
        -- Re-enable constraints in case of error
        ALTER TABLE dbo.EMPLOYEE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SYSTEM_PARAMETER CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.ATTENDANCE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.LEAVEFORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SPORT_COURT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.BOOKING_FORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.MEMBER_CARD CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCEL_RULE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.DISCOUNT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PAYROLL CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PERSONAL_CLOSET CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_EQUIPMENT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.VIP_ROOM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_HLV CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SERVICE_BOOKING CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.INVOICE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCELLATION_FORM CHECK CONSTRAINT ALL;
    END CATCH;
    
    SET NOCOUNT OFF;
END;
GO

-- ============================================================
-- DELETE ALL DATA STORED PROCEDURE
-- ============================================================
DROP PROCEDURE IF EXISTS dbo.sp_DeleteAllData;
GO

CREATE PROCEDURE dbo.sp_DeleteAllData
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '========== STARTING DELETE ALL DATA ==========';
    
    -- Disable constraints
    ALTER TABLE dbo.EMPLOYEE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SYSTEM_PARAMETER NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.ATTENDANCE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.LEAVEFORM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SPORT_COURT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.BOOKING_FORM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.MEMBER_CARD NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.CANCEL_RULE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.DISCOUNT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.PAYROLL NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.PERSONAL_CLOSET NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.RENTING_EQUIPMENT NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.VIP_ROOM NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.RENTING_HLV NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.SERVICE_BOOKING NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.INVOICE NOCHECK CONSTRAINT ALL;
    ALTER TABLE dbo.CANCELLATION_FORM NOCHECK CONSTRAINT ALL;

    PRINT 'Disabling foreign key constraints...';
    
    BEGIN TRY
        -- Delete all data (reverse order of foreign keys)
        DELETE FROM dbo.ACCOUNT_LOGIN; PRINT 'Deleted ACCOUNT_LOGIN';
        DELETE FROM dbo.CANCELLATION_FORM; PRINT 'Deleted CANCELLATION_FORM';
        DELETE FROM dbo.INVOICE; PRINT 'Deleted INVOICE';
        DELETE FROM dbo.SERVICE_BOOKING; PRINT 'Deleted SERVICE_BOOKING';
        DELETE FROM dbo.RENTING_HLV; PRINT 'Deleted RENTING_HLV';
        DELETE FROM dbo.VIP_ROOM; PRINT 'Deleted VIP_ROOM';
        DELETE FROM dbo.RENTING_EQUIPMENT; PRINT 'Deleted RENTING_EQUIPMENT';
        DELETE FROM dbo.PERSONAL_CLOSET; PRINT 'Deleted PERSONAL_CLOSET';
        DELETE FROM dbo.PAYROLL; PRINT 'Deleted PAYROLL';
        DELETE FROM dbo.DISCOUNT; PRINT 'Deleted DISCOUNT';
        DELETE FROM dbo.CANCEL_RULE; PRINT 'Deleted CANCEL_RULE';
        DELETE FROM dbo.MEMBER_CARD; PRINT 'Deleted MEMBER_CARD';
        DELETE FROM dbo.BOOKING_FORM; PRINT 'Deleted BOOKING_FORM';
        DELETE FROM dbo.SPORT_COURT; PRINT 'Deleted SPORT_COURT';
        DELETE FROM dbo.COURT_TYPE; PRINT 'Deleted COURT_TYPE';
        DELETE FROM dbo.SERVICE; PRINT 'Deleted SERVICE';
        DELETE FROM dbo.COACH; PRINT 'Deleted COACH';
        DELETE FROM dbo.CUSTOMER; PRINT 'Deleted CUSTOMER';
        DELETE FROM dbo.LEAVEFORM; PRINT 'Deleted LEAVEFORM';
        DELETE FROM dbo.ATTENDANCE; PRINT 'Deleted ATTENDANCE';
        DELETE FROM dbo.EMPLOYEE_SCHEDULE; PRINT 'Deleted EMPLOYEE_SCHEDULE';
        DELETE FROM dbo.SYSTEM_PARAMETER; PRINT 'Deleted SYSTEM_PARAMETER';
        DELETE FROM dbo.EMPLOYEE; PRINT 'Deleted EMPLOYEE';
        DELETE FROM dbo.SPORT_CENTER; PRINT 'Deleted SPORT_CENTER';
        
        -- Re-enable constraints
        PRINT '';
        PRINT 'Re-enabling foreign key constraints...';
        ALTER TABLE dbo.EMPLOYEE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SYSTEM_PARAMETER CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.ATTENDANCE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.LEAVEFORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SPORT_COURT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.BOOKING_FORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.MEMBER_CARD CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCEL_RULE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.DISCOUNT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PAYROLL CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PERSONAL_CLOSET CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_EQUIPMENT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.VIP_ROOM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_HLV CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SERVICE_BOOKING CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.INVOICE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCELLATION_FORM CHECK CONSTRAINT ALL;
        
        PRINT '';
        PRINT '========== DELETE COMPLETED SUCCESSFULLY ==========';
        
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '========== ERROR OCCURRED ==========';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        
        -- Re-enable constraints
        ALTER TABLE dbo.EMPLOYEE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SYSTEM_PARAMETER CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.ATTENDANCE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.LEAVEFORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SPORT_COURT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.BOOKING_FORM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.MEMBER_CARD CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCEL_RULE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.DISCOUNT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PAYROLL CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.PERSONAL_CLOSET CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_EQUIPMENT CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.VIP_ROOM CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.RENTING_HLV CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.SERVICE_BOOKING CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.INVOICE CHECK CONSTRAINT ALL;
        ALTER TABLE dbo.CANCELLATION_FORM CHECK CONSTRAINT ALL;
    END CATCH;
    
    SET NOCOUNT OFF;
END;
GO

-- ============================================================
-- CHECK RECORD COUNTS STORED PROCEDURE
-- ============================================================
DROP PROCEDURE IF EXISTS dbo.sp_CheckRecordCounts;
GO

CREATE PROCEDURE dbo.sp_CheckRecordCounts
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalRecords INT = 0;
    DECLARE @Count INT;
    
    PRINT '========== RECORD COUNT REPORT ==========';
    PRINT '';
    
    SET @Count = (SELECT COUNT(*) FROM dbo.SPORT_CENTER);
    PRINT 'SPORT_CENTER: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.EMPLOYEE);
    PRINT 'EMPLOYEE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.SYSTEM_PARAMETER);
    PRINT 'SYSTEM_PARAMETER: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.EMPLOYEE_SCHEDULE);
    PRINT 'EMPLOYEE_SCHEDULE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.ATTENDANCE);
    PRINT 'ATTENDANCE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.LEAVEFORM);
    PRINT 'LEAVEFORM: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.CUSTOMER);
    PRINT 'CUSTOMER: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.COACH);
    PRINT 'COACH: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.COURT_TYPE);
    PRINT 'COURT_TYPE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.SPORT_COURT);
    PRINT 'SPORT_COURT: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.BOOKING_FORM);
    PRINT 'BOOKING_FORM: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.MEMBER_CARD);
    PRINT 'MEMBER_CARD: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.CANCEL_RULE);
    PRINT 'CANCEL_RULE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.DISCOUNT);
    PRINT 'DISCOUNT: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.PAYROLL);
    PRINT 'PAYROLL: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.SERVICE);
    PRINT 'SERVICE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.PERSONAL_CLOSET);
    PRINT 'PERSONAL_CLOSET: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.RENTING_EQUIPMENT);
    PRINT 'RENTING_EQUIPMENT: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.VIP_ROOM);
    PRINT 'VIP_ROOM: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.RENTING_HLV);
    PRINT 'RENTING_HLV: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.SERVICE_BOOKING);
    PRINT 'SERVICE_BOOKING: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.INVOICE);
    PRINT 'INVOICE: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.CANCELLATION_FORM);
    PRINT 'CANCELLATION_FORM: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    SET @Count = (SELECT COUNT(*) FROM dbo.ACCOUNT_LOGIN);
    PRINT 'ACCOUNT_LOGIN: ' + CAST(@Count AS NVARCHAR(10));
    SET @TotalRecords = @TotalRecords + @Count;
    
    PRINT '';
    PRINT '========== TOTAL RECORDS: ' + CAST(@TotalRecords AS NVARCHAR(10)) + ' ==========';
    PRINT '';
    
    SET NOCOUNT OFF;
END;
GO

-- ============================================================
-- EXECUTE THE PROCEDURES
-- ============================================================
EXEC dbo.sp_BulkInsertAllData @CsvPath = 'V:\Generate_Data_VietSport\';
EXEC dbo.sp_CheckRecordCounts;
EXEC dbo.sp_DeleteAllData