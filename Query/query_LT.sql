USE VIET_SPORT
GO

--======
--CHỨC NĂNG 1: LẬP PHIẾU BOOKING FORM
--======

IF OBJECT_ID('sp_Receptionist_Booking_Create') IS NOT NULL
    DROP PROCEDURE sp_Receptionist_Booking_Create;
GO

CREATE OR ALTER PROCEDURE sp_Receptionist_Booking_Create
    @CourtID NVARCHAR(50),
    @CustomerID NVARCHAR(50),
    @SportCenterID NVARCHAR(50),
    @RID NVARCHAR(50),          -- Mã Lễ tân
    @StartDate DATE,            -- Ngày sử dụng
    @StartTime_In TIME,         -- Giờ bắt đầu
    @EndTime_In TIME,           -- Giờ kết thúc
    @ServiceID NVARCHAR(50) = NULL,
    @Quantity INT = 0
AS
BEGIN
    -- Thiết lập mức cô lập TRƯỚC khi bắt đầu Transaction
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 

    DECLARE @StatusCheck1 NVARCHAR(50);
    DECLARE @StatusCheck2 NVARCHAR(50);
    DECLARE @FullStartTime DATETIME = CAST(@StartDate AS DATETIME) + CAST(@StartTime_In AS DATETIME);
    DECLARE @FullEndTime DATETIME = CAST(@StartDate AS DATETIME) + CAST(@EndTime_In AS DATETIME);

    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. KIỂM TRA LOGIC THỜI GIAN
        IF @StartTime_In >= @EndTime_In
        BEGIN
            RAISERROR(N'Lỗi: Giờ bắt đầu phải nhỏ hơn giờ kết thúc!', 16, 1);
            ROLLBACK TRAN; RETURN -1;
        END

            -- =============================================
    -- 2. KIỂM TRA SỰ TỒN TẠI VÀ LOGIC NGHIỆP VỤ
    -- =============================================

    -- A. Kiểm tra Khách hàng
    IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR(N'Lỗi: Mã khách hàng không tồn tại!', 16, 1); RETURN -2;
    END

    -- B. Kiểm tra Trung tâm
    IF NOT EXISTS (SELECT 1 FROM SPORT_CENTER WHERE CenterID = @SportCenterID)
    BEGIN
        RAISERROR(N'Lỗi: Mã trung tâm thể thao không tồn tại!', 16, 1); RETURN -3;
    END

    -- C. Kiểm tra Sân và Sân phải thuộc Trung tâm đã chọn
    IF NOT EXISTS (SELECT 1 FROM SPORT_COURT WHERE CourtID = @CourtID)
    BEGIN
        RAISERROR(N'Lỗi: Mã sân không tồn tại!', 16, 1); RETURN -4;
    END
    IF NOT EXISTS (SELECT 1 FROM SPORT_COURT WHERE CourtID = @CourtID AND CenterID = @SportCenterID)
    BEGIN
        RAISERROR(N'Lỗi: Sân được chọn không thuộc Trung tâm thể thao này!', 16, 1); RETURN -5;
    END

    -- D. Kiểm tra Nhân viên (Phải tồn tại và là Lễ tân)
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @RID AND Role = 'Receptionist')
    BEGIN
        RAISERROR(N'Lỗi: Mã nhân viên không tồn tại hoặc không có quyền Lễ tân!', 16, 1); RETURN -6;
    END

    -- E. Kiểm tra Dịch vụ (Nếu có chọn)
    IF @ServiceID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM SERVICE WHERE ServiceID = @ServiceID)
        BEGIN
            RAISERROR(N'Lỗi: Mã dịch vụ không tồn tại!', 16, 1); RETURN -7;
        END
        
        IF NOT EXISTS (SELECT 1 FROM SERVICE WHERE ServiceID = @ServiceID AND AvailableStatus = N'Đang hoạt động')
        BEGIN
            RAISERROR(N'Lỗi: Dịch vụ này hiện đang ngừng hoạt động!', 16, 1); RETURN -8;
        END

        IF @Quantity <= 0
        BEGIN
            RAISERROR(N'Lỗi: Số lượng dịch vụ phải lớn hơn 0!', 16, 1); RETURN -9;
        END

	END
    -- =============================================
    -- 3. KIỂM TRA XUNG ĐỘT LỊCH ĐẶT SÂN
    -- =============================================
    IF EXISTS (
        SELECT 1 FROM BOOKING_FORM 
        WHERE CourtID = @CourtID 
        AND Status <> N'Cancelled'
        AND (
            (@FullStartTime >= StartTime AND @FullStartTime < EndTime)
            OR (@FullEndTime > StartTime AND @FullEndTime <= EndTime)
            OR (StartTime >= @FullStartTime AND EndTime <= @FullEndTime)
        )
    )
    BEGIN
        RAISERROR(N'Lỗi: Sân này đã được đặt trong khoảng thời gian bạn chọn!', 16, 1); RETURN -10;
    END
		--=====================================
        -- 4. DEMO UNREPEATABLE READ: KIỂM TRA TRẠNG THÁI SÂN (STATUS)
		--=====================================
        -- Đọc lần 1
        SELECT @StatusCheck1 = Status FROM SPORT_COURT WHERE CourtID = @CourtID;
        PRINT 'T1 - Doc lan 1: Status = ' + ISNULL(@StatusCheck1, 'NULL');

        IF (@StatusCheck1 = N'Đang bảo trì') 
        BEGIN
            RAISERROR(N'Sân đang bảo trì, không thể đặt!', 16, 1);
            ROLLBACK TRAN; RETURN -11;
        END

        -- ĐỢI T2 XEN VÀO (Lúc này Winform sẽ treo 10s)
        WAITFOR DELAY '00:00:10'; 

        -- Đọc lần 2
        SELECT @StatusCheck2 = Status FROM SPORT_COURT WHERE CourtID = @CourtID;
        PRINT 'T1 - Doc lan 2: Status = ' + ISNULL(@StatusCheck2, 'NULL');

        -- So sánh để phát hiện lỗi Unrepeatable Read
        IF (@StatusCheck1 <> @StatusCheck2) 
        BEGIN  
            RAISERROR(N'LỖI: Trạng thái sân đã bị thay đổi trong khi đang xử lý! (Unrepeatable Read)', 16, 1);
            ROLLBACK TRAN; RETURN -12;
        END

        -- 5. SINH MÃ TỰ ĐỘNG VÀ INSERT
        DECLARE @NewBKG_ID NVARCHAR(50);
        DECLARE @MaxNum INT;
        SELECT @MaxNum = MAX(CAST(SUBSTRING(BookingID, 4, LEN(BookingID)) AS INT)) 
        FROM BOOKING_FORM WHERE BookingID LIKE 'BKG%';
        SET @NewBKG_ID = 'BKG' + RIGHT('0000' + CAST(ISNULL(@MaxNum, 0) + 1 AS NVARCHAR), 5);

        -- Chèn Phiếu đặt
        INSERT INTO BOOKING_FORM (BookingID, CourtID, OrderDate, OrderTime, StartTime, EndTime, Status, CustomerID, SportCenterID, RID)
        VALUES (@NewBKG_ID, @CourtID, GETDATE(), CAST(GETDATE() AS TIME), @FullStartTime, @FullEndTime, N'Confirmed', @CustomerID, @SportCenterID, @RID);

        -- Chèn Dịch vụ
        IF @ServiceID IS NOT NULL
        BEGIN
            DECLARE @MaxSB INT;
            SELECT @MaxSB = MAX(CAST(SUBSTRING(SBID, 4, LEN(SBID)) AS INT)) FROM SERVICE_BOOKING;
            DECLARE @NewSBID NVARCHAR(50) = 'SBD' + RIGHT('0000' + CAST(ISNULL(@MaxSB, 0) + 1 AS NVARCHAR), 5);

            INSERT INTO SERVICE_BOOKING (SBID, BookingID, ServiceID, BookingQuantity)
            VALUES (@NewSBID, @NewBKG_ID, @ServiceID, @Quantity);
        END

        COMMIT TRANSACTION;
        PRINT N'Thành công! Mã: ' + @NewBKG_ID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;


	--======
	--CHỨC NĂNG 2: LẬP PHIẾU CANCELLATION FORM
	--======
	IF OBJECT_ID('sp_Receptionist_Cancellation_Create') IS NOT NULL
		DROP PROCEDURE sp_Receptionist_Cancellation_Create;
	GO

	CREATE PROCEDURE sp_Receptionist_Cancellation_Create
		@BookingID NVARCHAR(50),
		@NewBookingID NVARCHAR(50) = NULL
	AS
	BEGIN
		SET NOCOUNT ON;

		-- 1. LẤY THỜI GIAN HIỆN TẠI VÀ THỜI ĐIỂM BẮT ĐẦU ĐÁ
		DECLARE @CurrentDateTime DATETIME = GETDATE();
		DECLARE @BookingStartTime DATETIME;

		SELECT @BookingStartTime = StartTime FROM BOOKING_FORM WHERE BookingID = @BookingID;

		IF @BookingStartTime IS NULL
		BEGIN
			RAISERROR(N'Lỗi: Không tìm thấy phiếu đặt sân!', 16, 1);
			RETURN -1;
		END

		-- Nếu đã quá giờ bắt đầu thì không được hủy
		IF @CurrentDateTime > @BookingStartTime
		BEGIN
			RAISERROR(N'Lỗi: Giờ bắt đầu sân đã trôi qua, không thể hủy phiếu!', 16, 1);
			RETURN -2;
		END

		-- 2. TÍNH KHOẢNG CÁCH THỜI GIAN THEO PHÚT (Để đạt độ chính xác cao nhất)
		DECLARE @MinutesDiff INT = DATEDIFF(MINUTE, @CurrentDateTime, @BookingStartTime);

		-- 3. TÌM QUY ĐỊNH HỦY (CANCEL_RULE) PHÙ HỢP
		-- Quy đổi MinimumTime của từng Rule sang Phút để so sánh với @MinutesDiff
		DECLARE @FoundRuleID NVARCHAR(50);
		DECLARE @FoundPenalty DECIMAL(10, 2);

-- 3. LOGIC TÍNH PHÍ PHẠT TRỰC TIẾP (Thay thế cho CancelRule)
    -- Bạn có thể sửa các mốc thời gian và số tiền ở đây
    IF @MinutesDiff >= 1440 -- Hủy trước 24 tiếng
    BEGIN
        SET @FoundPenalty = 0; -- Không phạt
    END
    ELSE IF @MinutesDiff >= 360 -- Hủy trước 6 tiếng
    BEGIN
        SET @FoundPenalty = 20000; -- Phạt cố định 20k hoặc tính %: @TotalAmount * 0.1
    END
    ELSE -- Hủy dưới 6 tiếng (Sát giờ)
    BEGIN
        SET @FoundPenalty = 50000; -- Phạt cố định 50k hoặc tính %: @TotalAmount * 0.3
    END
		-- 4. SINH MÃ PHIẾU HỦY CNF0001
		DECLARE @NewCNF_ID NVARCHAR(50);
		DECLARE @MaxNum INT;
		SELECT @MaxNum = MAX(CAST(SUBSTRING(CancelFormID, 4, LEN(CancelFormID)) AS INT)) 
		FROM CANCELLATION_FORM WHERE CancelFormID LIKE 'CNF%';
		SET @NewCNF_ID = 'CNF' + RIGHT('000' + CAST(ISNULL(@MaxNum, 0) + 1 AS NVARCHAR), 4);

		-- 5. THỰC THI TRANSACTION
		BEGIN TRANSACTION;
		BEGIN TRY
			INSERT INTO CANCELLATION_FORM (
				CancelFormID, CancelTime, PenaltyPrice, Status, BookingID
			)
			VALUES (
				@NewCNF_ID, 
				@CurrentDateTime, 
				@FoundPenalty, 
				CASE WHEN @NewBookingID IS NULL THEN N'Cancelled' ELSE N'Changed' END, 
				@BookingID
			);

			UPDATE BOOKING_FORM SET Status = N'Cancelled' WHERE BookingID = @BookingID;

			COMMIT TRANSACTION;
			PRINT N'Hủy thành công! Mã: ' + @NewCNF_ID + N' | Phạt: ' + CAST(@FoundPenalty AS NVARCHAR);
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			THROW;
		END CATCH
	END;
	GO


--=================
--CHỨC NĂNG 3:
--=================

-- ==================================================================
-- SP 1: Load Court Types
-- Mô tả: Lấy danh sách tất cả loại sân
-- ==================================================================
IF OBJECT_ID('SP_GetCourtTypes', 'P') IS NOT NULL
    DROP PROCEDURE SP_GetCourtTypes;
GO

CREATE PROCEDURE SP_GetCourtTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT DISTINCT 
            CourtType,
            CourtTypeName
        FROM COURT_TYPE
        ORDER BY CourtTypeName;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ==================================================================
-- SP 2: Load All Court
-- Mô tả: Lấy tất cả sân từ hôm nay trở đi
-- ==================================================================

IF OBJECT_ID('SP_GetAllCourts', 'P') IS NOT NULL
    DROP PROCEDURE SP_GetAllCourts;
GO

CREATE PROCEDURE SP_GetAllCourts
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            SC.CourtID,
            SC.CourtType,
            CT.CourtTypeName,
            SC.Capacity,
            SC.UnitPrice,
            SC.CenterID,
            SC.Status
        FROM SPORT_COURT SC
        LEFT JOIN COURT_TYPE CT ON SC.CourtType = CT.CourtType
        ORDER BY SC.CourtID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- ==================================================================
-- SP 3: Search Bookings by Filters
-- Mô tả: Tìm kiếm đặt sân theo loại sân và ngày
-- Parameters:
--   @CourtTypeName: Tên loại sân (NULL hoặc 'All' = tất cả)
--   @OrderDate: Ngày đặt sân
-- ==================================================================
IF OBJECT_ID('SP_SearchBookings', 'P') IS NOT NULL
    DROP PROCEDURE SP_SearchBookings;
GO

CREATE PROCEDURE SP_SearchBookings
    @CourtTypeName NVARCHAR(255) = NULL,
    @OrderDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            BF.BookingID,
            BF.CourtID,
            SC.CourtType,
            CT.CourtTypeName,
            BF.OrderDate,
            BF.OrderTime,
            BF.StartTime,
            BF.EndTime,
            BF.Status,
            C.FullName AS CustomerName,
            C.PhoneNumber,
            C.CustomerID
        FROM BOOKING_FORM BF
        INNER JOIN SPORT_COURT SC ON BF.CourtID = SC.CourtID
        INNER JOIN COURT_TYPE CT ON SC.CourtType = CT.CourtType
        LEFT JOIN CUSTOMER C ON BF.CustomerID = C.CustomerID
        WHERE 
            CAST(BF.OrderDate AS DATE) = @OrderDate
            AND (
                @CourtTypeName IS NULL 
                OR @CourtTypeName = 'All' 
                OR CT.CourtTypeName = @CourtTypeName
            )
        ORDER BY BF.StartTime;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
--================
--SP 4: Xem danh sách Booking Form
--================
IF OBJECT_ID('SP_GetBookingForm', 'P') IS NOT NULL
    DROP PROCEDURE SP_GetBookingForm;
GO

CREATE PROCEDURE SP_GetBookingForm
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            *
        FROM BOOKING_FORM BF
        ORDER BY BF.OrderDate,BF.OrderTime;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO