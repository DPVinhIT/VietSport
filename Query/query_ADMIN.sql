USE VIET_SPORT;
go
--==========
--CHỨC NĂNG 1: QUẢN LÝ TÀI KHOẢN NHÂN VIÊN
--==========
-- 1.1 Thêm mới nhân viên (NÚT ADD)
IF OBJECT_ID('sp_Admin_AccountEmployees_Add') IS NOT NULL
    DROP PROCEDURE sp_Admin_AccountEmployees_Add;
GO

CREATE PROCEDURE sp_Admin_AccountEmployees_Add
    @FullName NVARCHAR(255),
    @Birthday DATE,
    @Gender NVARCHAR(10),
    @CCCD NVARCHAR(20),
	@Street NVARCHAR(255),
    @District NVARCHAR(255),
    @City NVARCHAR(255),
    @PhoneNumber NVARCHAR(20),
    @BasicSalary DECIMAL(10, 2),
	@ManagerID NVARCHAR(50) = NULL,
    @CenterID NVARCHAR(50),
    @Role NVARCHAR(50)
	
AS
BEGIN
	-- LOGIC MỚI: Nếu Role là Manager thì ép ManagerID về NULL bất kể dữ liệu truyền vào
    IF @Role = 'Manager'
    BEGIN
        SET @ManagerID = NULL;
    END

	DECLARE @NewEMP_ID NVARCHAR(50);
    DECLARE @MaxNum INT;
	-- Lương cơ bản không được phép bằng 0 hoặc âm
    IF @BasicSalary <= 0
    BEGIN
        PRINT N'Lỗi: Lương cơ bản (BasicSalary) phải lớn hơn 0.';
        RETURN -1;
    END

	-- 1. Tìm số lớn nhất sau chữ 'EMP'
    -- Cắt từ ký tự thứ 4 (sau chữ E, M, P) để lấy phần số
    SELECT @MaxNum = MAX(CAST(SUBSTRING(EmployeeID, 4, LEN(EmployeeID)) AS INT))
    FROM EMPLOYEE
    WHERE EmployeeID LIKE 'EMP%';

    -- 2. Tính toán số tiếp theo
    DECLARE @NextNum INT = ISNULL(@MaxNum, 0) + 1;

    -- 3. Kiểm tra giới hạn tối đa 4 chữ số (9999)
    IF @NextNum > 9999
    BEGIN
        PRINT N'Lỗi: Hệ thống đã đạt giới hạn tối đa 9,999 mã nhân viên (EMP9999).';
        RETURN -2;
    END

    -- 4. Tạo mã mới với định dạng EMP + 4 chữ số (Ví dụ: EMP0001)
    SET @NewEMP_ID = 'EMP' + RIGHT('000' + CAST(@NextNum AS NVARCHAR), 4);

    -- 3. Kiểm tra CCCD duy nhất
    IF EXISTS (SELECT 1 FROM EMPLOYEE WHERE CCCD = @CCCD)
    BEGIN
        PRINT N'Lỗi: Số CCCD đã tồn tại trong hệ thống.';
        RETURN -3;
    END

	-- 4. KIỂM TRA MANAGER CÓ TỒN TẠI VÀ CÓ PHẢI LÀ MANAGER KHÔNG
    IF @ManagerID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @ManagerID)
        BEGIN
            PRINT N'Lỗi: Mã người quản lý (ManagerID) không tồn tại trong hệ thống.';
            RETURN -4;
        END
        
        -- Kiểm tra xem người này có quyền Manager (IsManager = 1) hoặc Admin không
        IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @ManagerID AND (Role = 'Manager'))
        BEGIN
            PRINT N'Lỗi: Nhân viên ' + @ManagerID + N' không có quyền Quản lý (Manager).';
            RETURN -5;
        END
    END

    -- 4. Chèn nhân viên
    INSERT INTO EMPLOYEE (
        EmployeeID, FullName, Birthday, Gender, CCCD, Street, District, City,
        PhoneNumber, BasicSalary, Manager, CenterID, AccountLogin, 
        Role
    )
    VALUES (
        @NewEMP_ID, @FullName, @Birthday, @Gender, @CCCD, @Street, @District, @City,
        @PhoneNumber, @BasicSalary, @ManagerID, @CenterID, NULL,
        @Role
    );

    PRINT N'Thêm nhân viên thành công. Mã NV tự động: ' + @NewEMP_ID;
END;
GO


-- 1.2 Cấp tài khoản cho nhân viên đã có (NÚT CREATE)
IF OBJECT_ID('sp_Admin_AccountEmployees_CreateAccount') IS NOT NULL
    DROP PROCEDURE sp_Admin_AccountEmployees_CreateAccount;
GO

CREATE PROCEDURE sp_Admin_AccountEmployees_CreateAccount
    @EmployeeID NVARCHAR(50),
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    -- 1. Kiểm tra nhân viên có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @EmployeeID)
    BEGIN
        PRINT N'Lỗi: Nhân viên không tồn tại.'; RETURN -1;
    END
    
    -- 2. Kiểm tra nếu nhân viên đã có tài khoản rồi
    IF EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @EmployeeID AND AccountLogin IS NOT NULL)
    BEGIN
        PRINT N'Lỗi: Nhân viên này đã có tài khoản. Hãy dùng chức năng Update.'; RETURN -2;
    END

    -- 3. Kiểm tra Username có bị trùng trong hệ thống không
    IF EXISTS (SELECT 1 FROM ACCOUNT_LOGIN WHERE AccountLogin = @Username)
    BEGIN
        PRINT N'Lỗi: Tên đăng nhập này đã có người sử dụng.'; RETURN -3;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO ACCOUNT_LOGIN (AccountLogin, Password) VALUES (@Username, @Password);
        UPDATE EMPLOYEE SET AccountLogin = @Username WHERE EmployeeID = @EmployeeID;
        
        COMMIT TRANSACTION;
        PRINT N'Cấp tài khoản thành công cho nhân viên: ' + @EmployeeID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi hệ thống: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--1.3 Thay đổi thông tin tài khoản (NÚT UPDATE)
IF OBJECT_ID('sp_Admin_AccountEmployees_UpdateAccount') IS NOT NULL
    DROP PROCEDURE sp_Admin_AccountEmployees_UpdateAccount;
GO

CREATE PROCEDURE sp_Admin_AccountEmployees_UpdateAccount
    @EmployeeID NVARCHAR(50),
    @NewUsername NVARCHAR(50),
    @NewPassword NVARCHAR(255)
AS
BEGIN
    DECLARE @OldUsername NVARCHAR(50) = (SELECT AccountLogin FROM EMPLOYEE WHERE EmployeeID = @EmployeeID);
	-- 1. KIỂM TRA NHÂN VIÊN CÓ TỒN TẠI TRONG HỆ THỐNG KHÔNG
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @EmployeeID)
    BEGIN
        PRINT N'Lỗi: Nhân viên có mã ' + @EmployeeID + N' không tồn tại trên hệ thống.';
        RETURN -1;
    END
    
    IF @OldUsername IS NULL
    BEGIN
        PRINT N'Lỗi: Nhân viên này chưa có tài khoản để cập nhật. Hãy dùng nút Create.'; RETURN -2;
    END
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Nếu đổi tên đăng nhập, phải kiểm tra trùng
        IF @OldUsername <> @NewUsername AND EXISTS (SELECT 1 FROM ACCOUNT_LOGIN WHERE AccountLogin = @NewUsername)
        BEGIN
            PRINT N'Lỗi: Tên đăng nhập mới đã tồn tại.'; ROLLBACK; RETURN -3;
        END

        -- Cập nhật bảng Account (Cần tạo bản ghi mới và xóa bản ghi cũ vì AccountLogin là Primary Key)
        IF @OldUsername <> @NewUsername
        BEGIN
            INSERT INTO ACCOUNT_LOGIN (AccountLogin, Password) VALUES (@NewUsername, @NewPassword);
            UPDATE EMPLOYEE SET AccountLogin = @NewUsername WHERE EmployeeID = @EmployeeID;
            DELETE FROM ACCOUNT_LOGIN WHERE AccountLogin = @OldUsername;
        END
        ELSE
        BEGIN
            UPDATE ACCOUNT_LOGIN SET Password = @NewPassword WHERE AccountLogin = @OldUsername;
        END

        COMMIT TRANSACTION;
        PRINT N'Cập nhật tài khoản thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--1.4 Xóa tài khoản (NÚT DELETE)
IF OBJECT_ID('sp_Admin_AccountEmployees_DeleteAccount') IS NOT NULL
    DROP PROCEDURE sp_Admin_AccountEmployees_DeleteAccount;
GO

CREATE PROCEDURE sp_Admin_AccountEmployees_DeleteAccount
    @EmployeeID NVARCHAR(50)
AS
BEGIN
	-- 1. KIỂM TRA NHÂN VIÊN CÓ TỒN TẠI TRONG HỆ THỐNG KHÔNG
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @EmployeeID)
    BEGIN
        PRINT N'Lỗi: Nhân viên có mã ' + @EmployeeID + N' không tồn tại trên hệ thống.';
        RETURN -1;
    END
    DECLARE @Username NVARCHAR(50) = (SELECT AccountLogin FROM EMPLOYEE WHERE EmployeeID = @EmployeeID);

    IF @Username IS NULL
    BEGIN
        PRINT N'Lỗi: Nhân viên này vốn không có tài khoản.'; RETURN -2;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE EMPLOYEE SET AccountLogin = NULL WHERE EmployeeID = @EmployeeID;
        DELETE FROM ACCOUNT_LOGIN WHERE AccountLogin = @Username;
        
        COMMIT TRANSACTION;
        PRINT N'Đã xóa quyền truy cập (Tài khoản) của nhân viên.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--1.5 Click vào Menu "Account Employees": Hiện danh sách tài khoản
IF OBJECT_ID('sp_Admin_AccountEmployees_ViewList') IS NOT NULL
    DROP PROCEDURE sp_Admin_AccountEmployees_ViewList;
GO

CREATE PROCEDURE sp_Admin_AccountEmployees_ViewList
AS
BEGIN
    SELECT 
        E.EmployeeID, 
        E.AccountLogin, 
        A.Password, -- Hiển thị mật khẩu trực tiếp từ bảng ACCOUNT_LOGIN
        E.Role
    FROM EMPLOYEE E
    LEFT JOIN ACCOUNT_LOGIN A ON E.AccountLogin = A.AccountLogin;
END;
GO


--===========
--CHỨC NĂNG 2: XEM VÀ CẬP NHẬT THÔNG TIN HỆ THỐNG
--===========
--2.1 Nút Search (Nằm ở Tab View trong Dashboard) Xem các tham số hệ thống 
IF OBJECT_ID('sp_Admin_SystemParameters_Search') IS NOT NULL
    DROP PROCEDURE sp_Admin_SystemParameters_Search;
GO

CREATE PROCEDURE sp_Admin_SystemParameters_Search
    @FromDate DATE,
    @ToDate DATE
AS
BEGIN
    -- Kiểm tra tính hợp lệ của ngày
    IF @FromDate > @ToDate
    BEGIN
        PRINT N'Lỗi: Ngày bắt đầu không được lớn hơn ngày kết thúc.';
        RETURN -1;
    END

    SELECT 
        SystemPID, 
        SetupDate, 
        SetupTime, 
        MinBookingTime, 
        MaxBookingTime, 
        MaxCourtsPerCustomer
    FROM SYSTEM_PARAMETER
    WHERE SetupDate BETWEEN @FromDate AND @ToDate
    ORDER BY SetupDate DESC, SetupTime DESC;
END;
GO



--2.2 NÚT UPDATE khi Click vào Update/Change trong Dashboard (Cập nhật theo SystemPID)
IF OBJECT_ID('sp_Admin_Dashboard_Update') IS NOT NULL
    DROP PROCEDURE sp_Admin_Dashboard_Update;
GO

CREATE PROCEDURE sp_Admin_Dashboard_Update
    @SystemPID NVARCHAR(50),      -- Nhận vào mã PID để xác định bản ghi cần sửa
    @NewPrice DECIMAL(10, 2),
    @NewMinTime INT,
    @NewMaxTime INT,
    @NewMaxCourts INT
AS
BEGIN
    -- 1. Kiểm tra bản ghi có tồn tại theo SystemPID không
    IF NOT EXISTS (SELECT 1 FROM SYSTEM_PARAMETER WHERE SystemPID = @SystemPID)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy thiết lập có mã ' + @SystemPID + N' để cập nhật.';
        RETURN -1;
    END

    -- 2. Kiểm tra tính hợp lệ của số liệu (Phải là số dương > 0)
    -- Kiểm tra Đơn giá
    IF @NewPrice <= 0
    BEGIN
        PRINT N'Lỗi: Đơn giá mới (NewPrice) phải lớn hơn 0.';
        RETURN -2;
    END

    -- Kiểm tra Số lượng sân tối đa
    IF @NewMaxCourts <= 0
    BEGIN
        PRINT N'Lỗi: Số lượng sân đặt tối đa (NewMaxCourts) phải lớn hơn 0.';
        RETURN -3;
    END

    -- 3. Kiểm tra logic thời gian đặt sân
    -- Thời gian tối thiểu > 0 và thời gian tối đa phải lớn hơn thời gian tối thiểu
    IF @NewMinTime <= 0 OR @NewMaxTime <= @NewMinTime
    BEGIN
        PRINT N'Lỗi: Dữ liệu thời gian đặt sân không hợp lệ (Phải > 0 và Min < Max).';
        RETURN -4;
    END

    -- 3. Thực hiện cập nhật dựa trên SystemPID
    -- Chúng ta giữ nguyên SetupDate và SetupTime gốc để bảo toàn lịch sử thời điểm tạo ban đầu
    UPDATE SYSTEM_PARAMETER
    SET Price = @NewPrice,
        MinBookingTime = @NewMinTime,
        MaxBookingTime = @NewMaxTime,
        MaxCourtsPerCustomer = @NewMaxCourts
    WHERE SystemPID = @SystemPID;

    PRINT N'Cập nhật tham số hệ thống có mã ' + @SystemPID + N' thành công.';
END;
GO

--2.3 Khi nhấn vào Tab System Parameter: Hiện toàn bộ tham số
IF OBJECT_ID('sp_Admin_Dashboard_ShowAllParams') IS NOT NULL
    DROP PROCEDURE sp_Admin_Dashboard_ShowAllParams;
GO

CREATE PROCEDURE sp_Admin_Dashboard_ShowAllParams
AS
BEGIN
    SELECT 
        SystemPID, 
        SetupDate, 
        SetupTime, 
        Price, 
        MinBookingTime, 
        MaxBookingTime, 
        MaxCourtsPerCustomer, 
        AID AS AdminID
    FROM SYSTEM_PARAMETER
    ORDER BY SetupDate DESC, SetupTime DESC; -- Hiện cái mới nhất lên đầu
END;
GO

--2.4 Thêm mới 1 tham số hệ thống (ADD)
IF OBJECT_ID('sp_Admin_SystemParameters_Add') IS NOT NULL
    DROP PROCEDURE sp_Admin_SystemParameters_Add;
GO

CREATE PROCEDURE sp_Admin_SystemParameters_Add
    @Price DECIMAL(10, 2),
    @MinBookingTime INT,
    @MaxBookingTime INT,
    @MaxCourtsPerCustomer INT,
    @AID NVARCHAR(50) -- Mã Admin thực hiện
AS
BEGIN
	-- 1. KIỂM TRA QUYỀN ADMIN
    -- Kiểm tra xem mã nhân viên có tồn tại và IsAdmin có bằng 1 hay không
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @AID AND Role = 'Admin')
    BEGIN
        PRINT N'Lỗi: Nhân viên ' + @AID + N' không có quyền Admin để thực hiện thao tác này.';
        RETURN -1;
    END

	-- 2. KIỂM TRA RÀNG BUỘC GIÁ TRỊ DƯƠNG (> 0)
    IF @Price <= 0
    BEGIN
        PRINT N'Lỗi: Đơn giá sân (Price) phải lớn hơn 0.';
        RETURN -2;
    END

    IF @MaxCourtsPerCustomer <= 0
    BEGIN
        PRINT N'Lỗi: Số lượng sân đặt tối đa phải lớn hơn 0.';
        RETURN -3;
    END

    DECLARE @NewPID NVARCHAR(50);
    DECLARE @MaxNum INT;

    -- 1. Tìm số lớn nhất hiện tại sau chữ 'SPM'
    SELECT @MaxNum = MAX(CAST(SUBSTRING(SystemPID, 4, LEN(SystemPID)) AS INT))
    FROM SYSTEM_PARAMETER 
    WHERE SystemPID LIKE 'SPM%';

    -- 2. Tính toán số thứ tự tiếp theo
    DECLARE @NextNum INT = ISNULL(@MaxNum, 0) + 1;

    -- 3. Kiểm tra giới hạn (Chỉ cho phép đến 999)
    IF @NextNum > 999
    BEGIN
        PRINT N'Lỗi: Hệ thống đã đạt giới hạn tối đa 999 mã tham số (SPM999).';
        RETURN -4;
    END

    -- 4. Tạo mã mới với định dạng SPM + 3 chữ số (Ví dụ: SPM001)
    SET @NewPID = 'SPM' + RIGHT('00' + CAST(@NextNum AS NVARCHAR), 3);

    -- Kiểm tra logic dữ liệu
	IF @MinBookingTime <= 0 OR @MinBookingTime >= @MaxBookingTime OR @MaxBookingTime <= 0
	BEGIN
        PRINT N'Lỗi: MinBookingTime phải nhỏ hơn MaxBookingTime.';
        RETURN -5;
    END

    INSERT INTO SYSTEM_PARAMETER (
        SystemPID, SetupDate, SetupTime, Price, 
        MinBookingTime, MaxBookingTime, MaxCourtsPerCustomer, AID
    )
    VALUES (
        @NewPID, GETDATE(), GETDATE(), @Price, 
        @MinBookingTime, @MaxBookingTime, @MaxCourtsPerCustomer, @AID
    );

    PRINT N'Thêm mới tham số hệ thống thành công. Mã: ' + @NewPID;
END;
GO

--2.5 Xóa tham số hệ thống
IF OBJECT_ID('sp_Admin_SystemParameters_Delete') IS NOT NULL
    DROP PROCEDURE sp_Admin_SystemParameters_Delete;
GO

CREATE PROCEDURE sp_Admin_SystemParameters_Delete
    @SystemPID NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SYSTEM_PARAMETER WHERE SystemPID = @SystemPID)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy tham số để xóa.';
        RETURN -1;
    END

    DELETE FROM SYSTEM_PARAMETER WHERE SystemPID = @SystemPID;
    PRINT N'Xóa tham số hệ thống ' + @SystemPID + N' thành công.';
END;
GO

--===========
--TEST
--===========
-- 1. Tạo Trung tâm mẫu
INSERT INTO SPORT_CENTER (CenterID, Address, Hotline, OpenTime, CloseTime, Owner)
VALUES ('CN001', N'123 Đường ABC, Quận 1, HCM', '0901234567', '06:00:00', '22:00:00', N'Nguyễn Văn A');


GO
--CN1:

EXEC sp_Admin_AccountEmployees_Add 
    @FullName = N'Nguyễn Văn A', 
    @Birthday = '1995-01-01', 
    @Gender = N'Nam', 
    @CCCD = '501200001234', 
    @PhoneNumber = '0901234567', 
    @BasicSalary = 10000000, 
    @CenterID = 'CN001', 
    @Role = 'Admin',
    @Street = N'Lê Lợi', 
    @District = N'Quận 1', 
    @City = N'TP. Hồ Chí Minh';



	SELECT * FROM EMPLOYEE WHERE EmployeeID = 'CUS00003';
	--test 1.2
	EXEC sp_Admin_AccountEmployees_CreateAccount 
    @EmployeeID = 'EMP0152', 
    @Username = 'thangle95', 
    @Password = 'Thang@123';
	

	select*from ACCOUNT_LOGIN where AccountLogin='thangle95'
	--test 1.3
	--test 1.4