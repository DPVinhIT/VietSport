import csv
import random
from datetime import datetime, timedelta

from faker import Faker

fake = Faker("vi_VN")
random.seed(42)

# ================== DỮ LIỆU THỰC TẾ VIỆT NAM ==================
CITIES_DISTRICTS = {
    "TP. Hồ Chí Minh": [
        "Quận 1",
        "Quận 2",
        "Quận 3",
        "Quận 4",
        "Quận 5",
        "Quận 6",
        "Quận 7",
        "Quận 8",
        "Quận 9",
        "Quận 10",
        "Quận 11",
        "Quận 12",
        "Bình Thạnh",
        "Gò Vấp",
        "Tân Bình",
        "Tân Phú",
        "Phú Nhuận",
        "Bình Tân",
        "TP. Thủ Đức",
        "Nhà Bè",
        "Hóc Môn",
        "Củ Chi",
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
        "Tây Hồ",
        "Nam Từ Liêm",
        "Bắc Từ Liêm",
        "Hà Đông",
        "Thanh Trì",
        "Gia Lâm",
        "Đông Anh",
        "Sóc Sơn",
    ],
    "Đà Nẵng": [
        "Hải Châu",
        "Thanh Khê",
        "Sơn Trà",
        "Ngũ Hành Sơn",
        "Liên Chiểu",
        "Cẩm Lệ",
        "Hòa Vang",
    ],
    "Cần Thơ": ["Ninh Kiều", "Bình Thủy", "Cái Răng", "Ô Môn", "Thốt Nốt"],
    "Hải Phòng": [
        "Hồng Bàng",
        "Ngô Quyền",
        "Lê Chân",
        "Hải An",
        "Kiến An",
        "Đồ Sơn",
    ],
    "Biên Hòa": ["Tân Phong", "Trảng Dài", "Tân Hiệp", "Hóa An", "Long Bình"],
    "Nha Trang": [
        "Lộc Thọ",
        "Phước Tân",
        "Vĩnh Hải",
        "Vĩnh Phước",
        "Phước Long",
    ],
    "Huế": ["Phú Hội", "Vĩnh Ninh", "Phú Nhuận", "Xuân Phú", "Tây Lộc"],
    "Vũng Tàu": [
        "Phường 1",
        "Phường 2",
        "Phường 3",
        "Phường 4",
        "Phường 5",
        "Thắng Nhì",
        "Rạch Dừa",
    ],
    "Bình Dương": ["Thủ Dầu Một", "Dĩ An", "Thuận An", "Tân Uyên", "Bến Cát"],
}

# Tên trung tâm thể thao thực tế
SPORT_CENTER_NAMES = [
    "VietSport Arena",
    "Sài Gòn Sport Center",
    "Hà Nội Fitness Club",
    "Đà Nẵng Active",
    "Golden Sport Complex",
    "Star Sports Center",
    "Champion Arena",
    "Victory Stadium",
    "Elite Fitness Center",
    "Pro Sport Hub",
    "Sun Sport Arena",
    "Galaxy Fitness",
    "Royal Sport Club",
    "Diamond Sport Center",
    "Platinum Fitness",
    "Premier League Arena",
    "Super Sport Zone",
    "Top Fitness Center",
    "Ultimate Sport Club",
    "Power Gym Arena",
]

# Tên đường phổ biến Việt Nam
STREET_NAMES = [
    "Nguyễn Huệ",
    "Lê Lợi",
    "Trần Hưng Đạo",
    "Nguyễn Trãi",
    "Lý Thường Kiệt",
    "Đinh Tiên Hoàng",
    "Hai Bà Trưng",
    "Lê Duẩn",
    "Võ Văn Tần",
    "Nguyễn Đình Chiểu",
    "Cách Mạng Tháng 8",
    "Hoàng Văn Thụ",
    "Phan Đình Phùng",
    "Trường Chinh",
    "Nguyễn Văn Cừ",
    "Lê Văn Sỹ",
    "Điện Biên Phủ",
    "Nam Kỳ Khởi Nghĩa",
    "Pasteur",
    "Võ Thị Sáu",
    "Nguyễn Thị Minh Khai",
    "Bùi Viện",
    "Đề Thám",
    "Phạm Ngũ Lão",
    "Cống Quỳnh",
    "Nguyễn Công Trứ",
    "Lý Tự Trọng",
    "Tôn Đức Thắng",
    "Hàm Nghi",
    "Nguyễn Thái Học",
]

# Chuyên môn HLV chi tiết
COACH_SPECIALIZATIONS = [
    "Bóng đá",
    "Cầu lông đơn",
    "Cầu lông đôi",
    "Tennis đơn",
    "Tennis đôi",
    "Bóng rổ",
    "Bóng chuyền",
    "Gym & Fitness",
    "Yoga",
    "Pilates",
    "Boxing",
    "Muay Thai",
    "Kickboxing",
    "Bơi lội",
    "Aerobic",
    "Zumba",
    "CrossFit",
    "TRX Training",
    "Bóng bàn",
    "Pickleball",
]

# Lý do nghỉ phép chi tiết
LEAVE_REASONS = [
    "Nghỉ bệnh - Cảm cúm",
    "Nghỉ bệnh - Đau dạ dày",
    "Nghỉ bệnh - Sốt cao",
    "Việc gia đình khẩn cấp",
    "Chăm con ốm",
    "Đám cưới người thân",
    "Đám tang",
    "Nghỉ phép năm",
    "Nghỉ thai sản",
    "Đi khám bệnh định kỳ",
    "Làm giấy tờ cá nhân",
    "Chuyển nhà",
    "Thi cử/Học tập",
    "Tai nạn giao thông nhẹ",
    "Hẹn gặp luật sư",
    "Bận việc cá nhân đột xuất",
]

# Tên khuyến mãi thực tế
DISCOUNT_NAMES = [
    "Khai trương - Giảm sốc",
    "Flash Sale cuối tuần",
    "Happy Hour 14h-17h",
    "Sinh nhật VietSport",
    "Ưu đãi thành viên mới",
    "Combo gia đình",
    "Khuyến mãi mùa hè",
    "Sale Tết Nguyên Đán",
    "Giảm giá Black Friday",
    "Ưu đãi 8/3",
    "Sale 11/11",
    "Christmas Special",
    "Năm mới - Deal mới",
    "Đặt sớm giảm 20%",
    "Giảm giá nhóm 4+",
    "Ưu đãi sinh viên",
    "Deal cuối năm",
    "Tri ân khách hàng",
    "Tháng vàng khuyến mãi",
    "Siêu sale mùa thu",
    "Ưu đãi Valentine",
    "Deal hot tháng 6",
    "Giảm giá mùa World Cup",
    "Khuyến mãi SEA Games",
    "Ưu đãi hè rực rỡ",
]

# Tên dịch vụ chi tiết
SERVICE_NAMES = [
    "Tủ đồ cá nhân loại nhỏ",
    "Tủ đồ cá nhân loại lớn",
    "Tủ đồ VIP có khóa điện tử",
    "Thuê vợt cầu lông Yonex",
    "Thuê vợt cầu lông Victor",
    "Thuê vợt tennis Wilson",
    "Thuê vợt tennis Head",
    "Thuê bóng đá size 4",
    "Thuê bóng đá size 5",
    "Thuê bóng rổ Spalding",
    "Thuê giày thể thao",
    "Thuê áo đấu có số",
    "Phòng VIP có điều hòa",
    "Phòng VIP có màn hình LED",
    "Phòng họp đội",
    "Thuê HLV cá nhân - Basic",
    "Thuê HLV cá nhân - Pro",
    "Thuê HLV nhóm",
    "Nước suối Aquafina",
    "Nước tăng lực Redbull",
    "Nước điện giải Pocari",
    "Khăn tắm cotton",
    "Khăn mặt",
    "Dầu gội sữa tắm combo",
    "Massage thư giãn 30 phút",
    "Massage thể thao 60 phút",
    "Xông hơi khô",
    "Xông hơi ướt",
    "Bể sục jacuzzi",
    "Phòng tắm VIP",
    "Đỗ xe ô tô",
    "Đỗ xe máy VIP",
    "Gửi đồ qua đêm",
    "Dịch vụ giặt đồ",
    "Cho thuê đồng phục thi đấu",
    "Livestream trận đấu",
]

# Thiết bị cho thuê chi tiết
EQUIPMENT_TYPES = [
    "Vợt cầu lông Yonex Astrox",
    "Vợt cầu lông Victor Thruster",
    "Vợt cầu lông Li-Ning",
    "Vợt tennis Wilson Pro Staff",
    "Vợt tennis Head Speed",
    "Vợt tennis Babolat Pure",
    "Bóng đá Adidas Tango",
    "Bóng đá Nike Flight",
    "Bóng đá Molten",
    "Bóng rổ Spalding NBA",
    "Bóng rổ Molten",
    "Bóng chuyền Mikasa",
    "Giày cầu lông Yonex",
    "Giày tennis Nike Court",
    "Giày bóng đá Nike Mercurial",
    "Áo đấu có số 1-20",
    "Quần short thể thao",
    "Băng đô thể thao",
    "Bảo vệ đầu gối",
    "Bảo vệ cổ chân",
    "Găng tay thủ môn",
    "Còi trọng tài",
    "Thẻ vàng thẻ đỏ",
    "Lưới cầu lông dự phòng",
]

# Quy định hủy chi tiết
CANCEL_RULE_NAMES = [
    "Hủy trước 24h - Miễn phí",
    "Hủy trước 12h - Phí 20%",
    "Hủy trước 6h - Phí 50%",
    "Hủy trước 2h - Phí 80%",
    "Hủy sát giờ - Phí 100%",
    "Hủy do thời tiết - Miễn phí",
    "Hủy do sự cố kỹ thuật - Hoàn 100%",
    "Hủy booking nhóm trước 48h",
    "Hủy gói tháng - Theo điều khoản",
    "Hủy HLV trước 4h",
    "Hủy phòng VIP trước 3h",
    "Chính sách đổi lịch miễn phí",
    "Chính sách hoàn tiền khẩn cấp",
    "Quy định hủy giờ cao điểm",
    "Quy định hủy cuối tuần",
    "Hủy do sức khỏe có chứng từ",
]

# Họ và tên Việt Nam thực tế
VIETNAMESE_FIRST_NAMES_MALE = [
    "Anh",
    "Bình",
    "Cường",
    "Dũng",
    "Đức",
    "Hải",
    "Hoàng",
    "Hùng",
    "Khoa",
    "Kiên",
    "Long",
    "Minh",
    "Nam",
    "Phong",
    "Quang",
    "Sơn",
    "Thành",
    "Trung",
    "Tuấn",
    "Việt",
    "An",
    "Bảo",
    "Công",
    "Đạt",
    "Hiếu",
    "Huy",
    "Khang",
    "Lâm",
    "Nghĩa",
    "Phúc",
    "Quân",
    "Tài",
    "Thắng",
    "Trọng",
    "Tùng",
    "Vũ",
    "Xuân",
    "Duy",
    "Khánh",
    "Nhật",
]

VIETNAMESE_FIRST_NAMES_FEMALE = [
    "Anh",
    "Bích",
    "Chi",
    "Diệu",
    "Dung",
    "Hà",
    "Hạnh",
    "Hiền",
    "Hoa",
    "Hương",
    "Lan",
    "Linh",
    "Mai",
    "My",
    "Nga",
    "Ngọc",
    "Nhung",
    "Phương",
    "Quỳnh",
    "Thanh",
    "Thảo",
    "Thủy",
    "Trang",
    "Trinh",
    "Vân",
    "Yến",
    "Ánh",
    "Đào",
    "Giang",
    "Hằng",
    "Huệ",
    "Kim",
    "Loan",
    "Ly",
    "Nhi",
    "Oanh",
    "Phượng",
    "Thu",
    "Thư",
    "Uyên",
]

VIETNAMESE_LAST_NAMES = [
    "Nguyễn",
    "Trần",
    "Lê",
    "Phạm",
    "Hoàng",
    "Huỳnh",
    "Phan",
    "Vũ",
    "Võ",
    "Đặng",
    "Bùi",
    "Đỗ",
    "Hồ",
    "Ngô",
    "Dương",
    "Lý",
    "Đinh",
    "Trương",
    "Lương",
    "Mai",
]

VIETNAMESE_MIDDLE_NAMES = [
    "Văn",
    "Thị",
    "Hữu",
    "Đức",
    "Minh",
    "Hoàng",
    "Ngọc",
    "Quốc",
    "Thanh",
    "Xuân",
    "Kim",
    "Bích",
    "Hồng",
    "Phương",
    "Thành",
    "Đình",
    "Công",
    "Quang",
    "Anh",
    "Trọng",
]


def gen_vietnamese_name(gender="random"):
    """Tạo tên Việt Nam thực tế"""
    if gender == "random":
        gender = random.choice(["Nam", "Nữ"])

    last_name = random.choice(VIETNAMESE_LAST_NAMES)

    if gender == "Nam":
        middle = random.choice(
            [
                "Văn",
                "Hữu",
                "Đức",
                "Minh",
                "Quốc",
                "Thành",
                "Đình",
                "Công",
                "Quang",
                "Trọng",
            ]
        )
        first = random.choice(VIETNAMESE_FIRST_NAMES_MALE)
    else:
        middle = random.choice(
            [
                "Thị",
                "Ngọc",
                "Bích",
                "Hồng",
                "Phương",
                "Kim",
                "Thanh",
                "Xuân",
                "Hoàng",
                "Anh",
            ]
        )
        first = random.choice(VIETNAMESE_FIRST_NAMES_FEMALE)

    return f"{last_name} {middle} {first}", gender


def gen_realistic_address():
    """Tạo địa chỉ thực tế Việt Nam"""
    city = random.choice(list(CITIES_DISTRICTS.keys()))
    district = random.choice(CITIES_DISTRICTS[city])
    street_name = random.choice(STREET_NAMES)
    house_number = random.randint(1, 500)
    return house_number, street_name, district, city


# ================== SỐ LƯỢNG BẢN GHI (<= 1500) ==================
N_CENTER = 10
N_EMPLOYEE = 150
N_SYSTEM_PARAM = 25
N_SCHEDULE = 600
N_ATTENDANCE = 1400
N_LEAVEFORM = 250
N_CUSTOMER = 1000
N_COACH = 80
N_BOOKING = 1400
N_MEMBER_CARD = 600
N_CANCEL_RULE = 16
N_DISCOUNT = 60
N_PAYROLL = 700
N_COURT_TYPE = 8
N_SPORT_COURT = 100
N_INVOICE = 1300
N_CANCEL_FORM = 250
N_SERVICE = 100
N_SERVICE_BOOK = 1200
N_PERSONAL_CLOSET = 100
N_RENT_EQUIP = 120
N_VIP_ROOM = 50
N_RENT_HLV = 100

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
    """Tạo số điện thoại Việt Nam thực tế"""
    # Đầu số các nhà mạng Việt Nam
    prefixes = [
        "032",
        "033",
        "034",
        "035",
        "036",
        "037",
        "038",
        "039",  # Viettel
        "070",
        "076",
        "077",
        "078",
        "079",  # Mobifone
        "081",
        "082",
        "083",
        "084",
        "085",  # Vinaphone
        "056",
        "058",  # Vietnamobile
        "059",  # Gmobile
        "090",
        "091",
        "092",
        "093",
        "094",
        "096",
        "097",
        "098",  # Đầu số cũ
    ]
    prefix = random.choice(prefixes)
    number = "".join(str(random.randint(0, 9)) for _ in range(7))
    return prefix + number


def gen_email(name):
    """Tạo email từ tên"""
    # Chuyển tên thành email format
    import unicodedata

    name_normalized = unicodedata.normalize("NFD", name)
    name_ascii = name_normalized.encode("ascii", "ignore").decode("ascii")
    name_parts = name_ascii.lower().split()
    if len(name_parts) >= 2:
        email_base = f"{name_parts[-1]}.{name_parts[0]}"
    else:
        email_base = name_parts[0] if name_parts else "user"

    domains = [
        "gmail.com",
        "yahoo.com",
        "hotmail.com",
        "outlook.com",
        "email.com",
        "icloud.com",
        "protonmail.com",
    ]
    suffix = random.randint(1, 999)
    return f"{email_base}{suffix}@{random.choice(domains)}"


def gen_cccd():
    """Tạo số CCCD 12 số thực tế"""
    # 3 số đầu: mã tỉnh (001-096)
    province_codes = [
        "001",
        "002",
        "004",
        "006",
        "008",
        "010",
        "011",
        "012",
        "014",
        "015",
        "017",
        "019",
        "020",
        "022",
        "024",
        "025",
        "026",
        "027",
        "030",
        "031",
        "033",
        "034",
        "035",
        "036",
        "037",
        "038",
        "040",
        "042",
        "044",
        "045",
        "046",
        "048",
        "049",
        "051",
        "052",
        "054",
        "056",
        "058",
        "060",
        "062",
        "064",
        "066",
        "067",
        "068",
        "070",
        "072",
        "074",
        "075",
        "077",
        "079",
        "080",
        "082",
        "083",
        "084",
        "086",
        "087",
        "089",
        "091",
        "092",
        "093",
        "094",
        "095",
        "096",
    ]
    province = random.choice(province_codes)
    # 1 số: giới tính và thế kỷ sinh (0-9)
    gender_century = str(random.randint(0, 9))
    # 2 số: năm sinh
    year = (
        f"{random.randint(70, 99):02d}"
        if random.random() < 0.3
        else f"{random.randint(0, 5):02d}"
    )
    # 6 số cuối: số ngẫu nhiên
    random_part = f"{random.randint(0, 999999):06d}"
    return f"{province}{gender_century}{year}{random_part}"


# ================== MAIN ==================


def main():
    # Tập hợp tất cả account login đã dùng (account -> password)
    accounts = {}

    # ---------- 1. SPORT_CENTER ----------
    center_ids = []
    center_cities = {}  # Lưu city của từng center để dùng sau
    with open("SPORT_CENTER.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CenterID", "Address", "Hotline", "OpenTime", "CloseTime", "Owner"]
        )
        used_names = set()
        for i in range(1, N_CENTER + 1):
            cid = f"CEN{i:03d}"
            center_ids.append(cid)

            # Tên trung tâm không trùng
            center_name = random.choice(SPORT_CENTER_NAMES)
            while center_name in used_names:
                center_name = random.choice(SPORT_CENTER_NAMES)
            used_names.add(center_name)

            # Địa chỉ thực tế
            house_num, street, district, city = gen_realistic_address()
            center_cities[cid] = city
            full_address = f"{house_num} - {street} - {district} - {city}"

            # Giờ mở cửa thực tế cho trung tâm thể thao
            open_times = ["05:00:00", "05:30:00", "06:00:00", "06:30:00"]
            close_times = [
                "21:00:00",
                "21:30:00",
                "22:00:00",
                "22:30:00",
                "23:00:00",
            ]

            owner_name, _ = gen_vietnamese_name()

            w.writerow(
                [
                    cid,
                    full_address,
                    gen_phone(),
                    random.choice(open_times),
                    random.choice(close_times),
                    owner_name,
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

    # Định nghĩa lương theo vai trò (thực tế VN)
    SALARY_RANGES = {
        "Quản lý": (15_000_000, 35_000_000),
        "Lễ tân": (6_000_000, 12_000_000),
        "Kỹ thuật viên": (8_000_000, 15_000_000),
        "Thu ngân": (6_000_000, 10_000_000),
        "Admin": (10_000_000, 20_000_000),
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

        # BƯỚC 1: Tạo đúng 1 quản lý cho mỗi trung tâm
        managers_by_center = {}
        manager_pool = []
        emp_idx = 0

        for center_id in center_ids:
            emp_id = employee_ids[emp_idx]
            emp_idx += 1

            # Tạo quản lý cho trung tâm này
            current_year = 2024
            age = random.randint(30, 55)  # Quản lý thường tuổi cao hơn
            birth_year = current_year - age
            birthday = random_date(
                datetime(birth_year, 1, 1), datetime(birth_year, 12, 31)
            ).date()

            full_name, gender = gen_vietnamese_name()

            # Vai trò = Quản lý
            role = "Quản lý"
            is_mgr = 1
            is_rec = 0
            is_tech = 0
            is_cash = 0
            is_admin = 0

            # Lương quản lý
            salary_min, salary_max = SALARY_RANGES[role]
            experience_bonus = min((age - 18) * 200_000, 5_000_000)
            basic_salary = (
                random.randint(salary_min, salary_max) + experience_bonus
            )

            # Địa chỉ
            house_num, street, district, city = gen_realistic_address()
            street_full = f"{house_num} {street}"

            # Account login
            prefix = "MN"
            counter = role_prefix_counters[prefix]
            role_prefix_counters[prefix] += 1
            acc_login = f"{prefix}{counter:04d}"
            password = f"{acc_login}@123"
            accounts[acc_login] = password

            # Quản lý không có manager (manager_id = "")
            manager_id = ""

            managers_by_center[center_id] = emp_id
            manager_pool.append(emp_id)

            w.writerow(
                [
                    emp_id,
                    full_name,
                    birthday,
                    gender,
                    gen_cccd(),
                    street_full,
                    district,
                    city,
                    gen_phone(),
                    basic_salary,
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

        # BƯỚC 2: Tạo nhân viên còn lại (tất cả phải có manager)
        for emp_id in employee_ids[emp_idx:]:
            # Sinh ngày sinh thực tế (18-55 tuổi)
            current_year = 2024
            age = random.randint(18, 55)
            birth_year = current_year - age
            birthday = random_date(
                datetime(birth_year, 1, 1), datetime(birth_year, 12, 31)
            ).date()

            # Tên và giới tính
            full_name, gender = gen_vietnamese_name()

            # Vai trò (không phải quản lý)
            role_weights = [
                ("Lễ tân", 30),
                ("Kỹ thuật viên", 25),
                ("Thu ngân", 25),
                ("Admin", 20),
            ]
            roles = [r[0] for r in role_weights]
            weights = [r[1] for r in role_weights]
            role = random.choices(roles, weights=weights, k=1)[0]

            is_mgr = 0
            is_rec = 1 if role == "Lễ tân" else 0
            is_tech = 1 if role == "Kỹ thuật viên" else 0
            is_cash = 1 if role == "Thu ngân" else 0
            is_admin = 1 if role == "Admin" else 0

            # Chọn trung tâm
            center_id = pick(center_ids)

            # Gán manager: ưu tiên quản lý cùng center
            manager_id = managers_by_center[center_id]

            # Địa chỉ thực tế
            house_num, street, district, city = gen_realistic_address()
            street_full = f"{house_num} {street}"

            # Lương theo vai trò
            salary_min, salary_max = SALARY_RANGES[role]
            experience_bonus = min((age - 18) * 200_000, 5_000_000)
            basic_salary = (
                random.randint(salary_min, salary_max) + experience_bonus
            )

            # Account login theo role
            if role == "Lễ tân":
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
                    full_name,
                    birthday,
                    gender,
                    gen_cccd(),
                    street_full,
                    district,
                    city,
                    gen_phone(),
                    basic_salary,
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
        # Giá theo giờ cao điểm/thấp điểm
        price_configs = [
            80_000,
            100_000,
            120_000,
            150_000,
            180_000,
            200_000,
            250_000,
            300_000,
            350_000,
            400_000,
        ]
        min_booking_times = [30, 45, 60]  # phút
        max_booking_times = [120, 180, 240, 300]  # phút

        for i in range(1, N_SYSTEM_PARAM + 1):
            setup = random_datetime(
                datetime(2022, 1, 1), datetime(2024, 12, 31)
            )
            sys_id = f"SPM{i:03d}"
            aid = pick(employee_ids)
            w.writerow(
                [
                    sys_id,
                    setup.date(),
                    setup.time().strftime("%H:%M:%S"),
                    random.choice(price_configs),
                    random.choice(min_booking_times),
                    random.choice(max_booking_times),
                    random.randint(1, 5),
                    aid,
                ]
            )

    # ---------- 4. EMPLOYEE_SCHEDULE ----------
    schedule_ids = []
    schedule_data = {}  # Lưu thông tin schedule để dùng cho attendance
    with open("EMPLOYEE_SCHEDULE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["ScheduleID", "StartTime", "EndTime"])

        # Ca làm việc thực tế
        shift_patterns = [
            (6, 12),  # Ca sáng
            (12, 18),  # Ca chiều
            (18, 23),  # Ca tối
            (6, 14),  # Ca sáng dài
            (14, 22),  # Ca chiều-tối
            (8, 17),  # Ca hành chính
        ]

        for i in range(1, N_SCHEDULE + 1):
            sch_id = f"SCH{i:04d}"
            # Random ngày trong năm 2024
            work_date = random_date(
                datetime(2024, 1, 1), datetime(2024, 12, 31)
            )
            shift = random.choice(shift_patterns)
            start = datetime.combine(
                work_date,
                datetime.min.time().replace(
                    hour=shift[0], minute=random.choice([0, 30])
                ),
            )
            end = datetime.combine(
                work_date,
                datetime.min.time().replace(
                    hour=shift[1], minute=random.choice([0, 30])
                ),
            )
            schedule_ids.append(sch_id)
            schedule_data[sch_id] = (start, end)
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
            sch_start, sch_end = schedule_data[sch]

            # Trạng thái với logic thực tế
            status_roll = random.random()
            if status_roll < 0.75:
                status = "Đúng giờ"
                # Check in sớm 0-10 phút hoặc đúng giờ
                check_in = sch_start + timedelta(minutes=random.randint(-10, 5))
            elif status_roll < 0.92:
                status = "Trễ"
                # Check in trễ 5-60 phút
                check_in = sch_start + timedelta(minutes=random.randint(5, 60))
            else:
                status = "Vắng"
                check_in = sch_start  # Ghi nhận nhưng vắng

            # Check out dựa trên schedule
            if status != "Vắng":
                # Check out có thể sớm 0-15 phút hoặc trễ 0-30 phút
                check_out = sch_end + timedelta(minutes=random.randint(-15, 30))
            else:
                check_out = sch_start  # Không có check out thực tế

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
        for i in range(1, N_LEAVEFORM + 1):
            lf_id = f"LFM{i:04d}"
            emp = pick(employee_ids)
            sch = pick(schedule_ids)
            dt = random_datetime(datetime(2024, 1, 1), datetime(2024, 12, 31))

            # Trạng thái với phân bố thực tế
            status_roll = random.random()
            if status_roll < 0.6:
                status = "Approved"
            elif status_roll < 0.85:
                status = "Pending"
            else:
                status = "Rejected"

            w.writerow(
                [lf_id, emp, sch, dt, random.choice(LEAVE_REASONS), status]
            )

    # ---------- 7. CUSTOMER ----------
    customer_ids = []
    customer_data = {}  # Lưu thông tin customer để sử dụng sau
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
        used_usernames = set()

        for i in range(1, N_CUSTOMER + 1):
            cid = f"CUS{i:05d}"
            customer_ids.append(cid)

            # Khách hàng từ 15-70 tuổi
            age = random.randint(15, 70)
            birth_year = 2024 - age
            birthday = random_date(
                datetime(birth_year, 1, 1), datetime(birth_year, 12, 31)
            ).date()

            full_name, gender = gen_vietnamese_name()
            customer_data[cid] = {"name": full_name, "age": age}

            # Logic đăng ký online/trực tiếp thực tế
            # Khách trẻ có xu hướng đăng ký online nhiều hơn
            if age < 35:
                is_online = 1 if random.random() < 0.6 else 0
            else:
                is_online = 1 if random.random() < 0.25 else 0

            is_direct = 1 if random.random() < 0.7 else 0
            # Đảm bảo ít nhất 1 loại
            if is_online == 0 and is_direct == 0:
                is_direct = 1

            acc_login = ""

            def generate_unique_username(name):
                import unicodedata

                name_norm = unicodedata.normalize("NFD", name)
                name_ascii = name_norm.encode("ascii", "ignore").decode("ascii")
                parts = name_ascii.lower().split()
                if len(parts) >= 2:
                    base = f"{parts[-1]}{parts[0][0]}"
                else:
                    base = parts[0] if parts else "user"

                username = base
                suffix = random.randint(1, 999)
                while username in used_usernames or username in accounts:
                    username = f"{base}{suffix}"
                    suffix += 1
                return username

            if is_online == 1:
                login = generate_unique_username(full_name)
                used_usernames.add(login)
                password = fake.password(length=12)
                accounts[login] = password
                acc_login = login
            elif is_direct == 1 and random.random() < 0.3:
                # Một số khách trực tiếp cũng có tài khoản
                login = generate_unique_username(full_name)
                used_usernames.add(login)
                password = fake.password(length=12)
                accounts[login] = password
                acc_login = login

            # Địa chỉ thực tế
            house_num, street, district, city = gen_realistic_address()
            full_address = f"{house_num} - {street} - {district} - {city}"

            w.writerow(
                [
                    cid,
                    full_name,
                    birthday,
                    gen_phone(),
                    gen_email(full_name),
                    full_address,
                    is_online,
                    is_direct,
                    acc_login,
                ]
            )

    # ---------- 8. COACH ----------
    coach_ids = []
    coach_data = {}  # Lưu thông tin HLV
    with open("COACH.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CoachID", "FullName", "Specialization", "ScheduleWork", "Price"]
        )

        # Giá HLV theo chuyên môn
        COACH_PRICES = {
            "Bóng đá": (300_000, 600_000),
            "Cầu lông đơn": (200_000, 400_000),
            "Cầu lông đôi": (250_000, 450_000),
            "Tennis đơn": (350_000, 700_000),
            "Tennis đôi": (400_000, 750_000),
            "Bóng rổ": (300_000, 550_000),
            "Bóng chuyền": (250_000, 500_000),
            "Gym & Fitness": (200_000, 500_000),
            "Yoga": (250_000, 550_000),
            "Pilates": (300_000, 600_000),
            "Boxing": (350_000, 700_000),
            "Muay Thai": (400_000, 800_000),
            "Kickboxing": (350_000, 700_000),
            "Bơi lội": (300_000, 600_000),
            "Aerobic": (200_000, 400_000),
            "Zumba": (200_000, 400_000),
            "CrossFit": (350_000, 650_000),
            "TRX Training": (300_000, 550_000),
            "Bóng bàn": (200_000, 400_000),
            "Pickleball": (250_000, 500_000),
        }

        schedule_options = [
            "Sáng (6h-12h)",
            "Chiều (12h-18h)",
            "Tối (18h-22h)",
            "Sáng + Chiều",
            "Chiều + Tối",
            "Cả ngày",
            "Thứ 2,4,6",
            "Thứ 3,5,7",
            "Cuối tuần",
        ]

        for i in range(1, N_COACH + 1):
            co_id = f"COA{i:03d}"
            coach_ids.append(co_id)

            full_name, gender = gen_vietnamese_name()
            spec = random.choice(COACH_SPECIALIZATIONS)
            sched = random.choice(schedule_options)

            price_min, price_max = COACH_PRICES.get(spec, (200_000, 500_000))
            price = random.randint(price_min, price_max)
            # Làm tròn giá
            price = round(price / 10_000) * 10_000

            coach_data[co_id] = {
                "name": full_name,
                "spec": spec,
                "price": price,
            }

            w.writerow([co_id, full_name, spec, sched, price])

    # ---------- 9. COURT_TYPE ----------
    # Theo đặc tả: cầu lông/bóng rổ theo giờ, tennis theo ca 2h, bóng đá mini theo trận 90p
    court_types = []
    court_type_data = {}
    with open("COURT_TYPE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["CourtType", "CourtTypeName", "TypeofRental"])
        # (ID, Tên loại sân, Cách tính thuê)
        type_data = [
            ("CTP01", "Sân bóng đá mini", "Theo trận (90 phút)"),
            ("CTP02", "Sân cầu lông", "Theo giờ"),
            ("CTP03", "Sân tennis", "Theo ca (2 giờ)"),
            ("CTP04", "Sân bóng rổ", "Theo giờ"),
            ("CTP05", "Sân futsal", "Theo trận (90 phút)"),
        ]
        for ct_id, name, rental_type in type_data:
            court_types.append(ct_id)
            court_type_data[ct_id] = {"name": name, "rental": rental_type}
            w.writerow([ct_id, name, rental_type])

    # ---------- 10. SPORT_COURT ----------
    court_ids = []
    court_data = {}
    with open("SPORT_COURT.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["CourtID", "CourtType", "Capacity", "UnitPrice", "CenterID"]
        )

        # Giá sân theo loại (VNĐ theo đơn vị thuê tương ứng)
        COURT_PRICES = {
            "CTP01": (200_000, 400_000),  # Bóng đá mini - /trận
            "CTP02": (60_000, 120_000),  # Cầu lông - /giờ
            "CTP03": (150_000, 350_000),  # Tennis - /ca 2h
            "CTP04": (200_000, 400_000),  # Bóng rổ - /giờ
            "CTP05": (250_000, 500_000),  # Futsal - /trận
        }

        # Sức chứa theo loại sân
        COURT_CAPACITIES = {
            "CTP01": [10, 12, 14],  # Bóng đá mini: 10-14 người
            "CTP02": [2, 4],  # Cầu lông: 2-4 người
            "CTP03": [2, 4],  # Tennis: 2-4 người
            "CTP04": [10, 12],  # Bóng rổ: 10-12 người
            "CTP05": [10, 12],  # Futsal: 10-12 người
        }

        # Số lượng sân mỗi loại cho mỗi center
        COURTS_PER_TYPE = {
            "CTP01": 2,  # 2 sân bóng đá mini
            "CTP02": 4,  # 4 sân cầu lông
            "CTP03": 2,  # 2 sân tennis
            "CTP04": 1,  # 1 sân bóng rổ
            "CTP05": 2,  # 2 sân futsal
        }

        court_counter = 1
        # Mỗi center có đủ các loại sân
        for center_id in center_ids:
            for ctype in court_types:
                num_courts = COURTS_PER_TYPE.get(ctype, 1)
                for _ in range(num_courts):
                    crt_id = f"CRT{court_counter:04d}"
                    court_counter += 1

                    cap = random.choice(COURT_CAPACITIES.get(ctype, [4, 6]))
                    price_min, price_max = COURT_PRICES.get(
                        ctype, (100_000, 300_000)
                    )
                    price = random.randint(price_min, price_max)
                    price = round(price / 10_000) * 10_000  # Làm tròn

                    court_ids.append(crt_id)
                    court_data[crt_id] = {
                        "type": ctype,
                        "price": price,
                        "center": center_id,
                    }
                    w.writerow([crt_id, ctype, cap, price, center_id])

    # ---------- 11. BOOKING_FORM ----------
    booking_ids = []
    booking_data = {}
    with open("BOOKING_FORM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "BookingID",
                "CourtID",
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

        # Khung giờ phổ biến để đặt sân
        peak_hours = [17, 18, 19, 20]  # Giờ cao điểm
        normal_hours = [6, 7, 8, 9, 10, 11, 14, 15, 16, 21, 22]

        for i in range(1, N_BOOKING + 1):
            bkid = f"BKG{i:05d}"
            booking_ids.append(bkid)

            # Chọn court từ SPORT_COURT (FK đến CourtID)
            court = pick(court_ids)
            court_info = court_data.get(court, {})
            center = court_info.get("center", pick(center_ids))

            # Ngày đặt (trong năm 2024)
            order_dt = random_datetime(
                datetime(2024, 1, 1), datetime(2024, 12, 31)
            )

            # Thời gian chơi (thường đặt trước 1-7 ngày)
            days_ahead = random.choices(
                [0, 1, 2, 3, 4, 5, 6, 7],
                weights=[5, 25, 25, 15, 10, 8, 7, 5],
                k=1,
            )[0]

            # Chọn giờ (70% giờ cao điểm vào buổi tối/cuối tuần)
            if random.random() < 0.7:
                start_hour = random.choice(peak_hours)
            else:
                start_hour = random.choice(normal_hours)

            start = datetime.combine(
                order_dt.date() + timedelta(days=days_ahead),
                datetime.min.time().replace(hour=start_hour, minute=0),
            )

            # Thời lượng đặt (1-3 giờ, phổ biến là 1-2 giờ)
            duration = random.choices([1, 2, 3], weights=[40, 45, 15], k=1)[0]
            end = start + timedelta(hours=duration)

            # Trạng thái với phân bố thực tế
            status_roll = random.random()
            if status_roll < 0.7:
                status = "Confirmed"
            elif status_roll < 0.9:
                status = "Pending"
            else:
                status = "Cancelled"

            customer = pick(customer_ids)
            receptionist = pick(employee_ids)

            booking_data[bkid] = {
                "customer": customer,
                "center": center,
                "court": court,
                "status": status,
                "start": start,
                "end": end,
                "duration": duration,
            }

            w.writerow(
                [
                    bkid,
                    court,
                    order_dt.date(),
                    order_dt.time().strftime("%H:%M:%S"),
                    start,
                    end,
                    status,
                    customer,
                    center,
                    receptionist,
                ]
            )

    # ---------- 12. MEMBER_CARD ----------
    member_card_data = {}
    with open("MEMBER_CARD.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["CardID", "MembershipLevel", "CustomerID"])

        # Phân bố cấp độ thành viên thực tế
        levels = ["Silver", "Gold", "Platinum", "Diamond"]
        level_weights = [50, 30, 15, 5]  # Silver nhiều nhất, Diamond ít nhất

        # Đảm bảo mỗi customer chỉ có 1 thẻ
        available_customers = customer_ids.copy()
        random.shuffle(available_customers)

        for i in range(1, min(N_MEMBER_CARD + 1, len(available_customers) + 1)):
            card_id = f"MBC{i:05d}"
            customer = available_customers[i - 1]
            level = random.choices(levels, weights=level_weights, k=1)[0]
            member_card_data[card_id] = {"customer": customer, "level": level}
            w.writerow([card_id, level, customer])

    # ---------- 13. CANCEL_RULE ----------
    cancel_rule_ids = []
    with open("CANCEL_RULE.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "CancelRuleID",
                "RuleName",
                "MinimumTime",
                "TimeUnit",
                "PenaltyFee",
                "MID",
            ]
        )

        # Quy định hủy thực tế với thời gian và phí cụ thể
        cancel_rules_detail = [
            ("Hủy trước 24h - Miễn phí", 24, "Giờ", 0),
            ("Hủy trước 12h - Phí 20%", 12, "Giờ", 50_000),
            ("Hủy trước 6h - Phí 50%", 6, "Giờ", 100_000),
            ("Hủy trước 2h - Phí 80%", 2, "Giờ", 150_000),
            ("Hủy sát giờ - Phí 100%", 1, "Giờ", 200_000),
            ("Hủy do thời tiết - Miễn phí", 0, "Giờ", 0),
            ("Hủy do sự cố kỹ thuật - Hoàn 100%", 0, "Giờ", 0),
            ("Hủy booking nhóm trước 48h", 48, "Giờ", 100_000),
            ("Hủy gói tháng - Theo điều khoản", 7, "Ngày", 500_000),
            ("Hủy HLV trước 4h", 4, "Giờ", 100_000),
            ("Hủy phòng VIP trước 3h", 3, "Giờ", 150_000),
            ("Chính sách đổi lịch miễn phí", 6, "Giờ", 0),
            ("Chính sách hoàn tiền khẩn cấp", 0, "Giờ", 50_000),
            ("Quy định hủy giờ cao điểm", 12, "Giờ", 200_000),
            ("Quy định hủy cuối tuần", 24, "Giờ", 150_000),
            ("Hủy do sức khỏe có chứng từ", 0, "Giờ", 0),
        ]

        for i, (name, min_time, unit, fee) in enumerate(
            cancel_rules_detail[:N_CANCEL_RULE], 1
        ):
            crid = f"CRL{i:03d}"
            cancel_rule_ids.append(crid)
            w.writerow([crid, name, min_time, unit, fee, pick(employee_ids)])

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
                "Percentage",
                "TargetUser",
                "MID",
            ]
        )
        targets = [
            "Tất cả khách hàng",
            "Thành viên Silver",
            "Thành viên Gold",
            "Thành viên Platinum",
            "Thành viên Diamond",
            "Khách hàng mới",
            "Đặt online",
            "Sinh viên",
            "Nhóm 4+ người",
        ]

        # Phần trăm giảm thực tế
        discount_percentages = [5, 10, 15, 20, 25, 30, 40, 50]

        for i in range(1, N_DISCOUNT + 1):
            did = f"DSC{i:03d}"
            discount_ids.append(did)

            # Chọn tên khuyến mãi
            if i <= len(DISCOUNT_NAMES):
                name = DISCOUNT_NAMES[i - 1]
            else:
                name = f"Khuyến mãi đặc biệt {i}"

            # Thời gian khuyến mãi
            start = random_date(
                datetime(2023, 1, 1), datetime(2024, 10, 31)
            ).date()

            # Thời gian khuyến mãi 3-60 ngày
            duration = random.choices(
                [3, 7, 14, 30, 45, 60], weights=[10, 30, 25, 20, 10, 5], k=1
            )[0]
            end = start + timedelta(days=duration)

            # Phần trăm giảm (ưu tiên mức nhỏ hơn)
            percentage = random.choices(
                discount_percentages, weights=[25, 30, 20, 15, 5, 3, 1, 1], k=1
            )[0]

            w.writerow(
                [
                    did,
                    name,
                    start,
                    end,
                    percentage,
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

        # Các loại phụ cấp thực tế
        ALLOWANCE_TYPES = {
            "Xăng xe": (300_000, 800_000),
            "Ăn trưa": (500_000, 1_000_000),
            "Điện thoại": (200_000, 500_000),
            "Chuyên cần": (500_000, 1_500_000),
        }

        for i in range(1, N_PAYROLL + 1):
            pr_id = f"PRL{i:05d}"
            month = random.randint(1, 12)
            year = random.choice([2023, 2024])

            emp = pick(employee_ids)

            # Lương cơ bản dựa trên nhân viên (giả định)
            base = random.randint(6_000_000, 25_000_000)

            # Phụ cấp tổng hợp
            allow = sum(
                random.randint(v[0], v[1]) if random.random() < 0.7 else 0
                for v in ALLOWANCE_TYPES.values()
            )

            # Ca làm thêm (0-20 ca, mỗi ca 100k-200k)
            extra_shifts = random.randint(0, 20)
            shift = extra_shifts * random.randint(100_000, 200_000)

            # Hoa hồng bán hàng (cho lễ tân, quản lý)
            sale = random.randint(0, 3_000_000) if random.random() < 0.3 else 0

            # Phạt (đi trễ, vi phạm)
            penalty = 0
            if random.random() < 0.15:  # 15% có bị phạt
                penalty = random.choice([50_000, 100_000, 200_000, 500_000])

            w.writerow(
                [pr_id, month, year, base, allow, shift, sale, penalty, emp]
            )

    # ---------- 16. SERVICE ----------
    service_ids = []
    service_data = {}
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

        # Dịch vụ với giá cụ thể
        SERVICE_DETAILS = [
            ("Tủ đồ cá nhân loại nhỏ", "Lượt", 20_000),
            ("Tủ đồ cá nhân loại lớn", "Lượt", 30_000),
            ("Tủ đồ VIP có khóa điện tử", "Lượt", 50_000),
            ("Thuê vợt cầu lông Yonex", "Giờ", 30_000),
            ("Thuê vợt cầu lông Victor", "Giờ", 25_000),
            ("Thuê vợt tennis Wilson", "Giờ", 50_000),
            ("Thuê vợt tennis Head", "Giờ", 45_000),
            ("Thuê bóng đá size 4", "Lượt", 30_000),
            ("Thuê bóng đá size 5", "Lượt", 40_000),
            ("Thuê bóng rổ Spalding", "Lượt", 35_000),
            ("Thuê giày thể thao", "Giờ", 40_000),
            ("Thuê áo đấu có số", "Lượt", 20_000),
            ("Phòng VIP có điều hòa", "Giờ", 200_000),
            ("Phòng VIP có màn hình LED", "Giờ", 350_000),
            ("Phòng họp đội", "Giờ", 150_000),
            ("Thuê HLV cá nhân - Basic", "Giờ", 300_000),
            ("Thuê HLV cá nhân - Pro", "Giờ", 500_000),
            ("Thuê HLV nhóm", "Giờ", 400_000),
            ("Nước suối Aquafina", "Lượt", 10_000),
            ("Nước tăng lực Redbull", "Lượt", 25_000),
            ("Nước điện giải Pocari", "Lượt", 20_000),
            ("Khăn tắm cotton", "Lượt", 15_000),
            ("Khăn mặt", "Lượt", 10_000),
            ("Dầu gội sữa tắm combo", "Lượt", 20_000),
            ("Massage thư giãn 30 phút", "Lượt", 200_000),
            ("Massage thể thao 60 phút", "Lượt", 350_000),
            ("Xông hơi khô", "Lượt", 100_000),
            ("Xông hơi ướt", "Lượt", 80_000),
            ("Bể sục jacuzzi", "Giờ", 150_000),
            ("Phòng tắm VIP", "Lượt", 50_000),
            ("Đỗ xe ô tô", "Lượt", 30_000),
            ("Đỗ xe máy VIP", "Lượt", 10_000),
            ("Gửi đồ qua đêm", "Ngày", 50_000),
            ("Dịch vụ giặt đồ", "Lượt", 40_000),
            ("Cho thuê đồng phục thi đấu", "Lượt", 100_000),
            ("Livestream trận đấu", "Giờ", 500_000),
        ]

        statuses = ["Đang hoạt động", "Tạm ngưng", "Bảo trì"]
        status_weights = [85, 10, 5]

        for i in range(1, N_SERVICE + 1):
            sid = f"SRV{i:04d}"
            service_ids.append(sid)

            if i <= len(SERVICE_DETAILS):
                name, unit, base_price = SERVICE_DETAILS[i - 1]
                # Dao động giá +-20%
                price = int(base_price * random.uniform(0.8, 1.2))
                price = round(price / 1000) * 1000  # Làm tròn
            else:
                name = f"Dịch vụ khác {i}"
                unit = random.choice(["Giờ", "Lượt", "Ngày"])
                price = random.randint(20_000, 300_000)

            status = random.choices(statuses, weights=status_weights, k=1)[0]
            service_data[sid] = {"name": name, "price": price, "type": unit}

            w.writerow([sid, name, unit, price, status])

    # ---------- 17. PERSONAL_CLOSET ----------
    with open("PERSONAL_CLOSET.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["PCServiceID", "ClosetID", "StatusCloset"])

        # Lấy các service là tủ đồ
        closet_services = [
            sid
            for sid in service_ids
            if "Tủ đồ" in service_data.get(sid, {}).get("name", "")
        ]
        if not closet_services:
            closet_services = service_ids[:3]

        closet_statuses = ["Trống", "Đang sử dụng", "Bảo trì", "Đã đặt trước"]
        status_weights = [30, 55, 10, 5]

        # Mỗi closet_service chỉ xuất hiện 1 lần
        for i, sid in enumerate(closet_services[:N_PERSONAL_CLOSET], 1):
            status = random.choices(
                closet_statuses, weights=status_weights, k=1
            )[0]
            w.writerow([sid, i, status])

    # ---------- 18. RENTING_EQUIPMENT ----------
    with open("RENTING_EQUIPMENT.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["REServiceID", "EquipmentType", "Quantity"])

        # Lấy service liên quan đến thuê dụng cụ
        equip_services = [
            sid
            for sid in service_ids
            if "Thuê" in service_data.get(sid, {}).get("name", "")
            and "HLV" not in service_data.get(sid, {}).get("name", "")
        ]
        if not equip_services:
            equip_services = service_ids[:10]

        # Mỗi equip_service chỉ xuất hiện 1 lần
        equip_services = equip_services[:N_RENT_EQUIP]
        for sid in equip_services:
            eq_type = random.choice(EQUIPMENT_TYPES)
            # Số lượng theo loại thiết bị
            if "Vợt" in eq_type:
                qty = random.randint(5, 30)
            elif "Bóng" in eq_type:
                qty = random.randint(10, 50)
            elif "Giày" in eq_type or "Áo" in eq_type:
                qty = random.randint(20, 100)
            else:
                qty = random.randint(5, 20)

            w.writerow([sid, eq_type, qty])

    # ---------- 19. VIP_ROOM ----------
    with open("VIP_ROOM.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["VRServiceID", "RoomID", "StatusRoom"])

        # Lấy service phòng VIP
        vip_services = [
            sid
            for sid in service_ids
            if "Phòng" in service_data.get(sid, {}).get("name", "")
            or "VIP" in service_data.get(sid, {}).get("name", "")
        ]
        if not vip_services:
            vip_services = service_ids[:5]

        room_statuses = [
            "Trống",
            "Đang sử dụng",
            "Đang dọn dẹp",
            "Bảo trì",
            "Đã đặt trước",
        ]
        status_weights = [25, 45, 15, 5, 10]

        # Mỗi vip_service chỉ xuất hiện 1 lần
        vip_services = vip_services[:N_VIP_ROOM]
        for i, sid in enumerate(vip_services, 1):
            status_choice = random.choices(
                room_statuses, weights=status_weights, k=1
            )[0]
            w.writerow([sid, i, status_choice])

    # ---------- 20. RENTING_HLV ----------
    with open("RENTING_HLV.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["RHServiceID", "Status", "Coach"])

        # Lấy service thuê HLV
        hlv_services = [
            sid
            for sid in service_ids
            if "HLV" in service_data.get(sid, {}).get("name", "")
        ]
        if not hlv_services:
            hlv_services = service_ids[:5]

        hlv_statuses = ["Đang hoạt động", "Tạm ngưng", "Nghỉ phép"]
        status_weights = [75, 15, 10]

        # Mỗi hlv_service chỉ xuất hiện 1 lần
        hlv_services = hlv_services[:N_RENT_HLV]
        for sid in hlv_services:
            status = random.choices(hlv_statuses, weights=status_weights, k=1)[
                0
            ]
            w.writerow([sid, status, pick(coach_ids)])

    # ---------- 21. SERVICE_BOOKING ----------
    with open("SERVICE_BOOKING.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["SBID", "BookingID", "ServiceID", "BookingQuantity"])

        # Số lượng dịch vụ theo loại
        for i in range(1, N_SERVICE_BOOK + 1):
            sb_id = f"SBD{i:05d}"
            booking = pick(booking_ids)
            service = pick(service_ids)

            # Số lượng hợp lý theo loại dịch vụ
            svc_name = service_data.get(service, {}).get("name", "")
            if "Nước" in svc_name or "Khăn" in svc_name:
                qty = random.randint(1, 10)
            elif "Tủ đồ" in svc_name:
                qty = 1
            elif "Phòng" in svc_name:
                qty = 1
            elif "HLV" in svc_name:
                qty = random.randint(1, 3)
            else:
                qty = random.randint(1, 5)

            w.writerow([sb_id, booking, service, qty])

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

        pay_methods = [
            "Tiền mặt",
            "Chuyển khoản ngân hàng",
            "Thẻ Visa/Master",
            "MoMo",
            "ZaloPay",
            "VNPay",
            "ShopeePay",
        ]
        pay_weights = [30, 25, 15, 12, 8, 7, 3]

        statuses = ["Đã thanh toán", "Chưa thanh toán", "Hủy", "Đang xử lý"]
        status_weights = [70, 15, 10, 5]

        for i in range(1, N_INVOICE + 1):
            inv_id = f"INV{i:05d}"

            booking = pick(booking_ids)
            bk_data = booking_data.get(booking, {})

            # Thời gian thuê từ booking
            rent_time = bk_data.get(
                "start",
                random_datetime(datetime(2024, 1, 1), datetime(2024, 12, 31)),
            )

            # Tính tổng tiền dựa trên sân + dịch vụ
            court = pick(court_ids)
            court_info = court_data.get(court, {})
            court_price = court_info.get("price", 200_000)
            duration = bk_data.get("duration", random.randint(1, 3))

            # Giá = giá sân * số giờ + phí dịch vụ ngẫu nhiên
            base_total = court_price * duration
            service_fee = random.randint(0, 500_000)
            total = base_total + service_fee

            # Áp dụng giảm giá
            disc = ""
            if discount_ids and random.random() < 0.4:
                disc = pick(discount_ids)
                # Giả định giảm 10-20%
                total = int(total * random.uniform(0.8, 0.95))

            total = round(total / 1000) * 1000  # Làm tròn

            pay_method = random.choices(pay_methods, weights=pay_weights, k=1)[
                0
            ]
            status = random.choices(statuses, weights=status_weights, k=1)[0]

            # Nhân viên thu ngân
            cashier = pick(employee_ids)

            w.writerow(
                [
                    inv_id,
                    rent_time,
                    total,
                    pay_method,
                    rent_time,
                    status,
                    booking,
                    disc,
                    court,
                    cashier,
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

        cancel_statuses = ["Pending", "Approved", "Rejected", "Processing"]
        cancel_weights = [20, 55, 15, 10]

        # Chỉ tạo form hủy cho các booking đã bị hủy
        cancelled_bookings = [
            bkid
            for bkid, data in booking_data.items()
            if data.get("status") == "Cancelled"
        ]

        for i in range(1, N_CANCEL_FORM + 1):
            cf_id = f"CNF{i:04d}"

            # Ưu tiên booking đã cancelled
            if cancelled_bookings and random.random() < 0.7:
                booking = random.choice(cancelled_bookings)
            else:
                booking = pick(booking_ids)

            bk_data = booking_data.get(booking, {})
            bk_start = bk_data.get("start", datetime(2024, 6, 15))

            # Thời gian hủy trước thời gian chơi
            hours_before = random.choices(
                [1, 2, 6, 12, 24, 48], weights=[5, 10, 20, 25, 25, 15], k=1
            )[0]
            cancel_time = bk_start - timedelta(hours=hours_before)

            # Phí phạt dựa trên quy định và thời gian hủy
            if hours_before >= 24:
                penalty = 0
            elif hours_before >= 12:
                penalty = random.randint(30_000, 80_000)
            elif hours_before >= 6:
                penalty = random.randint(80_000, 150_000)
            elif hours_before >= 2:
                penalty = random.randint(150_000, 250_000)
            else:
                penalty = random.randint(200_000, 400_000)

            status = random.choices(
                cancel_statuses, weights=cancel_weights, k=1
            )[0]

            w.writerow(
                [
                    cf_id,
                    cancel_time,
                    penalty,
                    status,
                    pick(cancel_rule_ids),
                    booking,
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
