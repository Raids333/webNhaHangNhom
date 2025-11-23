create database QLNhaHang;
use QLNhaHang;

select * from TaiKhoan
select * from VaiTro
select * from TaiKhoan_VaiTro

-- 1. Bảng Tài khoản 
CREATE TABLE TaiKhoan(
    TaiKhoanID INT IDENTITY(1,1) CONSTRAINT PK_TaiKhoan PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL CONSTRAINT UQ_TaiKhoan_TenDN UNIQUE, -- Giảm xuống 50 ký tự là đủ
    MatKhau VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NULL CONSTRAINT UQ_TaiKhoan_Email UNIQUE, -- Email có thể null nếu tạo nhanh
    SDT VARCHAR(15) NOT NULL CONSTRAINT UQ_TaiKhoan_SDT UNIQUE,
    HoatDong BIT NOT NULL CONSTRAINT DF_TaiKhoan_HoatDong DEFAULT (1),
    NgayTao DATETIME2(0) NOT NULL CONSTRAINT DF_TaiKhoan_NgayTao DEFAULT (SYSDATETIME())
);

-- 2. Bảng Vai trò
CREATE TABLE VaiTro(
    VaiTroID INT IDENTITY(1,1) CONSTRAINT PK_VaiTro PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL CONSTRAINT UQ_VaiTro_Ten UNIQUE
);
INSERT INTO VaiTro (TenVaiTro)
VALUES 
    (N'Khách Hàng'),
    (N'Quản Lí');


-- 3. Phân quyền (User - Role)
CREATE TABLE TaiKhoan_VaiTro(
	ID INT IDENTITY(1,1) PRIMARY KEY,
    TaiKhoanID INT NOT NULL,
    VaiTroID INT NOT NULL,
    CONSTRAINT FK_TKVT_TaiKhoan FOREIGN KEY (TaiKhoanID) REFERENCES TaiKhoan(TaiKhoanID),
    CONSTRAINT FK_TKVT_VaiTro FOREIGN KEY (VaiTroID) REFERENCES VaiTro(VaiTroID)
);

-- 4. Khách hàng
CREATE TABLE KhachHang(
    KhachHangID INT IDENTITY(1,1) CONSTRAINT PK_KhachHang PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) NOT NULL, -- Lưu SDT ở đây để tiện liên lạc nếu không có TaiKhoan
    TaiKhoanID INT NULL CONSTRAINT UQ_KhachHang_TaiKhoanID UNIQUE, -- Cho phép NULL (Khách vãng lai)
    DiemTichLuy INT NOT NULL CONSTRAINT DF_KH_Diem DEFAULT (0),
    CONSTRAINT FK_KhachHang_TaiKhoan FOREIGN KEY (TaiKhoanID) REFERENCES TaiKhoan(TaiKhoanID)
);

-- 5. Nhân viên
CREATE TABLE NhanVien(
    NhanVienID INT IDENTITY(1,1) CONSTRAINT PK_NhanVien PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    TaiKhoanID INT NOT NULL CONSTRAINT UQ_NhanVien_TaiKhoanID UNIQUE, -- Nhân viên bắt buộc có tài khoản để đăng nhập
    ChucVu NVARCHAR(50) NOT NULL,
    LuongCoBan DECIMAL(18,0) NOT NULL DEFAULT 0, -- Dùng Decimal lớn cho tiền tệ VNĐ
    CONSTRAINT FK_NhanVien_TaiKhoan FOREIGN KEY (TaiKhoanID) REFERENCES TaiKhoan(TaiKhoanID)
);
-- 6. Bàn ăn
CREATE TABLE Ban(
    BanID INT IDENTITY(1,1) CONSTRAINT PK_Ban PRIMARY KEY,
    TenBan NVARCHAR(50) NOT NULL CONSTRAINT UQ_Ban_Ten UNIQUE,
    SucChua INT NOT NULL DEFAULT 4,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Trống' 
    CONSTRAINT CK_Ban_TrangThai CHECK (TrangThai IN (N'Trống', N'Đã Đặt', N'Đang Phục Vụ', N'Bảo Trì'))
);
INSERT INTO Ban (TenBan, SucChua, TrangThai) VALUES 
-- KHU VỰC BÀN ĐÔI (Capacity 2)
(N'Bàn 01 (Cửa sổ)', 2, N'Trống'),
(N'Bàn 02 (Cửa sổ)', 2, N'Đang Phục Vụ'), -- Test: Bàn đang có khách
(N'Bàn 03', 2, N'Trống'),

-- KHU VỰC PHỔ THÔNG (Capacity 4 - Phổ biến nhất)
(N'Bàn 04', 4, N'Trống'),
(N'Bàn 05', 4, N'Trống'),
(N'Bàn 06', 4, N'Đã Đặt'),       -- Test: Bàn đã có người đặt trước
(N'Bàn 07', 4, N'Trống'),
(N'Bàn 08', 4, N'Trống'),
(N'Bàn 09', 4, N'Bảo Trì'),      -- Test: Bàn bị hỏng, không được hiện ra để đặt
(N'Bàn 10', 4, N'Trống'),

-- KHU VỰC GIA ĐÌNH (Capacity 6-8)
(N'Bàn 11 (Góc)', 6, N'Trống'),
(N'Bàn 12', 6, N'Đang Phục Vụ'),
(N'Bàn 13 (Tròn)', 8, N'Trống'),
(N'Bàn 14 (Tròn)', 8, N'Trống'),

-- KHU VỰC VIP / TIỆC (Capacity 10+)
(N'VIP 01', 10, N'Trống'),
(N'VIP 02', 12, N'Trống'),
(N'Bàn Tiệc Dài', 20, N'Trống');

-- 7. Loại món
CREATE TABLE LoaiMon(
    LoaiMonID INT IDENTITY(1,1) CONSTRAINT PK_LoaiMon PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL CONSTRAINT UQ_LoaiMon_Ten UNIQUE
);
INSERT INTO LoaiMon (TenLoai) VALUES 
(N'Khai Vị'),           
(N'Hải Sản Cao Cấp'),   
(N'Món Thịt & Steak'),  
(N'Món Lẩu'),          
(N'Tráng Miệng'),       
(N'Đồ Uống');

-- 8. Món ăn
CREATE TABLE MonAn(
    MonAnID INT IDENTITY(1,1) CONSTRAINT PK_MonAn PRIMARY KEY,
    TenMon NVARCHAR(150) NOT NULL CONSTRAINT UQ_MonAn_Ten UNIQUE,
    LoaiMonID INT NOT NULL,
    AnhMon NVARCHAR(255) NULL,
    DonGia DECIMAL(18,0) NOT NULL DEFAULT 0,
    DangKinhDoanh BIT NOT NULL DEFAULT 1, -- Thay "ConBan" bằng "DangKinhDoanh" rõ nghĩa hơn
    MoTa NVARCHAR(500) NULL,
    CONSTRAINT FK_MonAn_LoaiMon FOREIGN KEY (LoaiMonID) REFERENCES LoaiMon(LoaiMonID)
);
-- 1. KHAI VỊ 
DECLARE @IdKhaiVi INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Khai Vị');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Salad Rong Nho Cá Ngừ', @IdKhaiVi, 89000, N'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80', N'Sự kết hợp tươi mát giữa rong nho biển giòn tan và cá ngừ đại dương, sốt mè rang.', 1),
(N'Gỏi Cuốn Tôm Thịt', @IdKhaiVi, 65000, N'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=800&q=80', N'Món khai vị truyền thống với tôm tươi, thịt ba chỉ, bún tươi và rau sống.', 1),
(N'Súp Bí Đỏ Kem Tươi', @IdKhaiVi, 55000, N'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2b?auto=format&fit=crop&w=800&q=80', N'Súp bí đỏ nghiền mịn nấu cùng kem tươi béo ngậy, ăn kèm bánh mì nướng bơ tỏi.', 1),
(N'Khoai Tây Chiên Phủ Phô Mai', @IdKhaiVi, 45000, N'https://images.unsplash.com/photo-1573080496987-a199f8cd75ec?auto=format&fit=crop&w=800&q=80', N'Khoai tây chiên giòn rụm phủ lớp bột phô mai nhập khẩu thơm lừng.', 1);

-- 2. HẢI SẢN 
DECLARE @IdHaiSan INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Hải Sản Cao Cấp');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Tôm Hùm Alaska Nướng Phô Mai', @IdHaiSan, 1250000, N'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80', N'Tôm hùm Alaska nguyên con nướng cùng sốt phô mai Mozzarella tan chảy.', 1),
(N'Cua Hoàng Đế Hấp Sả', @IdHaiSan, 2500000, N'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?auto=format&fit=crop&w=800&q=80', N'Cua King Crab nhập khẩu, thịt chắc ngọt, hấp sả giữ trọn hương vị biển.', 1),
(N'Cá Hồi Áp Chảo Sốt Chanh dây', @IdHaiSan, 290000, N'https://images.unsplash.com/photo-1467003909585-2f8a7270028d?auto=format&fit=crop&w=800&q=80', N'Phi lê cá hồi Nauy áp chảo da giòn, dùng kèm sốt chanh dây chua ngọt.', 1),
(N'Mực Một Nắng Nướng Muối Ớt', @IdHaiSan, 180000, N'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?auto=format&fit=crop&w=800&q=80', N'Mực câu một nắng dày mình, nướng than hoa cùng muối ớt xanh cay nồng.', 1);

-- 3. THỊT & STEAK 
DECLARE @IdThit INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Món Thịt & Steak');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Bò Wagyu Dát Vàng', @IdThit, 1890000, N'https://images.unsplash.com/photo-1546964124-0cce460f38ef?auto=format&fit=crop&w=800&q=80', N'Thăn bò Wagyu A5 thượng hạng, mềm tan trong miệng, trang trí lá vàng thực phẩm.', 1),
(N'Sườn Cừu Nướng Thảo Mộc', @IdThit, 450000, N'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80', N'Sườn cừu Úc nướng cùng lá hương thảo (Rosemary), kèm khoai tây nghiền.', 1),
(N'Gà Nướng Mật Ong Tây Bắc', @IdThit, 199000, N'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=800&q=80', N'Gà đồi nguyên con nướng mật ong rừng và hạt mắc khén thơm lừng.', 1);

-- 4. LẨU 
DECLARE @IdLau INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Món Lẩu');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Lẩu Thái Tomyum Hải Sản', @IdLau, 350000, N'https://images.unsplash.com/photo-1549396535-c11d5c55b9df?auto=format&fit=crop&w=800&q=80', N'Nước lẩu chua cay đậm đà vị cốt dừa, nhúng kèm tôm, mực, nghêu và nấm.', 1),
(N'Lẩu Nấm Thiên Nhiên (Chay)', @IdLau, 250000, N'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80', N'Nước dùng ngọt thanh từ rau củ, kèm 5 loại nấm quý và đậu hũ non.', 1);

-- 5. TRÁNG MIỆNG 
DECLARE @IdTrangMieng INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Tráng Miệng');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Panna Cotta Dâu Tây', @IdTrangMieng, 49000, N'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80', N'Bánh kem sữa kiểu Ý mềm mịn, sốt dâu tây tươi.', 1),
(N'Tiramisu', @IdTrangMieng, 59000, N'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=800&q=80', N'Bánh ngọt vị cafe và rượu rum, phủ bột cacao.', 1);

-- 6. ĐỒ UỐNG 
DECLARE @IdDoUong INT = (SELECT LoaiMonID FROM LoaiMon WHERE TenLoai = N'Đồ Uống');

INSERT INTO MonAn (TenMon, LoaiMonID, DonGia, AnhMon, MoTa, DangKinhDoanh) VALUES
(N'Trà Đào Cam Sả', @IdDoUong, 45000, N'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80', N'Trà thanh mát, giải nhiệt với miếng đào giòn ngọt.', 1),
(N'Rượu Vang Đỏ (Ly)', @IdDoUong, 120000, N'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=800&q=80', N'Rượu vang Cabernet Sauvignon nhập khẩu.', 1),
(N'Nước Ép Dưa Hấu', @IdDoUong, 35000, N'https://images.unsplash.com/photo-1589984662646-e7b2e4962f18?auto=format&fit=crop&w=800&q=80', N'Nước ép nguyên chất 100%, không đường.', 1);

-- 9. Đặt bàn 
drop table DatBan
CREATE TABLE DatBan(
    DatBanID INT IDENTITY(1,1) CONSTRAINT PK_DatBan PRIMARY KEY,
    KhachHangID INT NULL, 
    ThongTinNguoiDat NVARCHAR(150) NULL, 
    BanID INT NOT NULL,
    SoNguoi INT NOT NULL DEFAULT 1,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Chờ Xác Nhận'
    CONSTRAINT CK_DatBan_TrangThai CHECK (TrangThai IN (N'Chờ Xác Nhận', N'Đã Xác Nhận', N'Đã Nhận Bàn', N'Hủy', N'Hoàn Thành')),
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT FK_DatBan_KhachHang FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID),
    CONSTRAINT FK_DatBan_Ban FOREIGN KEY (BanID) REFERENCES Ban(BanID)
);

ALTER TABLE DatBan
ADD ThoiGianBatDau DATETIME2(0) NOT NULL 
    CONSTRAINT DF_DatBan_BatDau DEFAULT (SYSDATETIME());

ALTER TABLE DatBan
ADD ThoiGianKetThuc DATETIME2(0) NOT NULL
    CONSTRAINT DF_DatBan_KetThuc DEFAULT (DATEADD(HOUR, 2, SYSDATETIME()));

ALTER TABLE DatBan
ADD CONSTRAINT CK_DatBan_ThoiGian CHECK (ThoiGianKetThuc > ThoiGianBatDau);

select * from DatBan
select * from Ban


-- 10. Đơn hàng (Order)
CREATE TABLE DonHang(
    DonHangID INT IDENTITY(1,1) CONSTRAINT PK_DonHang PRIMARY KEY,
    NhanVienID INT NOT NULL, 
    KhachHangID INT NULL, 
    BanID INT NULL, 
    DatBanID INT NULL, 
    
    ThoiGianTao DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    TongTien DECIMAL(18,0) NOT NULL DEFAULT 0, 
    
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Đang Phục Vụ'
    CONSTRAINT CK_DonHang_TrangThai CHECK (TrangThai IN (N'Chờ Xử Lý', N'Đang Phục Vụ', N'Đã Thanh Toán', N'Hủy')),
    
    GhiChu NVARCHAR(255) NULL,
    
    CONSTRAINT FK_DonHang_NhanVien FOREIGN KEY (NhanVienID) REFERENCES NhanVien(NhanVienID),
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID),
    CONSTRAINT FK_DonHang_Ban FOREIGN KEY (BanID) REFERENCES Ban(BanID),
    CONSTRAINT FK_DonHang_DatBan FOREIGN KEY (DatBanID) REFERENCES DatBan(DatBanID)
);

-- 11. Chi tiết đơn hàng 
CREATE TABLE CT_DonHang(
    CTDonHangID INT IDENTITY(1,1) CONSTRAINT PK_CTDonHang PRIMARY KEY, 
    DonHangID INT NOT NULL,
    MonAnID INT NOT NULL,
    SoLuong INT NOT NULL CONSTRAINT CK_CT_SoLuong CHECK (SoLuong > 0),
    DonGia DECIMAL(18,0) NOT NULL, 
    ThanhTien AS (SoLuong * DonGia), 
    GhiChuMon NVARCHAR(100) NULL, 
    
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID),
    CONSTRAINT FK_CTDH_MonAn FOREIGN KEY (MonAnID) REFERENCES MonAn(MonAnID)
);

-- 12. Thanh toán
CREATE TABLE ThanhToan(
    ThanhToanID INT IDENTITY(1,1) CONSTRAINT PK_ThanhToan PRIMARY KEY,
    DonHangID INT NOT NULL,
    ThoiGianTT DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    SoTien DECIMAL(18,0) NOT NULL,
    PhuongThuc NVARCHAR(30) NOT NULL DEFAULT N'Tiền mặt'
    CONSTRAINT CK_TT_PhuongThuc CHECK (PhuongThuc IN (N'Tiền mặt', N'Chuyển khoản', N'QR', N'Thẻ')),
    GhiChu NVARCHAR(255) NULL,
    
    CONSTRAINT FK_ThanhToan_DonHang FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID)
);