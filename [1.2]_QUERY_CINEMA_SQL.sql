-- [1] Lấy danh sách suất chiếu của tất cả các phim có trong ngày '28-08-2023'
SELECT 
	p.ten AS 'Tên phim', 
	p.thoiluong AS 'Thời lượng', 
	sc.giobatdau AS 'Giờ bắt đầu',
	ph.ten_phong 'Tên phòng' 
FROM phim AS p join suat_chieu AS sc ON p.id_phim=sc.id_phim 
	join phong_chieu AS ph ON ph.id_phongchieu = sc.id_phong 
	join dinh_dang_phim AS d ON d.id_dinhdangphim = sc.id_ddp 
WHERE sc.ngaychieu = '2023-28-08' 
ORDER BY p.ten
-- [2] Thủ tục hiển thị danh sách mua vé của một khách hàng cụ thể
if exists (select* from sys.objects where type = 'P' and name = 'giaodich')
 drop procedure giaodich 
go
create procedure giaodich 
@hokhachhang nvarchar (10),
@tenkhachhang nvarchar (30)
as
begin 
select kh.ho as 'Họ khách hàng',kh.ten as 'Tên khách hàng',v.ngayban as 'Ngày bán',p.ten as 'Tên 
phim', lv.ten as 'Loại vé', lg.loaighe as 'Loại ghế', d.vitriday as 'Hàng',n.id_vitri 'Số ghế'
from ve as v join khach_hang as kh on v.id_khachhang= kh.id_khachhang 
	join suat_chieu as sc on v.id_suatchieu=sc.id_suatchieu 
	join phim as p on p.id_phim=sc.id_phim 
	join vi_tri_ngoi as n on v.id_vitri=n.id_vitri and v.id_dayghe=n.id_dayghe 
	join day_ghe as d on d.id_dayghe=n.id_dayghe 
	join loai_ve as lv on lv.id_loaive=v.id_loaive 
	join loai_ghe as lg on lg.id_loaighe=n.id_loaighe 
	where kh.ho = @hokhachhang and kh.ten =@tenkhachhang 
end; 
exec giaodich N'Họ khách hàng',N'Tên khách hàng'

-- [3] Thủ tục hiển thị danh sách khách hàng đã đặt vé trong một suất chiếu cụ thể
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'danhsach')
 DROP PROCEDURE danhsach 
GO
CREATE PROCEDURE danhsach 
@giobatdau NVARCHAR (15)
AS
BEGIN 
SELECT kh.ho AS 'Họ khách hàng',kh.ten AS 'Tên khách hàng',p.ten AS 'Tên phim' ,
sc.giobatdau AS 'Giờ bắt đầu', count(*) AS 'Số vé đã mua' FROM khach_hang AS kh 
	join ve AS v ON kh.id_khachhang=v.id_khachhang 
	join suat_chieu AS sc ON v.id_suatchieu= sc.id_suatchieu 
	join phim AS p ON p.id_phim=sc.id_phim 
WHERE sc.giobatdau = @giobatdau 
GROUP BY kh.ho,kh.ten,p.ten,sc.giobatdau 
END;
EXEC danhsach 'Giờ bắt đầu' 
-- [4] Hiển thị phòng chiếu ghế đã chọn và ghế còn trống
CREATE TABLE #xemphongchieu (tenphong VARCHAR(max), hang VARCHAR(1), ghengoi VARCHAR (2), chon_ghe NUMERIC (10));
WITH danhsach AS 
( SELECT a.vitriday, ROW_NUMBER() OVER (PARTITION BY a.id_dayghe ORDER BY a.id_dayghe) AS 'ghengoi', a.id_phongchieu,a.id_dayghe 
	FROM day_ghe AS a join vi_tri_ngoi AS b ON a.id_dayghe=b.id_dayghe 
	WHERE a.id_phongchieu='R1' )
INSERT INTO #xemphongchieu 
SELECT 
	d.ten_phong tenphong, 
	l.vitriday hang, 
	l.ghengoi,
CASE WHEN c.trangthai = 'True' THEN c.id_vitri ELSE 0 END chon_ghe 
FROM DANHSACH AS L LEFT JOIN VI_TRI_NGOI AS C 
	ON l.id_dayghe = c.id_dayghe and l.ghengoi=c.id_vitri 
	left join phong_chieu AS d 
	ON l.id_phongchieu=d.id_phongchieu 
DECLARE @APL AS VARCHAR (MAX)
DECLARE @pl AS VARCHAR (max)
DECLARE @dpq AS VARCHAR (max)
SELECT @apl = stuff ((SELECT DISTINCT ',['+ghengoi+']' FROM #xemphongchieu FOR XML PATH ('')),1,1,'')
SELECT @pl = stuff ((SELECT DISTINCT ',['+ghengoi+']' FROM #xemphongchieu FOR XML PATH ('')),1,1,'')
SET @dpq = 'select [tenphong],[hang],'+@apl+'from (
	select [tenphong],[hang],[ghengoi],[chon_ghe] from #xemphongchieu) as S
	Pivot (SUM ([chon_ghe]) for [ghengoi] in ('+@pl+')) as P'
EXEC (@dpq)
DROP TABLE #xemphongchieu

-- [6] Doanh thu của rạp chiếu phim
SELECT SUM(tongtienthuan + tongtienve) AS 'Doanh thu'
FROM (
 SELECT SUM(thucan.dongia) AS tongtienthuan 
 FROM ( 
	 SELECT * 
	 FROM thuc_an_nhanh AS ta 
	 JOIN hoa_don_tan AS hd ON hd.id_tan = ta.id_thucan 
	 ) AS thucan 
) AS a 
CROSS JOIN (
	 SELECT SUM(veban.dongia) + SUM(veban.phuthu) AS tongtienve 
	 FROM (
	 SELECT d.dongia, b.phuthu, c.id_vitri, c.id_dayghe 
	 FROM ve AS a 
	 JOIN loai_ve AS b ON a.id_loaive = b.id_loaive 
	 JOIN vi_tri_ngoi AS c ON c.id_vitri = a.id_vitri AND c.id_dayghe = a.id_dayghe 
	 JOIN loai_ghe AS d ON d.id_loaighe = c.id_loaighe 
	 ) AS veban 
) AS b;
