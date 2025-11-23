using QLNha_Hang.Models;
using System;
using System.Data.Entity; 
using System.Linq;
using System.Transactions; 
using System.Web.Mvc;

namespace QLNha_Hang.Controllers
{
    public class BookingController : Controller
    {
        private QLNhaHangEntities1 db = new QLNhaHangEntities1();

        public ActionResult Index()
        {
            if (Session["UserID"] == null)
            {
                TempData["ErrorMessage"] = "Bạn cần đăng nhập để đặt bàn.";
                return RedirectToAction("Login", "Account", new { returnUrl = Url.Action("Index", "Booking") });
            }

            var model = new FormDatBanVM();
            if (Session["FullName"] != null) model.HoTen = Session["FullName"].ToString();

            int userId = Convert.ToInt32(Session["UserID"]);
            var user = db.TaiKhoans.Find(userId);
            if (user != null) model.SDT = user.SDT;

            model.ThoiGianBatDau = DateTime.Now;
            model.ThoiGianKetThuc = DateTime.Now.AddHours(2);

            model.SoNguoi = 2;

            return View(model);
        }



        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(FormDatBanVM model)
        {
            if (Session["UserID"] == null)
            {
                return RedirectToAction("Login", "Account");
            }
            if (!ModelState.IsValid)
            {
                return View(model);
            }
            if (model.ThoiGianBatDau < DateTime.Now.AddMinutes(15))
            {
                ModelState.AddModelError("ThoiGianBatDau", "Thời gian đặt phải trước ít nhất 15 phút.");
                return View(model);
            }
            DateTime thoiGianKetThuc = model.ThoiGianKetThuc;

            using (var scope = new TransactionScope())
            {
                try
                {
                    int taiKhoanID = Convert.ToInt32(Session["UserID"]);
                    var khachHang = db.KhachHangs.FirstOrDefault(k => k.TaiKhoanID == taiKhoanID);

                    if (khachHang == null)
                    {
                        khachHang = new KhachHang
                        {
                            HoTen = model.HoTen,
                            SDT = model.SDT,
                            TaiKhoanID = taiKhoanID,
                            DiemTichLuy = 0
                        };
                        db.KhachHangs.Add(khachHang);
                        db.SaveChanges();
                    }


                    var banBanIds = db.DatBans
                        .Where(d =>
                            d.TrangThai != "Hủy" &&
                            d.ThoiGianBatDau < thoiGianKetThuc &&
                            d.ThoiGianKetThuc > model.ThoiGianBatDau
                        )
                        .Select(d => d.BanID)
                        .Distinct()
                        .ToList();

                    var banTrong = db.Bans
                        .Where(b =>
                            b.SucChua >= model.SoNguoi &&
                            b.TrangThai != "Không Hoạt Động" &&
                            b.TrangThai != "Bảo Trì" &&
                            !banBanIds.Contains(b.BanID) 
                        )
                        .OrderBy(b => b.SucChua) 
                        .FirstOrDefault();

                    if (banTrong == null)
                    {
                        ModelState.AddModelError("", "Rất tiếc, không còn bàn trống phù hợp vào khung giờ này. Vui lòng chọn giờ khác.");
                        return View(model);
                    }
                    var datBan = new DatBan
                    {
                        KhachHangID = khachHang.KhachHangID,
                        BanID = banTrong.BanID,
                        ThoiGianBatDau = model.ThoiGianBatDau,
                        ThoiGianKetThuc = thoiGianKetThuc,
                        SoNguoi = model.SoNguoi,
                        GhiChu = model.GhiChu,
                        TrangThai = "Chờ Xác Nhận"
                    };

                    db.DatBans.Add(datBan);
                    db.SaveChanges();

                    scope.Complete(); 

                    return RedirectToAction("Success", new { id = datBan.DatBanID });
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("", "Lỗi hệ thống: " + ex.Message);
                    return View(model);
                }
            }
        }

        public ActionResult Success(int? id)
        {
            if (id == null) return RedirectToAction("Index");

            var datBan = db.DatBans.Find(id);
            if (datBan == null) return HttpNotFound();

            if (Session["UserID"] != null)
            {
                int uid = Convert.ToInt32(Session["UserID"]);
                if (datBan.KhachHang.TaiKhoanID != uid)
                {
                    return RedirectToAction("Index", "Home");
                }
            }

            return View(datBan);
        }
        public Action BookingHistory()
        {
            if (Session["UserID"] == null)
                return RedirectToAction("Login", "Account");
            int userId = Convert.ToInt32(Session["UserID"]);
            var khachHang = db.KhachHangs.FirstOrDefault(k => k.TaiKhoanID == userId);
            if (khachHang == null)
            {
                TempData["ErrorMessage"] = "Bạn chưa có lịch sử đặt bàn.";
                return RedirectToAction("Index");
            }
            var datBans = db.DatBans
                .Where(d => d.KhachHangID == khachHang.KhachHangID)
                .OrderByDescending(d => d.ThoiGianBatDau)
                .ToList();
            return View(datBans);
        }
    }
}