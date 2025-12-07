import csv
import random
from datetime import datetime, timedelta

from faker import Faker

fake = Faker("vi_VN")
random.seed(42)
CITIES_DISTRICTS = {
    "TP. Hồ Chí Minh": [
        "Quận 1",
        "Quận 3",
        "Quận 5",
        "Quận 7",
        "Quận 10",
        "Bình Thạnh",
        "Gò Vấp",
        "Tân Bình",
        "Tân Phú",
        "Thủ Đức",
    ],
    "Hà Nội": [
        "Ba Đình",
        "Hoàn Kiếm",
        "Đống Đa",
        "Cầu Giấy",
        "Thanh Xuân",
        "Hai Bà Trưng",
        "Hoàng Mai",
        "Long Biên",
    ],
    "Đà Nẵng": [
        "Hải Châu",
        "Thanh Khê",
        "Sơn Trà",
        "Ngũ Hành Sơn",
        "Liên Chiểu",
        "Cẩm Lệ",
    ],
}


# ================== SỐ LƯỢNG BẢN GHI (<= 1500) ==================
N_CENTER = 5
N_EMPLOYEE = 120
N_SYSTEM_PARAM = 20
N_SCHEDULE = 500
N_ATTENDANCE = 1200
N_LEAVEFORM = 200
N_CUSTOMER = 800
N_COACH = 50
N_BOOKING = 1200
N_MEMBER_CARD = 500
N_CANCEL_RULE = 20
N_DISCOUNT = 50
N_PAYROLL = 600
N_COURT_TYPE = 4
N_SPORT_COURT = 60
N_INVOICE = 1100
N_CANCEL_FORM = 200
N_SERVICE = 80
N_SERVICE_BOOK = 1000
N_PERSONAL_CLOSET = 80
N_RENT_EQUIP = 80
N_VIP_ROOM = 30
N_RENT_HLV = 70

# ================== HÀM TIỆN ÍCH ==================


def random_date(start, end):
    delta = end - start
    return start + timedelta(days=random.randrange(delta.days + 1))


def random_datetime(start, end):
    delta = end - start
    seconds = random.randrange(delta.days * 24 * 3600 + 1)
    return start + timedelta(seconds=seconds)


def pick(lst):
    return random.choice(lst)


def gen_phone():
    prefixes = ["03", "05", "07", "08", "09"]
    prefix = random.choice(prefixes)
    number = "".join(
        str(random.randint(0, 9)) for _ in range(8)
    )  # 8 số còn lại
    return prefix + number


# ================== MAIN ==================


def main():
    # Tập hợp tất cả account login đã dùng (account -> password)
    accounts = {}

    # ---------- 1. SPORT_CENTER ----------
    center_ids = []
    with open("SPORT_CENTER.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CenterID", "Address", "Hotline", "OpenTime", "CloseTime", "Owner"]
        )
        for i in range(1, N_CENTER + 1):
            cid = f"CEN{i:03d}"
            center_ids.append(cid)
            w.writerow(
                [
                    cid,
                    fake.address().replace("\n", ", "),
                    fake.phone_number(),
                    "06:00:00",
                    "23:00:00",
                    fake.name(),
                ]
            )

    # ---------- 2. EMPLOYEE ----------
    employee_ids = []

    role_prefix_counters = {
        "MN": 1,  # Manager
        "RC": 1,  # Receptionist
        "TN": 1,  # Technician
        "CS": 1,  # Cashier
        "AD": 1,  # Admin
    }

    with open("EMPLOYEE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "EmployeeID",
                "FullName",
                "Birthday",
                "Gender",
                "CCCD",
                "Street",
                "District",
                "City",
                "PhoneNumber",
                "Role",
                "BasicSalary",
                "Manager",
                "CenterID",
                "AccountLogin",
                "IsManager",
                "IsReceptionist",
                "IsTechnician",
                "IsCashier",
                "IsAdmin",
            ]
        )

        for i in range(1, N_EMPLOYEE + 1):
            emp_id = f"EMP{i:04d}"
            employee_ids.append(emp_id)

        manager_pool = []

        for emp_id in employee_ids:
            birthday = random_date(
                datetime(1975, 1, 1), datetime(2003, 12, 31)
            ).date()
            gender = random.choice(["Nam", "Nữ"])
            role = random.choice(
                ["Quản lý", "Lễ tân", "Kỹ thuật viên", "Thu ngân", "Admin"]
            )

            is_mgr = 1 if role == "Quản lý" else 0
            is_rec = 1 if role == "Lễ tân" else 0
            is_tech = 1 if role == "Kỹ thuật viên" else 0
            is_cash = 1 if role == "Thu ngân" else 0
            is_admin = 1 if role == "Admin" else 0

            if is_mgr:
                manager_pool.append(emp_id)

            manager_id = ""
            if manager_pool and not is_mgr and random.random() < 0.7:
                manager_id = pick(manager_pool)

            center_id = pick(center_ids)

            # ---- ĐỊA CHỈ ĐẸP ----
            city = pick(list(CITIES_DISTRICTS.keys()))
            district = pick(CITIES_DISTRICTS[city])
            street = f"{random.randint(1, 200)} {fake.street_name()}"

            # ---- ACCOUNT LOGIN THEO ROLE ----
            if role == "Quản lý":
                prefix = "MN"
            elif role == "Lễ tân":
                prefix = "RC"
            elif role == "Kỹ thuật viên":
                prefix = "TN"
            elif role == "Thu ngân":
                prefix = "CS"
            else:
                prefix = "AD"

            counter = role_prefix_counters[prefix]
            role_prefix_counters[prefix] += 1
            acc_login = f"{prefix}{counter:04d}"
            password = f"{acc_login}@123"
            accounts[acc_login] = password

            w.writerow(
                [
                    emp_id,
                    fake.name(),
                    birthday,
                    gender,
                    f"{random.randint(100000000000,999999999999)}",
                    street,
                    district,
                    city,
                    gen_phone(),
                    role,
                    random.randint(5_000_000, 30_000_000),
                    manager_id,
                    center_id,
                    acc_login,
                    is_mgr,
                    is_rec,
                    is_tech,
                    is_cash,
                    is_admin,
                ]
            )

    # ---------- 3. SYSTEM_PARAMETER ----------
    with open("SYSTEM_PARAMETER.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "SystemPID",
                "SetupDate",
                "SetupTime",
                "Price",
                "MinBookingTime",
                "MaxBookingTime",
                "MaxCourtsPerCustomer",
                "AID",
            ]
        )
        for i in range(1, N_SYSTEM_PARAM + 1):
            setup = random_datetime(
                datetime(2021, 1, 1), datetime(2024, 12, 31)
            )
            sys_id = f"SPM{i:03d}"
            aid = pick(employee_ids)
            w.writerow(
                [
                    sys_id,
                    setup.date(),
                    setup.time().strftime("%H:%M:%S"),
                    random.randint(50_000, 300_000),
                    30,
                    120,
                    random.randint(1, 4),
                    aid,
                ]
            )

    # ---------- 4. EMPLOYEE_SCHEDULE ----------
    schedule_ids = []
    with open("EMPLOYEE_SCHEDULE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["ScheduleID", "StartTime", "EndTime"])
        for i in range(1, N_SCHEDULE + 1):
            sch_id = f"SCH{i:04d}"
            start = random_datetime(
                datetime(2024, 1, 1, 6, 0), datetime(2024, 12, 31, 20, 0)
            )
            end = start + timedelta(hours=random.choice([4, 6, 8]))
            schedule_ids.append(sch_id)
            w.writerow([sch_id, start, end])

    # ---------- 5. ATTENDANCE ----------
    with open("ATTENDANCE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "AttendanceID",
                "EmployeeID",
                "ScheduleID",
                "CheckIn",
                "CheckOut",
                "Status",
            ]
        )
        for i in range(1, N_ATTENDANCE + 1):
            att_id = f"ATT{i:05d}"
            emp = pick(employee_ids)
            sch = pick(schedule_ids)
            status = random.choice(["Đúng giờ", "Trễ", "Vắng"])
            start = random_datetime(
                datetime(2024, 1, 1, 6, 0), datetime(2024, 12, 31, 20, 0)
            )
            check_in = start + timedelta(minutes=random.randint(-10, 30))
            check_out = check_in + timedelta(hours=random.choice([4, 6, 8]))
            w.writerow([att_id, emp, sch, check_in, check_out, status])

    # ---------- 6. LEAVEFORM ----------
    with open("LEAVEFORM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "LeaveFormID",
                "EmployeeID",
                "ScheduleID",
                "DateCreate",
                "Reason",
                "Status",
            ]
        )
        reasons = ["Nghỉ bệnh", "Việc gia đình", "Nghỉ phép năm"]
        for i in range(1, N_LEAVEFORM + 1):
            lf_id = f"LFM{i:04d}"
            emp = pick(employee_ids)
            sch = pick(schedule_ids)
            dt = random_datetime(datetime(2024, 1, 1), datetime(2024, 12, 31))
            status = random.choice(["Pending", "Approved", "Rejected"])
            w.writerow([lf_id, emp, sch, dt, random.choice(reasons), status])

    # ---------- 7. CUSTOMER ----------
    customer_ids = []
    with open("CUSTOMER.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "CustomerID",
                "FullName",
                "Birthday",
                "PhoneNumber",
                "Email",
                "Address",
                "IsOnline",
                "IsDirectly",
                "AccountLogin",
            ]
        )
        for i in range(1, N_CUSTOMER + 1):
            cid = f"CUS{i:05d}"
            customer_ids.append(cid)
            birthday = random_date(
                datetime(1970, 1, 1), datetime(2010, 12, 31)
            ).date()

            is_online = 1 if random.random() < 0.4 else 0
            is_direct = 1 if random.random() < 0.7 else 0

            acc_login = ""

            def generate_unique_username():
                base = fake.user_name()[:20] or "user"
                username = base
                suffix = 1
                while username in accounts:
                    username = f"{base}{suffix}"
                    suffix += 1
                return username

            if is_online == 1:
                login = generate_unique_username()
                password = fake.password(length=10)
                accounts[login] = password
                acc_login = login
            elif is_direct == 1 and random.random() < 0.5:
                login = generate_unique_username()
                password = fake.password(length=10)
                accounts[login] = password
                acc_login = login

            # Địa chỉ full cho khách hàng
            city = pick(list(CITIES_DISTRICTS.keys()))
            district = pick(CITIES_DISTRICTS[city])
            street = f"{random.randint(1, 200)} {fake.street_name()}"
            full_address = f"{street}, {district}, {city}"

            w.writerow(
                [
                    cid,
                    fake.name(),
                    birthday,
                    gen_phone(),
                    fake.email(),
                    full_address,
                    is_online,
                    is_direct,
                    acc_login,
                ]
            )

    # ---------- 8. COACH ----------
    coach_ids = []
    with open("COACH.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CoachID", "FullName", "Specialization", "ScheduleWork", "Price"]
        )
        for i in range(1, N_COACH + 1):
            co_id = f"COA{i:03d}"
            coach_ids.append(co_id)
            spec = random.choice(
                ["Bóng đá", "Cầu lông", "Tennis", "Bóng rổ", "Gym"]
            )
            sched = random.choice(["Sáng", "Chiều", "Tối", "Cả ngày"])
            price = random.randint(200_000, 800_000)
            w.writerow([co_id, fake.name(), spec, sched, price])

    # ---------- 9. COURT_TYPE ----------
    court_types = []
    with open("COURT_TYPE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["CourtType", "TypeofRental"])
        type_data = [
            ("CTP01", "Sân bóng đá 5 người"),
            ("CTP02", "Sân cầu lông"),
            ("CTP03", "Sân tennis"),
            ("CTP04", "Sân bóng rổ"),
        ]
        for ct_id, name in type_data[:N_COURT_TYPE]:
            court_types.append(ct_id)
            w.writerow([ct_id, name])

    # ---------- 10. SPORT_COURT ----------
    court_ids = []
    with open("SPORT_COURT.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CourtID", "CourtType", "Capacity", "UnitPrice", "CenterID"]
        )
        for i in range(1, N_SPORT_COURT + 1):
            crt_id = f"CRT{i:04d}"
            ctype = pick(court_types)
            cap = random.choice([4, 6, 10])
            price = random.randint(200_000, 1_000_000)
            center_id = pick(center_ids)
            court_ids.append(crt_id)
            w.writerow([crt_id, ctype, cap, price, center_id])

    # ---------- 11. BOOKING_FORM ----------
    booking_ids = []
    with open("BOOKING_FORM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "BookingID",
                "CourtType",
                "OrderDate",
                "OrderTime",
                "StartTime",
                "EndTime",
                "Status",
                "CustomerID",
                "SportCenterID",
                "RID",
            ]
        )
        court_type_names = ["Bóng đá", "Cầu lông", "Tennis", "Bóng rổ"]
        for i in range(1, N_BOOKING + 1):
            bkid = f"BKG{i:05d}"
            booking_ids.append(bkid)
            ctype_name = random.choice(court_type_names)
            order_dt = random_datetime(
                datetime(2024, 1, 1), datetime(2024, 12, 31)
            )
            start = order_dt + timedelta(
                days=random.randint(0, 10), hours=random.randint(0, 10)
            )
            end = start + timedelta(hours=random.choice([1, 2, 3]))
            status = random.choice(["Pending", "Confirmed", "Cancelled"])
            w.writerow(
                [
                    bkid,
                    ctype_name,
                    order_dt.date(),
                    order_dt.time().strftime("%H:%M:%S"),
                    start,
                    end,
                    status,
                    pick(customer_ids),
                    pick(center_ids),
                    pick(employee_ids),
                ]
            )

    # ---------- 12. MEMBER_CARD ----------
    with open("MEMBER_CARD.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["CardID", "MembershipLevel", "CustomerID"])
        levels = ["Silver", "Gold", "Platinum", "Diamond"]
        for i in range(1, N_MEMBER_CARD + 1):
            card_id = f"MBC{i:05d}"
            w.writerow([card_id, random.choice(levels), pick(customer_ids)])

    # ---------- 13. CANCEL_RULE ----------
    cancel_rule_ids = []
    with open("CANCEL_RULE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "CanCelRuleID",
                "RuleName",
                "MinimumTime",
                "TimeUnit",
                "PenaltyFee",
                "MID",
            ]
        )
        units = ["Giờ", "Ngày"]
        for i in range(1, N_CANCEL_RULE + 1):
            crid = f"CRL{i:03d}"
            cancel_rule_ids.append(crid)
            w.writerow(
                [
                    crid,
                    f"Quy định hủy {i}",
                    random.randint(1, 24),
                    random.choice(units),
                    random.randint(50_000, 500_000),
                    pick(employee_ids),
                ]
            )

    # ---------- 14. DISCOUNT ----------
    discount_ids = []
    with open("DISCOUNT.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "DiscountID",
                "DiscountName",
                "StartDate",
                "EndDate",
                "Pecentage",
                "TargetUser",
                "MID",
            ]
        )
        targets = ["Tất cả", "Thành viên", "Khách mới", "Đặt online"]
        for i in range(1, N_DISCOUNT + 1):
            did = f"DSC{i:03d}"
            discount_ids.append(did)
            start = random_date(
                datetime(2023, 1, 1), datetime(2024, 6, 30)
            ).date()
            end = start + timedelta(days=random.randint(7, 60))
            w.writerow(
                [
                    did,
                    f"Khuyến mãi {i}",
                    start,
                    end,
                    random.choice([5, 10, 15, 20]),
                    random.choice(targets),
                    pick(employee_ids),
                ]
            )

    # ---------- 15. PAYROLL ----------
    with open("PAYROLL.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "PayrollID",
                "Month",
                "Year",
                "BasicSalary",
                "Allowance",
                "ShiftPay",
                "SaleCommission",
                "PenatyFee",
                "EmployeeID",
            ]
        )
        for i in range(1, N_PAYROLL + 1):
            pr_id = f"PRL{i:05d}"
            month = random.randint(1, 12)
            year = random.choice([2023, 2024])
            base = random.randint(5_000_000, 30_000_000)
            allow = random.randint(0, 3_000_000)
            shift = random.randint(0, 5_000_000)
            sale = random.randint(0, 5_000_000)
            penalty = random.randint(0, 1_000_000)
            w.writerow(
                [
                    pr_id,
                    month,
                    year,
                    base,
                    allow,
                    shift,
                    sale,
                    penalty,
                    pick(employee_ids),
                ]
            )

    # ---------- 16. SERVICE ----------
    service_ids = []
    with open("SERVICE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "ServiceID",
                "ServiceName",
                "TimeUnitType",
                "Price",
                "AvailableStatus",
            ]
        )
        names = [
            "Tủ đồ cá nhân",
            "Thuê dụng cụ",
            "Phòng VIP",
            "Thuê HLV",
            "Nước uống",
            "Khăn tắm",
        ]
        unit_types = ["Giờ", "Lượt", "Ngày"]
        statuses = ["Đang hoạt động", "Tạm ngưng"]
        for i in range(1, N_SERVICE + 1):
            sid = f"SRV{i:04d}"
            service_ids.append(sid)
            w.writerow(
                [
                    sid,
                    random.choice(names) + f" {i}",
                    random.choice(unit_types),
                    random.randint(20_000, 500_000),
                    random.choice(statuses),
                ]
            )

    # ---------- 17. PERSONAL_CLOSET ----------
    with open("PERSONAL_CLOSET.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["PCServiceID", "ClosetID", "StatusCloset"])
        for i in range(1, N_PERSONAL_CLOSET + 1):
            sid = pick(service_ids)
            w.writerow(
                [
                    sid,
                    i,
                    random.choice(["Trống", "Đang sử dụng", "Bảo trì"]),
                ]
            )

    # ---------- 18. RENTING_EQUIPMENT ----------
    with open("RENTING_EQUIPMENT.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["REServiceID", "EquipmentType", "Quantity"])
        eq_types = ["Vợt cầu lông", "Giày", "Bóng", "Vợt tennis", "Áo đấu"]
        for i in range(1, N_RENT_EQUIP + 1):
            sid = pick(service_ids)
            w.writerow(
                [
                    sid,
                    random.choice(eq_types),
                    random.randint(1, 20),
                ]
            )

    # ---------- 19. VIP_ROOM ----------
    with open("VIP_ROOM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["VRServiceID", "RoomID", "StatusRoom"])
        for i in range(1, N_VIP_ROOM + 1):
            sid = pick(service_ids)
            w.writerow(
                [
                    sid,
                    i,
                    random.choice(["Trống", "Đang sử dụng", "Đang dọn dẹp"]),
                ]
            )

    # ---------- 20. RENTING_HLV ----------
    with open("RENTING_HLV.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["RHServiceID", "Status", "Coach"])
        for i in range(1, N_RENT_HLV + 1):
            sid = pick(service_ids)
            w.writerow(
                [
                    sid,
                    random.choice(["Đang hoạt động", "Ngưng"]),
                    pick(coach_ids),
                ]
            )

    # ---------- 21. SERVICE_BOOKING ----------
    with open("SERVICE_BOOKING.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["SBID", "BookingID", "ServiceID", "BookingQuantity"])
        for i in range(1, N_SERVICE_BOOK + 1):
            sb_id = f"SBD{i:05d}"
            w.writerow(
                [
                    sb_id,
                    pick(booking_ids),
                    pick(service_ids),
                    random.randint(1, 5),
                ]
            )

    # ---------- 22. INVOICE ----------
    with open("INVOICE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "InvoiceID",
                "RentTime",
                "TotalPrice",
                "PaymentMethod",
                "CreateTime",
                "Status",
                "BookingID",
                "DiscountID",
                "CourtID",
                "CID",
            ]
        )
        pay_methods = ["Tiền mặt", "Chuyển khoản", "Thẻ", "Ví điện tử"]
        statuses = ["Chưa thanh toán", "Đã thanh toán", "Hủy"]
        for i in range(1, N_INVOICE + 1):
            inv_id = f"INV{i:05d}"
            rent_time = random_datetime(
                datetime(2024, 1, 1), datetime(2024, 12, 31)
            )
            total = random.randint(100_000, 3_000_000)
            disc = random.choice(discount_ids + [""])
            booking = pick(booking_ids)
            court = pick(court_ids)
            cid = pick(employee_ids)
            w.writerow(
                [
                    inv_id,
                    rent_time,
                    total,
                    random.choice(pay_methods),
                    rent_time,
                    random.choice(statuses),
                    booking,
                    disc,
                    court,
                    cid,
                ]
            )

    # ---------- 23. CANCELLATION_FORM ----------
    with open("CANCELLATION_FORM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "CancelFormID",
                "CancelTime",
                "PenaltyPrice",
                "Status",
                "CancelRuleID",
                "BookingID",
            ]
        )
        stt = ["Pending", "Approved", "Rejected"]
        for i in range(1, N_CANCEL_FORM + 1):
            cf_id = f"CNF{i:04d}"
            cancel_time = random_datetime(
                datetime(2024, 1, 1), datetime(2024, 12, 31)
            )
            penalty = random.randint(0, 500_000)
            w.writerow(
                [
                    cf_id,
                    cancel_time,
                    penalty,
                    random.choice(stt),
                    pick(cancel_rule_ids),
                    pick(booking_ids),
                ]
            )

    # ---------- 24. ACCOUNT_LOGIN (tổng hợp cuối cùng) ----------
    with open("ACCOUNT_LOGIN.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["AccountLogin", "Password"])
        for acc, pwd in sorted(accounts.items()):
            w.writerow([acc, pwd])

    print("ĐÃ TẠO XONG CÁC FILE CSV CHO DATABASE VIET_SPORT!")


if __name__ == "__main__":
    main()
