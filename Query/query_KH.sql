--ĐỔI COURTTYPE THÀNH BONGDA, TENNIS, CAULONG, BONGRO
--BỎ BẢNG CANCEL_RULE
--=========================================--
--KH1) Đăng ký tài khoản
CREATE PROCEDURE sp_DangKyKhachHang
(
    @FullName       NVARCHAR(255),
    @Birthday       DATE,
    @PhoneNumber    NVARCHAR(20),
    @Email          NVARCHAR(50),
    @Address        NVARCHAR(255),
    @AccountLogin   NVARCHAR(50),
    @Password       NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1️) Kiểm tra AccountLogin đã tồn tại chưa
    IF EXISTS (
        SELECT 1 
        FROM ACCOUNT_LOGIN 
        WHERE AccountLogin = @AccountLogin
    )
    BEGIN
        RAISERROR (N'Tên đăng nhập đã tồn tại', 16, 1);
        RETURN;
    END

    -- 2️) Kiểm tra Email đã tồn tại chưa
    IF EXISTS (
        SELECT 1 
        FROM CUSTOMER 
        WHERE Email = @Email
    )
    BEGIN
        RAISERROR (N'Email đã được sử dụng', 16, 1);
        RETURN;
    END

    -- 3️) Kiểm tra PhoneNumber đã tồn tại chưa
    IF EXISTS (
        SELECT 1 
        FROM CUSTOMER 
        WHERE PhoneNumber = @PhoneNumber
    )
    BEGIN
        RAISERROR (N'Số điện thoại đã tồn tại', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- 4️) Thêm tài khoản đăng nhập
        INSERT INTO ACCOUNT_LOGIN (AccountLogin, Password)
        VALUES (@AccountLogin, @Password);
		
		--5) Tạo ID tăng dần
		DECLARE @maxID NVARCHAR(50), @CustomerID NVARCHAR(50)
		SELECT @maxID = MAX(CustomerID) FROM CUSTOMER
		--Nếu chưa tồn tại mã khách hàng nào
		IF @maxID IS NULL
		BEGIN
			SET @CustomerID = 'CUS00001'
		END
		--Nếu đã tồn tại mã khách hàng từ trước trong hệ thống
		ELSE 
		BEGIN 
			DECLARE @num INT = CAST(RIGHT(@maxID, 5) AS INT) + 1;
			SET @CustomerID = 'CUS' + RIGHT('00000' + CAST(@num AS VARCHAR(10)), 5)
		END

        -- 5️) Thêm khách hàng
        INSERT INTO CUSTOMER
        (
            CustomerID,
            FullName,
            Birthday,
            PhoneNumber,
            Email,
            Address,
            AccountLogin
        )
        VALUES
        (
            @CustomerID,
            @FullName,
            @Birthday,
            @PhoneNumber,
            @Email,
            @Address,
            @AccountLogin
        );

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;

        DECLARE @ErrMsg NVARCHAR(4000);
        SET @ErrMsg = ERROR_MESSAGE();

        RAISERROR (@ErrMsg, 16, 1);
    END CATCH
END;
GO

--drop procedure sp_DangKyKhachHang
--EXEC sp_DangKyKhachHang
--    @FullName     = N'Nguyễn Văn A',
--    @Birthday     = '2000-01-01',
--    @PhoneNumber  = '0909123455',
--    @Email        = 'B@gmail.com',
--    @Address      = N'HCM',
--    @AccountLogin = 'nguyenvanU',
--    @Password     = '123456';

--KH2) Xem danh sách sân mở
CREATE PROCEDURE sp_XemDanhSachSanMo
(
	@CourtType NVARCHAR(50), 
	--@Price = NULL,
	@StartTime DATETIME,
	@EndTime DATETIME,
	@SportCenterID NVARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--1) Kiểm tra ngày giờ hợp lệ
	IF (@StartTime >= @EndTime)
	BEGIN
        RAISERROR (N'Ngày giờ không hợp lệ', 16, 1);
        RETURN;
    END
	--2) Kiểm tra
	--Tìm sân trống
	SELECT sc.CourtID, sc.CourtType, sc.Capacity, sc.UnitPrice, sc.CenterID
	FROM SPORT_COURT sc
	WHERE sc.CourtType = @CourtType AND (@SportCenterID IS NULL OR sc.CenterID = @SportCenterID)
	AND sc.Status = N'Có thể sử dụng'
	AND NOT EXISTS (
			SELECT 1
            FROM BOOKING_FORM bf2
            WHERE bf2.CourtID = sc.CourtID
            AND bf2.Status <> 'Cancelled' AND (bf2.StartTime < @EndTime AND bf2.EndTime  > @StartTime)
			);
END;
GO
--drop procedure sp_XemDanhSachSanMo
--EXEC sp_XemDanhSachSanMo
--    @CourtType = N'CTP01',
--    @StartTime = '2024-06-15 22:00:00',
--    @EndTime   = '2024-06-15 23:00:00',
--    @SportCenterID = 'CEN001' --(Optional);






--KH3) Đặt sân trực tuyến
CREATE PROCEDURE sp_DatSanTrucTuyen
(
    @CourtID		NVARCHAR(50),
    @CustomerID     NVARCHAR(50),
    @SportCenterID  NVARCHAR(50),
    @StartTime      DATETIME,
    @EndTime        DATETIME,
	@ServiceName	NVARCHAR(50) = NULL,
	@Quantity		INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1️) Kiểm tra thời gian hợp lệ
    IF (@StartTime >= @EndTime)
    BEGIN
        RAISERROR (N'Thời gian đặt sân không hợp lệ', 16, 1);
        RETURN;
    END

	-- 2️) Kiểm tra khoảng thời gian đặt có phù hợp với loại sân không
	DECLARE @Temp INT, @CourtType NVARCHAR(50)
	SET @Temp = DATEDIFF(MINUTE, @StartTime, @EndTime);

	SELECT @CourtType = CourtType 
	FROM SPORT_COURT
	WHERE CourtID = @CourtID

	IF (@Temp % 60 <> 0 AND @CourtType IN (N'CAULONG', N'BONGRO') )
	OR (@CourtType = N'TENNIS' AND @Temp % 120 <> 0)
	OR (@CourtType = N'BONGDA' AND @Temp % 90 <> 0)
	 BEGIN
		RAISERROR (
			N'Thời gian đặt không phù hợp với loại sân', 16, 1);
		RETURN;
	END

    -- 3️) Kiểm tra sân có bị trùng giờ không
    IF EXISTS (
		SELECT 1
		FROM SPORT_COURT sc
		WHERE (@SportCenterID IS NULL OR sc.CenterID = @SportCenterID)
		AND sc.Status = N'Có thể sử dụng'
		AND EXISTS (
				SELECT 1
				FROM BOOKING_FORM bf
				WHERE bf.CourtID = sc.CourtID
				AND bf.Status <> 'Cancelled' AND (bf.StartTime < @EndTime AND bf.EndTime  > @StartTime)
				)
    )
    BEGIN
        RAISERROR (N'Sân đã được đặt trong khung giờ này hoặc đang bảo trì', 16, 1);
        RETURN;
    END
	--4) Tạo BookingID tăng dần

	DECLARE @maxID NVARCHAR(50), @BookingID NVARCHAR(50)
	SELECT @maxID = MAX(BookingID) FROM BOOKING_FORM
	--Nếu chưa tồn tại BookingID nào
	IF @maxID IS NULL
		BEGIN
			SET @BookingID = 'BKG00001'
		END
	ELSE
		BEGIN
			DECLARE @num INT = CAST(RIGHT(@maxID, 5) AS INT) + 1;
			SET @BookingID = 'BKG' + RIGHT('00000' + CAST(@num AS VARCHAR(10)), 5)
		END

    -- 5) Tạo booking
    INSERT INTO BOOKING_FORM
    (
        BookingID,
        CourtID,
        OrderDate,
        OrderTime,
        StartTime,
        EndTime,
        Status,
        CustomerID,
        SportCenterID
    )
    VALUES
    (
        @BookingID,
        @CourtID,
        CAST(GETDATE() AS DATE),
        CAST(GETDATE() AS TIME),
        @StartTime,
        @EndTime,
        N'Confirmed',
        @CustomerID,
        @SportCenterID
    );
	--6) Tạo Service nếu có
	IF (@ServiceName IS NOT NULL AND @Quantity IS NOT NULL)
	
	BEGIN
		DECLARE @ServiceID NVARCHAR(50);
		SELECT @ServiceID = s.ServiceID
		FROM dbo.SERVICE s
		WHERE s.ServiceName = @ServiceName

		DECLARE @maxID2 NVARCHAR(50), @SBID NVARCHAR(50)
		SELECT @maxID2 = MAX(SBID) FROM SERVICE_BOOKING

		--Tạo mã SBID tăng dần
		IF @maxID2 IS NULL
			BEGIN
				SET @SBID = 'SBD00001'
			END
		ELSE
			BEGIN
				DECLARE @num2 INT = CAST(RIGHT(@maxID2, 5) AS INT) + 1;
				SET @SBID = 'SBD' + RIGHT('00000' + CAST(@num2 AS VARCHAR(10)), 5)
			END
		-- Cập nhật số lượng của Service
		IF (@Quantity IS NOT NULL AND @ServiceID IN (SELECT REServiceID 
													FROM RENTING_EQUIPMENT))
		BEGIN
			UPDATE RENTING_EQUIPMENT
			SET Quantity = Quantity - @Quantity
			WHERE REServiceID = @ServiceID
		END
	-- 7) Thêm vào bảng SERVICE_BOOKING
		INSERT INTO SERVICE_BOOKING
		(
			SBID,
			BookingID,
			ServiceID,
			BookingQuantity
		)
		VALUES
		(
			@SBID,
			@BookingID,
			@ServiceID,
			@Quantity
		)
	END
	PRINT N'Đặt sân thành công';
END
GO



--DROP PROCEDURE sp_DatSanTrucTuyen
--select * from BOOKING_FORM where CourtID = 'CRT0001'


--EXEC sp_DatSanTrucTuyen
--    @CourtID       = 'CRT0001',
--    @CustomerID    = 'CUS00012',
--    @SportCenterID = 'CEN001',
--    @StartTime     = '2025-01-10 19:30:00',
--    @EndTime       = '2025-01-10 20:30:00';

--KH4) Xem danh sách các sân đã đặt
CREATE PROCEDURE sp_KH_XemDanhSachSanDaDat
(
    @CustomerID     NVARCHAR(50),
    @StartTime       DATETIME = NULL,
    @EndTime         DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
	 IF NOT EXISTS (
        SELECT 1
        FROM CUSTOMER
        WHERE CustomerID = @CustomerID
    )
    BEGIN
        RAISERROR (N'Mã khách hàng không tồn tại', 16, 1);
        RETURN;
    END

    -- 2️) Kiểm tra thời gian hợp lệ 
    IF (@StartTime IS NOT NULL AND @EndTime IS NOT NULL AND @StartTime >= @EndTime)
    BEGIN
        RAISERROR (N'Thời gian không hợp lệ', 16, 1);
        RETURN;
    END

    --3️) Kiểm tra có BookingForm nào trong khoảng thời gian đó không 
    IF NOT EXISTS (
        SELECT 1
        FROM BOOKING_FORM
        WHERE CustomerID = @CustomerID
          AND (@StartTime IS NULL OR StartTime < @EndTime)
          AND (@EndTime   IS NULL OR EndTime   > @StartTime)
    )
    BEGIN
        RAISERROR (N'Không có sân nào được đặt trong khoảng thời gian này', 16, 1);
        RETURN;
    END
    SELECT
        bf.BookingID,
		bf.CourtID,
		bf.OrderDate,
        bf.StartTime,
        bf.EndTime,
        bf.Status AS BookingStatus,
        i.TotalPrice,
        i.Status AS PaymentStatus
    FROM BOOKING_FORM bf
    JOIN INVOICE i ON bf.BookingID = i.BookingID
    WHERE bf.CustomerID = @CustomerID
      AND ((@StartTime IS NULL OR bf.StartTime >= @StartTime) AND (@EndTime   IS NULL OR bf.EndTime   <= @EndTime))
	  OR ((@StartTime IS NULL OR bf.StartTime <= @EndTime) AND (@EndTime   IS NULL OR bf.EndTime   >= @StartTime))
    ORDER BY bf.StartTime DESC;
END
GO

--select * from INVOICE where BookingID in (select BookingID From BOOKING_FORM where CustomerID = 'CUS00302')
--drop procedure sp_KH_XemDanhSachSanDaDat
--EXEC sp_KH_XemDanhSachSanDaDat
--    @CustomerID = 'CUS00227',
--    @StartTime = '2024-08-05 08:00:00',
--    @EndTime   = '2024-08-05 19:59:59';

--KH5) Huỷ đặt sân (BỎ BẢNG CANCELL_RULE)
CREATE PROCEDURE sp_HuyDatSan
(
    @BookingID   NVARCHAR(50),
    @CustomerID  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME, @EndTime DATETIME


    -- 1) Kiểm tra Booking tồn tại
    IF NOT EXISTS (
        SELECT 1
        FROM BOOKING_FORM
        WHERE BookingID = @BookingID
    )
    BEGIN
        RAISERROR (N'Booking không tồn tại', 16, 1);
        RETURN;
    END

	-- 2) Kiểm tra khách hàng ứng với BookingID
		IF NOT EXISTS (
		SELECT 1
		FROM BOOKING_FORM
		WHERE BookingID = @BookingID
		  AND CustomerID = @CustomerID
	)
	BEGIN
		RAISERROR (N'Booking không tồn tại hoặc không thuộc khách hàng', 16, 1);
		RETURN;
	END

    -- 3) Lấy thời gian bắt đầu và kết thúc
    SELECT @StartTime = StartTime, @EndTime = EndTime
    FROM BOOKING_FORM
    WHERE BookingID = @BookingID;



    -- 4) Kiểm tra thời điểm huỷ
    IF (GETDATE() >= @StartTime)
    BEGIN
        RAISERROR (N'Không thể huỷ khi đã tới giờ sử dụng sân', 16, 1);
        RETURN;
    END

    -- 5) Huỷ booking
    UPDATE BOOKING_FORM
    SET Status = 'Cancelled'
    WHERE BookingID = @BookingID;


	-- 6) Thêm phiếu huỷ vào CENCELLATION_FORM
	-- Tạo mã tăng dần
	DECLARE @maxID NVARCHAR(50), @CancelFormID NVARCHAR(50);

	
	SELECT @maxID = MAX(CancelFormID) FROM CANCELLATION_FORM;

	-- Nếu chưa có mã nào
	IF @maxID IS NULL
		BEGIN
			SET @CancelFormID = 'CNF0001';
		END
	ELSE
		BEGIN
			DECLARE @num INT = CAST(RIGHT(@maxID, 4) AS INT) + 1;
			SET @CancelFormID = 'CNF' + RIGHT('0000' + CAST(@num AS VARCHAR(10)), 4);
		END

	
	
	-- 7) Phạt
	DECLARE @PenaltyPrice DECIMAL(10, 2) = 0;

	DECLARE @CancelTime DATETIME = NULL;
	SET @CancelTime = GETDATE();

	DECLARE @TotalPrice DECIMAL(10, 2) = (SELECT SUM(i.TotalPrice) 
											FROM INVOICE i 
											WHERE i.BookingID = @BookingID)

	IF (DATEDIFF(HOUR, @CancelTime, @StartTime) > 24)
	BEGIN
		SET @PenaltyPrice = @TotalPrice * 0.1;

	END
	ELSE IF (DATEDIFF(HOUR, @CancelTime, @StartTime) <= 24 AND DATEDIFF(MINUTE, @CancelTime, @StartTime) > 0)
		BEGIN
			SET @PenaltyPrice = @TotalPrice * 0.5;

		END
	-- Thêm phiếu huỷ
	INSERT INTO CANCELLATION_FORM
	(
		CancelFormID,
		CancelTime,
		PenaltyPrice,
		Status,
		--CancelRuleID,
		BookingID
	)
	VALUES
	(
		@CancelFormID,
		@CancelTime,
		@PenaltyPrice,
		N'Pending',
		--@CancelRuleID,
		@BookingID
	);
	PRINT N'Huỷ sân thành công';

    -- 8) (Tuỳ chọn) Huỷ dịch vụ đi kèm
    --DELETE FROM SERVICE_BOOKING
    --WHERE BookingID = @BookingID;
END
GO
--drop procedure sp_HuyDatSan
--SELECT 1
--FROM BOOKING_FORM
--WHERE BookingID = 'BKG00001';

--update BOOKING_FORM set Status = 'Confirmed'
--where BookingID = 'BKG00001'

--update BOOKING_FORM set StartTime = '2025-12-26 20:00:00.000'
--where BookingID = 'BKG00001'
--update BOOKING_FORM set StartTime = '2025-12-26 21:30:00.000'
--where BookingID = 'BKG00001'

--select * from INVOICE where BookingID= 'BKG00001'

--EXEC sp_HuyDatSan
--    @BookingID  = 'BKG00001',
--    @CustomerID = 'CUS00227';
--select * from CANCELLATION_FORM where BookingID = 'BKG00001'

-- KH5.2) Đổi sân
CREATE PROCEDURE sp_KH_DoiSanHoacGio
(
    @BookingID      NVARCHAR(50),
    @CustomerID     NVARCHAR(50),
    @NewCourtID     NVARCHAR(50) = NULL,
    @NewStartTime   DATETIME,
    @NewEndTime     DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldStartTime DATETIME, @OldEndTime DATETIME

    -- 1) Kiểm tra booking tồn tại & thuộc khách hàng
    IF NOT EXISTS (
        SELECT 1
        FROM BOOKING_FORM
        WHERE BookingID = @BookingID
          AND CustomerID = @CustomerID
    )
    BEGIN
        RAISERROR (N'Booking không tồn tại hoặc không thuộc khách hàng', 16, 1);
        RETURN;
    END

	--Kiểm tra khoảng thời gian đặt có phù hợp với loại sân không
	DECLARE @Temp INT, @CourtType NVARCHAR(50)
	SET @Temp = DATEDIFF(MINUTE, @NewStartTime, @NewEndTime);

	IF (@NewCourtID IS NULL)
		BEGIN
			SELECT @CourtType = CourtType 
			FROM BOOKING_FORM 
			JOIN SPORT_COURT ON SPORT_COURT.CourtID = BOOKING_FORM.CourtID 
			WHERE BookingID = @BookingID
		END
	ELSE
		BEGIN
			SELECT @CourtType = CourtType 
			FROM SPORT_COURT
			WHERE CourtID = @NewCourtID
		END

	IF (@Temp % 60 <> 0 AND @CourtType IN (N'CAULONG', N'BONGRO') )
	OR (@CourtType = N'TENNIS' AND @Temp % 120 <> 0)
	OR (@CourtType = N'BONGDA' AND @Temp % 90 <> 0)
	 BEGIN
		RAISERROR (
			N'Thời gian đặt không phù hợp với loại sân', 16, 1);
		RETURN;
	END
    -- 2) Lấy thời gian cũ
    SELECT @OldStartTime = StartTime
    FROM BOOKING_FORM
    WHERE BookingID = @BookingID;

    -- 3) Không cho đổi khi đã tới giờ sử dụng
    IF GETDATE() > @OldStartTime AND GETDATE() < @OldEndTime
    BEGIN
        RAISERROR (N'Không thể đổi khi đã tới giờ sử dụng sân', 16, 1);
        RETURN;
    END

    -- 4) Kiểm tra thời gian mới hợp lệ
    IF @NewStartTime >= @NewEndTime
    BEGIN
        RAISERROR (N'Thời gian mới không hợp lệ', 16, 1);
        RETURN;
    END

    -- 5) Kiểm tra sân mới tồn tại & khả dụng
    IF (@NewCourtID IS NOT NULL AND  NOT EXISTS (
        SELECT 1
        FROM SPORT_COURT
        WHERE CourtID = @NewCourtID
          AND Status = N'Có thể sử dụng'
    ))
    BEGIN
        RAISERROR (N'Sân mới không tồn tại hoặc không khả dụng', 16, 1);
        RETURN;
    END

    -- 6) Kiểm tra sân mới có trống trong khung giờ mới không
    IF (@NewCourtID IS NOT NULL AND EXISTS (
        SELECT 1
        FROM BOOKING_FORM bf
        WHERE bf.CourtID = @NewCourtID
          AND bf.BookingID <> @BookingID
          AND bf.Status <> 'Cancelled'
          AND bf.StartTime <= @NewEndTime
          AND bf.EndTime >= @NewStartTime
    ))
    BEGIN
        RAISERROR (N'Sân mới đã được đặt trong khung giờ này', 16, 1);
        RETURN;
    END

    -- 7) Cập nhật booking
    UPDATE BOOKING_FORM
	SET
        StartTime = @NewStartTime,
        EndTime   = @NewEndTime
    WHERE BookingID = @BookingID;
	IF (@NewCourtID IS NOT NULL)  
	UPDATE BOOKING_FORM
	SET
        CourtID = @NewCourtID
    WHERE BookingID = @BookingID;

    PRINT N'Đổi sân / đổi giờ thành công';
END
GO
--DROP PROCEDURE sp_KH_DoiSanHoacGio
--UPDATE BOOKING_FORM SET EndTime = '2025-12-26 22:30:00' WHERE BookingID = 'BKG00001'
--UPDATE BOOKING_FORM SET Status = 'Confirmed' WHERE BookingID = 'BKG00001'
--EXEC sp_KH_DoiSanHoacGio
--    @BookingID    = 'BKG00002',
--    @CustomerID   = 'CUS00461',
--    @NewCourtID   = 'CRT0028',
--    @NewStartTime = '2025-12-26 21:30:00',
--    @NewEndTime   = '2025-12-26 22:00:00';

-- KH6) Thanh toán
CREATE PROCEDURE sp_KH_ThanhToan
(
    @InvoiceID      NVARCHAR(50),
    @CustomerID     NVARCHAR(50),
    @PaymentMethod  NVARCHAR(20),
    @DiscountID     NVARCHAR(50) = NULL,
    @CID            NVARCHAR(50)   
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @BookingID NVARCHAR(50),
        @MembershipLevel NVARCHAR(50);

    -- 1) Kiểm tra Invoice tồn tại

    IF NOT EXISTS (
        SELECT 1
        FROM INVOICE
        WHERE InvoiceID = @InvoiceID
    )
    BEGIN
        RAISERROR (N'Hóa đơn không tồn tại', 16, 1);
        RETURN;
    END

    -- 2) Kiểm tra chưa thanh toán

    IF EXISTS (
        SELECT 1
        FROM INVOICE
        WHERE InvoiceID = @InvoiceID
          AND Status = N'Đã thanh toán'
    )
    BEGIN
        RAISERROR (N'Hóa đơn đã được thanh toán', 16, 1);
        RETURN;
    END

    -- 3) Lấy BookingID

    SELECT @BookingID = BookingID
    FROM INVOICE
    WHERE InvoiceID = @InvoiceID;


    -- 4) Kiểm tra & áp mã giảm giá (nếu có)

    IF @DiscountID IS NOT NULL
    BEGIN
        -- Lấy cấp độ thành viên
        SELECT @MembershipLevel = MembershipLevel
        FROM MEMBER_CARD
        WHERE CustomerID = @CustomerID;

        -- Kiểm tra điều kiện áp dụng
        IF NOT EXISTS (
            SELECT 1
            FROM DISCOUNT d
            WHERE d.DiscountID = @DiscountID
              AND GETDATE() BETWEEN d.StartDate AND d.EndDate
              AND (
                    d.TargetUser = N'Tất cả khách hàng'
                    OR (
                        @MembershipLevel IS NOT NULL
                        AND d.TargetUser = N'Thành viên ' + @MembershipLevel
                    )
                  )
        )
        BEGIN
            RAISERROR (N'Khách hàng không đủ điều kiện áp dụng mã giảm giá này', 16, 1);
            RETURN;
        END

        -- Gắn DiscountID vào hóa đơn
        UPDATE INVOICE
        SET DiscountID = @DiscountID
        WHERE InvoiceID = @InvoiceID;
    END


     -- 5) Cập nhật hóa đơn

    UPDATE INVOICE
    SET 
        PaymentMethod = @PaymentMethod,
        CreateTime = GETDATE(),
        Status = N'Đã thanh toán',
        CID = @CID
    WHERE InvoiceID = @InvoiceID;


      -- 6) Cập nhật Booking

    UPDATE BOOKING_FORM
    SET Status = N'Đã thanh toán'
    WHERE BookingID = @BookingID;

    PRINT N'Thanh toán thành công';
END
GO
--UPDATE INVOICE SET Status = N'Chưa thanh toán' WHERE InvoiceID = 'INV00012'
--update DISCOUNT 
--set 
--	EndDate = '05-08-2026'
--where DiscountID = 'DSC004'
--EXEC sp_KH_ThanhToan
--    @InvoiceID = 'INV00012',
--    @CustomerID = 'CUS00370',
--    @PaymentMethod = N'Tiền mặt',
--	@DiscountID = 'DSC004',
--    @CID = 'EMP0003';

-- 7) Xem chi tiết sân và hoá đơn
CREATE PROCEDURE sp_KH_XemChiTietDatSanVaHoaDon
(
    @CustomerID NVARCHAR(50),
    @CourtID    NVARCHAR(50),
    @FromDate   DATE,
    @ToDate     DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra ngày hợp lệ
    IF (@FromDate > @ToDate)
    BEGIN
        RAISERROR (N'Ngày không hợp lệ', 16, 1);
        RETURN;
    END

    SELECT

        b.Status AS BookingStatus,
        DATEDIFF(MINUTE, b.StartTime, b.EndTime) / 60 AS BookingDuration_Hour,

        c.CourtType,
        c.UnitPrice,


        -- Dịch vụ
		COUNT (sb.SBID) AS ServiceNumber,
		SUM (s.Price * sb.BookingQuantity) AS TotalServicePrice,

        -- Hóa đơn
        --i.InvoiceID,
        i.TotalPrice AS TotalPrice,
        i.Status AS PaymentStatus,
        
        i.CreateTime AS Payment_CancelTime

    FROM BOOKING_FORM b
    JOIN SPORT_COURT c
        ON b.CourtID = c.CourtID
    LEFT JOIN SERVICE_BOOKING sb
        ON b.BookingID = sb.BookingID
    LEFT JOIN SERVICE s
        ON sb.ServiceID = s.ServiceID
    LEFT JOIN INVOICE i
        ON b.BookingID = i.BookingID

    WHERE b.CustomerID = @CustomerID
      AND b.CourtID = @CourtID
      AND b.OrderDate >= @FromDate
      AND b.OrderDate   <= @ToDate

    GROUP BY
        b.BookingID, b.Status, b.StartTime, b.EndTime,
        c.CourtID, c.CourtType, c.UnitPrice,
        i.InvoiceID, i.TotalPrice, i.Status, i.PaymentMethod, i.CreateTime

    ORDER BY b.StartTime DESC;
END
GO

--drop procedure sp_KH_XemChiTietDatSanVaHoaDon

--EXEC sp_KH_XemChiTietDatSanVaHoaDon
--    @CustomerID = 'CUS00860',
--    @CourtID    = 'CRT0013',
--    @FromDate   = '2024-10-27',
--    @ToDate     = '2024-10-28';

-- 8) Đánh giá và phản hồi
