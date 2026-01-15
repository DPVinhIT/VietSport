--CÁC CHỨC NĂNG CHÍNH: DÙNG CHUNG
USE VIET_SPORT
GO
--1.1 DC1: Ðang nhập vào hệ thống - Khách hàng
GO
CREATE OR ALTER PROC sp_LoginC
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM ACCOUNT_LOGIN a
        WHERE a.AccountLogin = @Username
          AND a.Password = @Password
    )
	BEGIN
		SELECT c.CustomerID, c.FullName
		FROM ACCOUNT_LOGIN a
		JOIN CUSTOMER c ON a.AccountLogin = c.AccountLogin
		WHERE a.AccountLogin = @Username
        SET @result = 1; -- Đăng nhập thành công
    END
	ELSE
        SET @result = 0; -- Sai username hoặc password
END
GO

--1.2 DC1: Ðang nhập vào hệ thống - Nhân viên
GO
CREATE OR ALTER PROC sp_LoginE
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM ACCOUNT_LOGIN a
        WHERE a.AccountLogin = @Username
          AND a.Password = @Password
    )
	BEGIN
		SELECT e.EmployeeID, e.FullName,e.Role
		FROM ACCOUNT_LOGIN a
		JOIN EMPLOYEE e ON a.AccountLogin = e.AccountLogin
		WHERE a.AccountLogin = @Username
        SET @result = 1; -- Đăng nhập thành công
    END
	ELSE
        SET @result = 0; -- Sai username hoặc password
END
GO

--2.1. Quản lý thông tin cá nhân - Xem thông tin cá nhân khách hàng//
CREATE PROC sp_ViewCusInfo
    @CusID NVARCHAR(50),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (
        SELECT 1
        FROM CUSTOMER c
        WHERE c.CustomerID = @CusID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã khách hàng này', 16, 1);
	END
	SELECT c.AccountLogin, c.Address, c.Birthday, c.Email, c.FullName, c.PhoneNumber
	FROM CUSTOMER c
	WHERE c.CustomerID = @CusID
    SET @result = 1;
END
GO

--2.2. Quản lý thông tin cá nhân - Xem thông tin cá nhân nhân viên//
CREATE PROC sp_ViewEmpInfo
    @EmpID NVARCHAR(50),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.EmployeeID = @EmpID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
	END
	SELECT e.AccountLogin, e.Birthday, e.CCCD, e.City, e.District, e.Street, e.Gender, e.FullName, e.PhoneNumber
	FROM EMPLOYEE e
    WHERE e.EmployeeID = @EmpID
    SET @result = 1;
END
GO

--2.3 Quản lý thông tin cá nhân - Cập nhật thông tin cá nhân KH//
CREATE PROC sp_UpdateCusInfo 
	@CusID		  NVARCHAR(50),
    @FullName     NVARCHAR(255) = NULL,
    @PhoneNumber  VARCHAR(20) = NULL,
    @Email        VARCHAR(50) = NULL,
    @Address      VARCHAR(255) = NULL,
    @Birthday     DATE,
	@result		  INT OUT
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS (
        SELECT 1
        FROM CUSTOMER c
        WHERE c.CustomerID = @CusID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã khách hàng này', 16, 1);
	END
	 IF EXISTS (
        SELECT 1
        FROM CUSTOMER c
        WHERE c.Email = @Email AND c.CustomerID <> @CusID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Đã có người dùng email này', 16, 1);
	END
	--Kiểm tra SĐT có bị trùng không
	 IF EXISTS (
        SELECT 1
        FROM CUSTOMER c
        WHERE c.PhoneNumber = @PhoneNumber AND c.CustomerID <> @CusID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Đã có người dùng số điện thoại này', 16, 1);
	END
	--Cập nhật các thông tin đã thay đổi
	UPDATE Customer
	SET FullName = ISNULL(@FullName, FullName),
		PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
		Email = ISNULL(@Email, Email),
		Address = ISNULL(@Address, Address),
		Birthday = ISNULL(@Birthday, Birthday)
	WHERE CustomerID = @CusID
END
GO
--2.4 Quản lý thông tin cá nhân - Cập nhật thông tin cá nhân nv//
CREATE PROC sp_UpdateEmpInfo 
	@EmpID		  NVARCHAR(50),
    @FullName     NVARCHAR(255) = NULL,
    @Birthday     DATE, 	
	@Gender		  NVARCHAR(20) = NULL,   
	@CCCD		  NVARCHAR(20) = NULL,
	@PhoneNumber  VARCHAR(20) = NULL,
	@Street		  NVARCHAR(255) = NULL,
	@District	  NVARCHAR(255) = NULL,
	@City		  NVARCHAR(255) = NULL,
	@result		  INT OUT
AS
BEGIN
	SET NOCOUNT ON
	 IF NOT EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.EmployeeID = @EmpID

    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
	END
	 IF EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.EmployeeID <> @EmpID AND e.CCCD = @CCCD
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Đã có người dùng CCCD này', 16, 1);
	END
	--Kiểm tra SĐT có bị trùng không
	 IF EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.PhoneNumber = @PhoneNumber AND e.EmployeeID <> @EmpID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Đã có người dùng số điện thoại này', 16, 1);
	END
	--Cập nhật các thông tin đã thay đổi
	UPDATE EMPLOYEE
	SET FullName = ISNULL(@FullName, FullName),
		PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
		CCCD = ISNULL(@CCCD, CCCD),
		Gender = ISNULL(@Gender, Gender),
		Birthday = ISNULL(@Birthday, Birthday),
		Street = ISNULL(@Street, Street),
		District = ISNULL(@District, District),
		City = ISNULL(@City, City)
	WHERE EmployeeID = @EmpID
END
GO

--3.1 Quản lý thông tin tài khoản - Xem thông tin tài khoản//
CREATE PROC sp_ViewAccountInfo @Username NVARCHAR(50)
AS 
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS(
		SELECT * 
		FROM ACCOUNT_LOGIN a
		WHERE a.AccountLogin = @Username
	)
	BEGIN
	RAISERROR (N'Không tồn tại username', 16, 1);
	END
	SELECT * 
	FROM ACCOUNT_LOGIN a
	WHERE a.AccountLogin = @Username
END
GO
--3.2 Đổi mật khẩu
CREATE PROC sp_ChangePassword
    @Username VARCHAR(20),
    @Phone VARCHAR(15),
    @NewPassword NVARCHAR(255),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate dữ liệu
        IF (
            @Username IS NULL OR LTRIM(RTRIM(@Username)) = '' OR
            @Phone IS NULL OR LTRIM(RTRIM(@Phone)) = '' OR
            @NewPassword IS NULL OR LTRIM(RTRIM(@NewPassword)) = ''
        )
        BEGIN
            SET @result = -2; -- Thiếu dữ liệu
            RETURN;
        END

        -- 2. Check Username tồn tại trong AccountLogin
        IF NOT EXISTS (SELECT 1 FROM ACCOUNT_LOGIN WHERE AccountLogin = @Username)
        BEGIN
            SET @result = -3; -- Username không tồn tại
            RETURN;
        END
        
        -- 3. Check thông tin có khớp cùng 1 khách hàng không
        IF NOT EXISTS (
            SELECT 1
            FROM ACCOUNT_LOGIN a
			LEFT JOIN CUSTOMER c ON a.AccountLogin = c.AccountLogin
			LEFT JOIN EMPLOYEE e ON a.AccountLogin = e.AccountLogin
            WHERE (a.AccountLogin = @Username AND c.PhoneNumber = @Phone) 
				  OR (a.AccountLogin = @Username AND e.PhoneNumber = @Phone)
        )
        BEGIN
            SET @result = 0; -- Thông tin không khớp
            RETURN;
        END

        BEGIN TRAN;

        -- 4. Reset mật khẩu
        UPDATE ACCOUNT_LOGIN
        SET Password = @NewPassword
        WHERE AccountLogin = @Username;

        COMMIT;
        SET @result = 1; -- Reset thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @result = -1; -- Lỗi hệ thống
    END CATCH
END
GO



--NVDC1: Xem lịch làm việc
CREATE PROC sp_ViewWorkSchedule 
	@EmpID NVARCHAR(50),
	@Date DATE = NULL,
	@Month INT = NULL,
	@result INT OUT
AS
BEGIN 
	IF NOT EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.EmployeeID = @EmpID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
	END
	SELECT es.StartTime, es.EndTime
	INTO #temp
	FROM ATTENDANCE a 
	JOIN EMPLOYEE_SCHEDULE es ON a.ScheduleID = es.ScheduleID
	WHERE a.EmployeeID = @EmpID
	IF @Date IS NOT NULL
	BEGIN
		SELECT StartTime, EndTime
		FROM #temp
		WHERE FORMAT(StartTime, 'DD-MM-YYYY') = @Date
		SET @result = 1
		RETURN
	END
	IF @Month IS NOT NULL
	BEGIN
		SELECT StartTime, EndTime
		FROM #temp
		WHERE MONTH(StartTime) = @Month
		SET @result = 1
		RETURN
	END
	SET @result = 0
END
GO

--NVDC2: Xem bảng lương
CREATE PROC sp_ViewSalary
	@EmpID NVARCHAR(50),
	@result INT OUT
AS
BEGIN 
	IF NOT EXISTS (
        SELECT 1
        FROM EMPLOYEE e
        WHERE e.EmployeeID = @EmpID
    )
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
	END
	SELECT e.BasicSalary
	FROM EMPLOYEE e
	WHERE e.EmployeeID = @EmpID
	SET @result = 1
END
GO

--NVDC3: Gửi đơn xin nghỉ phép
CREATE PROC sp_CreateLeaveForm
	@EmpID NVARCHAR(50),
	@ScheduleID NVARCHAR(50),
	@Reason NVARCHAR(255),
	@Status NVARCHAR(20),
	@result INT OUT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS (
			SELECT 1
			FROM EMPLOYEE e
			WHERE e.EmployeeID = @EmpID
		)
		BEGIN
			SET @result = 0;
			RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
		END
		BEGIN TRAN
		DECLARE @LFMID NVARCHAR(50) = 'LFM' + RIGHT('00000' + CAST(CAST(RIGHT((SELECT MAX(LeaveFormID) FROM LEAVEFORM), 5) AS INT) + 1 AS NVARCHAR(10)), 5)
		INSERT INTO LEAVEFORM(LeaveFormID, EmployeeID, ScheduleID, DateCreate, Reason, Status)
		VALUES (@LFMID, @EmpID, @ScheduleID, GETDATE(), @Reason, @Status)
		SET @result = 1;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN
		;THROW;
	END CATCH
END
GO

--NVDC4: Xem tình trạng đơn xin nghỉ phép
CREATE PROC sp_ViewLeaveFormStatus
	@EmpID NVARCHAR(50),
	@result INT OUT
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM EMPLOYEE e
		WHERE e.EmployeeID = @EmpID
	)
	BEGIN
		SET @result = 0;
		RAISERROR (N'Không tồn tại mã nhân viên này', 16, 1);
	END
	SELECT lf.LeaveFormID, lf.Status
	FROM LEAVEFORM lf
	WHERE lf.EmployeeID = @EmpID
	SET @result = 1;
END
GO

--NVDC5: Xem danh sách Discount
CREATE PROC sp_ViewDiscountList
AS
BEGIN
	SELECT * 
	FROM DISCOUNT
END
GO

--NVDC6: Quên mật khẩu
CREATE OR ALTER PROC sp_ForgotPasswordE
    @Username NVARCHAR(50),
    @CCCD NVARCHAR(20),
    @Phone NVARCHAR(20),
    @NewPassword NVARCHAR(255),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate dữ liệu
        IF (
            @Username IS NULL OR LTRIM(RTRIM(@Username)) = '' OR
            @CCCD IS NULL OR LTRIM(RTRIM(@CCCD)) = '' OR
            @Phone IS NULL OR LTRIM(RTRIM(@Phone)) = '' OR
            @NewPassword IS NULL OR LTRIM(RTRIM(@NewPassword)) = ''
        )
        BEGIN
            SET @result = -2; -- Thiếu dữ liệu
            RETURN;
        END

        -- 2. Check Username tồn tại trong AccountLogin
        IF NOT EXISTS (SELECT 1 FROM ACCOUNT_LOGIN WHERE AccountLogin = @Username)
        BEGIN
            SET @result = -3; -- Username không tồn tại
            RETURN;
        END
        
        -- 3. Check thông tin có khớp cùng 1 nhân viên không
        IF NOT EXISTS (
            SELECT 1
            FROM EMPLOYEE
            WHERE AccountLogin = @Username
              AND CCCD = @CCCD
              AND PhoneNumber = @Phone
        )
        BEGIN
            SET @result = 0; -- Thông tin không khớp
            RETURN;
        END

        BEGIN TRAN;

        -- 4. Reset mật khẩu
        UPDATE ACCOUNT_LOGIN
        SET Password = @NewPassword
        WHERE AccountLogin = @Username;

        COMMIT;
        SET @result = 1; -- Reset thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @result = -1; -- Lỗi hệ thống
    END CATCH
END
GO

--KH: Quên mật khẩu
CREATE OR ALTER PROC sp_ForgotPasswordC
    @Username NVARCHAR(50),
    @Email NVARCHAR(50),
    @Phone NVARCHAR(20),
    @NewPassword NVARCHAR(255),
    @result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate dữ liệu
        IF (
            @Username IS NULL OR LTRIM(RTRIM(@Username)) = '' OR
            @Email IS NULL OR LTRIM(RTRIM(@Email)) = '' OR
            @Phone IS NULL OR LTRIM(RTRIM(@Phone)) = '' OR
            @NewPassword IS NULL OR LTRIM(RTRIM(@NewPassword)) = ''
        )
        BEGIN
            SET @result = -2; -- Thiếu dữ liệu
            RETURN;
        END

        -- 2. Check Username tồn tại trong AccountLogin
        IF NOT EXISTS (SELECT 1 FROM ACCOUNT_LOGIN WHERE AccountLogin = @Username)
        BEGIN
            SET @result = -3; -- Username không tồn tại
            RETURN;
        END
        
        -- 3. Check thông tin có khớp cùng 1 khách hàng không
        IF NOT EXISTS (
            SELECT 1
            FROM Customer
            WHERE AccountLogin = @Username
              AND Email = @Email
              AND PhoneNumber = @Phone
        )
        BEGIN
            SET @result = 0; -- Thông tin không khớp
            RETURN;
        END

        BEGIN TRAN;

        -- 4. Reset mật khẩu
        UPDATE ACCOUNT_LOGIN
        SET Password = @NewPassword
        WHERE AccountLogin = @Username;

        COMMIT;
        SET @result = 1; -- Reset thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @result = -1; -- Lỗi hệ thống
    END CATCH
END
GO

