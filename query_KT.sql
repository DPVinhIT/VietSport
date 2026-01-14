CREATE OR ALTER PROC sp_TN1_Tech_GetCourtMaintenance
    @CenterID   NVARCHAR(50),
    @CourtID    NVARCHAR(50) = NULL,
    @Status     NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sc.CourtID,
        sc.CourtType,
        sc.Capacity,
        sc.UnitPrice,
        sc.CenterID,
        sc.Status
    FROM dbo.SPORT_COURT sc
    WHERE sc.CenterID = @CenterID
      AND (@CourtID IS NULL OR sc.CourtID = @CourtID)
      AND (@Status IS NULL OR LTRIM(RTRIM(sc.Status)) = LTRIM(RTRIM(@Status)))
      AND LTRIM(RTRIM(sc.Status)) IN (N'Có thể sử dụng', N'Đang bảo trì')
    ORDER BY sc.CourtID;
END
GO


CREATE OR ALTER PROC sp_TN1_Tech_UpdateCourtStatusOnly
    @CenterID   NVARCHAR(50),
    @CourtID    NVARCHAR(50),
    @Status     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate theo đúng dữ liệu DB
    IF LTRIM(RTRIM(@Status)) NOT IN (N'Có thể sử dụng', N'Đang bảo trì')
    BEGIN
        SELECT 0 AS Result, N'Trạng thái không hợp lệ.' AS Message;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.SPORT_COURT
        WHERE CourtID = @CourtID AND CenterID = @CenterID
    )
    BEGIN
        SELECT 0 AS Result, N'Không tìm thấy sân trong trung tâm này.' AS Message;
        RETURN;
    END

    UPDATE dbo.SPORT_COURT
    SET Status = LTRIM(RTRIM(@Status))
    WHERE CourtID = @CourtID AND CenterID = @CenterID;

    SELECT 1 AS Result, N'Cập nhật trạng thái thành công.' AS Message;
END
GO

CREATE OR ALTER PROC sp_TN2_Tech_GetWorkScheduleByDate
    @EmployeeID NVARCHAR(50),
    @WorkDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ws.EmployeeID,
        ws.WorkDate,
        ws.WorkTime,
        ws.Shift,
        ws.MID,
        m.FullName AS ManagerName
    FROM dbo.WORK_SCHEDULE ws
    LEFT JOIN dbo.EMPLOYEE m ON m.EmployeeID = ws.MID
    WHERE ws.EmployeeID = @EmployeeID
      AND ws.WorkDate = @WorkDate
    ORDER BY ws.WorkTime;
END
GO

CREATE OR ALTER PROC sp_TN3_Tech_ViewMaintenanceReports
    @CenterID     NVARCHAR(50),
    @CourtStatus  NVARCHAR(50) = NULL   -- NULL => All
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        mr.ReportID,
        mr.TimeRepair,
        mr.CourtStatus,
        mr.IssueDescription,
        mr.CourtID,
        sc.CenterID,
        mr.TID
    FROM dbo.MAINTENANCE_REPORT mr
    INNER JOIN dbo.SPORT_COURT sc
        ON sc.CourtID = mr.CourtID
    WHERE
        sc.CenterID = @CenterID
        AND (
            @CourtStatus IS NULL
            OR mr.CourtStatus = @CourtStatus
        )
    ORDER BY mr.TimeRepair DESC, mr.ReportID DESC;
END
GO

CREATE OR ALTER PROC dbo.sp_TN3_Tech_AddMaintenanceReport
    @CenterID         NVARCHAR(50),
    @CourtID          NVARCHAR(50),
    @CourtStatus      NVARCHAR(50),       -- N'Đã xử lý' | N'Vẫn đang xử lý' | N'Thiếu vật liệu'
    @IssueDescription NVARCHAR(MAX) = NULL,
    @TimeRepair       DATETIME,           -- bắt buộc
    @TID              NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- 0) TimeRepair NOT NULL
    IF @TimeRepair IS NULL
    BEGIN
        SELECT 0 AS Result, N'TimeRepair không được để trống.' AS Message;
        RETURN;
    END

    -- 1) validate status
    IF @CourtStatus NOT IN (N'Đã xử lý', N'Vẫn đang xử lý', N'Thiếu vật liệu')
    BEGIN
        SELECT 0 AS Result, N'CourtStatus không hợp lệ.' AS Message;
        RETURN;
    END

    -- 2) check Technician thuộc Center
    IF NOT EXISTS (
        SELECT 1
        FROM EMPLOYEE
        WHERE EmployeeID = @TID AND CenterID = @CenterID
    )
    BEGIN
        SELECT 0 AS Result, N'Kỹ thuật viên không thuộc trung tâm này.' AS Message;
        RETURN;
    END

    -- 3) check CourtID thuộc Center
    IF NOT EXISTS (
        SELECT 1
        FROM SPORT_COURT
        WHERE CourtID = @CourtID AND CenterID = @CenterID
    )
    BEGIN
        SELECT 0 AS Result, N'CourtID không thuộc trung tâm của bạn.' AS Message;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- 4) generate ReportID an toàn (chống trùng khi chạy đồng thời)
        DECLARE @Next INT;

        SELECT @Next =
            ISNULL(
                MAX(CAST(SUBSTRING(ReportID, 3, 10) AS INT)),
                0
            ) + 1
        FROM MAINTENANCE_REPORT WITH (UPDLOCK, HOLDLOCK)
        WHERE ReportID LIKE N'MR%';

        DECLARE @ReportID NVARCHAR(50) =
            N'MR' + RIGHT('0000' + CAST(@Next AS VARCHAR(10)), 4);

        -- 5) insert
        INSERT INTO MAINTENANCE_REPORT
            (ReportID, TimeRepair, CourtStatus, IssueDescription, CourtID, TID)
        VALUES
            (@ReportID, @TimeRepair, @CourtStatus, @IssueDescription, @CourtID, @TID);

        COMMIT TRAN;

        SELECT 1 AS Result, N'Thêm report thành công: ' + @ReportID AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        SELECT 0 AS Result,
               N'Lỗi thêm report: ' + ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROC sp_TN4_Tech_SearchLeaveForm
    @EmployeeID NVARCHAR(50),
    @DateCreate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LeaveFormID,
        EmployeeID,
        WorkDate,
        WorkTime,
        DateCreate,
        Reason,
        Status
    FROM LEAVEFORM
    WHERE EmployeeID = @EmployeeID
      AND DateCreate = @DateCreate
    ORDER BY DateCreate DESC;
END
GO


CREATE OR ALTER PROC sp_TN4_Tech_AddLeaveForm
    @EmployeeID NVARCHAR(50),
    @WorkDate   DATE,
    @WorkTime   TIME(0),
    @Reason     NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 0) validate input
        IF @WorkDate IS NULL OR @WorkTime IS NULL OR LTRIM(RTRIM(ISNULL(@Reason,''))) = ''
        BEGIN
            SELECT 0 AS Result, N'Thiếu WorkDate/WorkTime/Reason.' AS Message;
            ROLLBACK;
            RETURN;
        END

        -- 1) chỉ cho xin nghỉ từ hôm nay trở đi
        IF @WorkDate < CONVERT(date, GETDATE())
        BEGIN
            SELECT 0 AS Result, N'Chỉ được xin nghỉ từ ngày hiện tại trở đi.' AS Message;
            ROLLBACK;
            RETURN;
        END

        -- 2) chỉ cho 3 khung giờ
        IF @WorkTime NOT IN (CAST('07:00:00' AS TIME(0)), CAST('13:00:00' AS TIME(0)), CAST('18:00:00' AS TIME(0)))
        BEGIN
            SELECT 0 AS Result, N'WorkTime không hợp lệ (chỉ 07:00 / 13:00 / 18:00).' AS Message;
            ROLLBACK;
            RETURN;
        END

        -- 3) bắt buộc ca đó tồn tại
        IF NOT EXISTS (
            SELECT 1
            FROM WORK_SCHEDULE ws
            WHERE ws.EmployeeID = @EmployeeID
              AND ws.WorkDate   = @WorkDate
              AND ws.WorkTime   = @WorkTime
        )
        BEGIN
            SELECT 0 AS Result, N'Không tồn tại ca làm này trong WorkSchedule.' AS Message;
            ROLLBACK;
            RETURN;
        END

        -- 4) chặn trùng đơn Pending
        IF EXISTS (
            SELECT 1
            FROM LEAVEFORM
            WHERE EmployeeID = @EmployeeID
              AND WorkDate   = @WorkDate
              AND WorkTime   = @WorkTime
              AND Status     = N'Pending'
        )
        BEGIN
            SELECT 0 AS Result, N'Ca này đã có đơn Pending rồi.' AS Message;
            ROLLBACK;
            RETURN;
        END

        -- 5) demo sinh ID đơn giản (demo phantom thì khỏi UPDLOCK cũng được)
        DECLARE @Next INT = (SELECT COUNT(*) + 1 FROM LEAVEFORM);
        DECLARE @LeaveFormID NVARCHAR(50) = N'LFM' + RIGHT('0000' + CAST(@Next AS VARCHAR(10)), 4);

        -- 6) insert
        INSERT INTO LEAVEFORM (LeaveFormID, EmployeeID, WorkDate, WorkTime, DateCreate, Reason, Status)
        VALUES (@LeaveFormID, @EmployeeID, @WorkDate, @WorkTime, GETDATE(), @Reason, N'Pending');

        COMMIT;

        SELECT 1 AS Result, N'Tạo đơn nghỉ thành công: ' + @LeaveFormID AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT 0 AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROC sp_TN5_Tech_ViewPayrollByEmployee
    @EmployeeID NVARCHAR(50),
    @Month      INT,
    @Year       INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate nhân viên tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM EMPLOYEE WHERE EmployeeID = @EmployeeID
    )
    BEGIN
        RAISERROR (N'Nhân viên không tồn tại', 16, 1);
        RETURN;
    END

    -- Lấy bảng lương
    SELECT
        p.PayrollID,
        e.EmployeeID,
        e.FullName,
        p.Month,
        p.Year,
        p.BasicSalary,
        p.Allowance,
        p.ShiftPay,
        p.SaleCommission,
        p.PenaltyFee,

        -- Tổng thu nhập
        TotalIncome =
              ISNULL(p.BasicSalary, 0)
            + ISNULL(p.Allowance, 0)
            + ISNULL(p.ShiftPay, 0)
            + ISNULL(p.SaleCommission, 0),

        -- Thực lãnh
        NetSalary =
              ISNULL(p.BasicSalary, 0)
            + ISNULL(p.Allowance, 0)
            + ISNULL(p.ShiftPay, 0)
            + ISNULL(p.SaleCommission, 0)
            - ISNULL(p.PenaltyFee, 0)

    FROM PAYROLL p
    JOIN EMPLOYEE e ON e.EmployeeID = p.EmployeeID
    WHERE p.EmployeeID = @EmployeeID
      AND p.Month = @Month
      AND p.Year  = @Year;
END
GO

CREATE OR ALTER PROC sp_TN6_Tech_ChangePassword
    @AccountLogin    NVARCHAR(50),
    @OldPassword     NVARCHAR(255),
    @NewPassword     NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- validate
    SET @AccountLogin = NULLIF(LTRIM(RTRIM(@AccountLogin)), '');
    SET @OldPassword  = ISNULL(@OldPassword, '');
    SET @NewPassword  = ISNULL(@NewPassword, '');

    IF @AccountLogin IS NULL
    BEGIN
        SELECT 0 AS Result, N'Tài khoản không hợp lệ.' AS Message;
        RETURN;
    END

    IF @NewPassword = ''
    BEGIN
        SELECT 0 AS Result, N'Mật khẩu mới không được để trống.' AS Message;
        RETURN;
    END

    -- Check tài khoản + mật khẩu cũ đúng
    IF NOT EXISTS (
        SELECT 1
        FROM ACCOUNT_LOGIN
        WHERE AccountLogin = @AccountLogin AND [Password] = @OldPassword
    )
    BEGIN
        SELECT 0 AS Result, N'Sai mật khẩu cũ hoặc không tồn tại tài khoản.' AS Message;
        RETURN;
    END

    -- Update mật khẩu mới
    UPDATE ACCOUNT_LOGIN
    SET [Password] = @NewPassword
    WHERE AccountLogin = @AccountLogin;

    SELECT 1 AS Result, N'Đổi mật khẩu thành công.' AS Message;
END
GO
