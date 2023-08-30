CREATE DATABASE CINEMA
Go
USE CINEMA
CREATE TABLE vai_tro (
id_vaitro varchar (15) not null,
ten nvarchar (50) not null,
constraint PK_vaitro primary key (id_vaitro) )
CREATE TABLE ca_lam_viec (
id varchar (15) not null,
tg_batdau nvarchar (15) not null,
tg_ketthuc nvarchar (15) not null,
constraint PK_calamviec primary key (id) 
)
CREATE TABLE nguoi_dung ( 
id_nguoidung varchar (15) not null,
ho nvarchar (10) not null,
ten nvarchar (40) not null,
gioitinh nvarchar (3),
ngaysinh date,
so_cccd_cmnd varchar (15) not null,
sodienthoai varchar (15) not null,
email varchar (30) not null,
diachi nvarchar (100),
ngayvaolam date,
tinhtranglam bit,
id_vaitro varchar (15) not null ,
id_quanly varchar (15) ,
id_ca varchar (15) not null
constraint PK_nguoidung primary key (id_nguoidung),
constraint UC_nguoidung unique (so_cccd_cmnd,sodienthoai,email),
constraint FK_vaitro foreign key (id_vaitro) references vai_tro (id_vaitro),
constraint FK_quanly foreign key (id_nguoidung) references nguoi_dung
(id_nguoidung),
constraint FK_calamviec foreign key (id_ca) references ca_lam_viec(id) 
)
CREATE TABLE khach_hang (
id_khachhang varchar (15) not null,
ho nvarchar (10) not null,
ten nvarchar (40) not null,
gioitinh nvarchar (3),
ngaysinh date,
sodienthoai varchar (15) not null,
email varchar (30) not null,
constraint PK_khachhang primary key (id_khachhang),
constraint UC_khachhang unique (sodienthoai,email),
)
CREATE TABLE thuc_an_nhanh (
id_thucan varchar (15),
tendoan nvarchar (50),
dongia int,
kichco nvarchar (10),
constraint PK_thucannhanh primary key (id_thucan),
)
CREATE TABLE hoa_don_tan (
id_hoadon varchar (15) not null,
ngayban date not null,
soluong int not null,
id_khachhang varchar (15),
id_tan varchar (15) not null,
id_nvban varchar (15) not null,
constraint PK_hoadon primary key (id_hoadon),
constraint Fk_khachdat foreign key (id_khachhang) references khach_hang
(id_khachhang),
constraint Fk_nvbanve foreign key (id_nvban) references nguoi_dung(id_nguoidung),
constraint Fk_TAN foreign key (id_tan) references thuc_an_nhanh(id_thucan) 
)
CREATE TABLE loai_ghe (
id_loaighe varchar (15) not null,
loaighe nvarchar (15) not null,
dongia int not null,
constraint PK_loaighe primary key (id_loaighe),
constraint UC_loaighe unique (loaighe) 
)
CREATE TABLE phong_chieu (
id_phongchieu varchar (15) not null,
ten_phong nvarchar (15) not null,
loaiphong nvarchar (10),
id_giamsat varchar (15),
constraint PK_phongchieu primary key (id_phongchieu),
constraint FK_giamsat foreign key (id_giamsat) references nguoi_dung
(id_nguoidung) 
)
CREATE TABLE day_ghe (
id_dayghe varchar (15) not null,
vitriday nvarchar(1) not null,
id_phongchieu varchar (15) not null,
constraint PK_dayghe primary key (id_dayghe),
constraint FK_phongchieu foreign key (id_phongchieu) references phong_chieu
(id_phongchieu),
)
CREATE TABLE vi_tri_ngoi (
id_vitri varchar (15) not null,
id_dayghe varchar (15) not null,
trangthai bit not null,
id_loaighe varchar (15) not null,
constraint PK_vitringoi primary key (id_vitri,id_dayghe),
constraint FK_ghe foreign key (id_dayghe) references day_ghe(id_dayghe),
constraint FK_loaighe foreign key (id_loaighe) references loai_ghe (id_loaighe)
)
CREATE TABLE dinh_dang_phim (
id_dinhdangphim varchar (15) not null,
tendinhdang varchar (5) not null,
constraint PK_dinhdangphim primary key (id_dinhdangphim) 
)
CREATE TABLE phim( 
id_phim varchar (15) not null,
ten nvarchar (100) not null,
thoiluong int, 
gioihantuoi nvarchar (50),
ngaycongchieu date not null,
ngonngu nvarchar (100),
dienvien nvarchar (100) ,
theloai nvarchar (100),
quocgia nvarchar (20),
daodien nvarchar (50),
tomtat nvarchar(max) not null,
trangthai nvarchar (15),
constraint PK_phim primary key (id_phim) 
)
CREATE TABLE suat_chieu (
id_suatchieu varchar (15) not null,
giobatdau nvarchar (15) not null,
ngaychieu date not null,
id_phim varchar (15) not null,
id_phong varchar (15) not null,
id_ddp varchar (15) not null
constraint PK_suatchieu primary key (id_suatchieu),
constraint FK_phim foreign key (id_phim) references phim (id_phim),
constraint FK_phong foreign key (id_phong) references phong_chieu(id_phongchieu),
constraint FK_dinhdangphim foreign key (id_ddp) references
dinh_dang_phim(id_dinhdangphim) 
)
CREATE TABLE loai_ve (
id_loaive varchar (15) not null,
ten nvarchar (30) not null,
phuthu int not null,
constraint PK_loaive primary key (id_loaive) )
CREATE TABLE ve (
id_ve varchar (15) not null,
ngayban date not null,
id_loaive varchar (15) not null,
id_khachhang varchar (15),
id_suatchieu varchar (15) not null,
id_vitri varchar (15) not null,
id_dayghe varchar (15) not null,
id_banve varchar (15) not null,
constraint PK_ve primary key (id_ve),
constraint Fk_suatchieu foreign key (id_suatchieu) references suat_chieu (id_suatchieu),
constraint Fk_khach foreign key (id_khachhang) references khach_hang (id_khachhang),
constraint FK_ghengoi foreign key (id_vitri,id_dayghe) references vi_tri_ngoi(id_vitri,id_dayghe),
constraint FK_banve foreign key (id_banve) references nguoi_dung(id_nguoidung),
constraint FK_loaive foreign key (id_loaive) references loai_ve (id_loaive)
)