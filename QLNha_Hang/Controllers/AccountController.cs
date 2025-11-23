using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using QLNha_Hang.Models;
using QLNha_Hang.Utils;
using System.Transactions;

namespace QLNha_Hang.Controllers
{
    public class AccountController : Controller
    {
        private QLNhaHangEntities1 db = new QLNhaHangEntities1();
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult HandleLogin(string username, string password)
        {
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ViewBag.ErrorMessage = "Vui lòng nhập đầy đủ thông tin!";
                return View("Login");
            }

            string hashedPassword = SecurityHelper.HashPassword(password);

            var user = db.TaiKhoans.FirstOrDefault(t =>
                t.TenDangNhap == username &&
                t.MatKhau == hashedPassword && 
                t.HoatDong == true
            );

            if (user != null)
            {
                Session["UserName"] = user.TenDangNhap;
                Session["UserID"] = user.TaiKhoanID;
                var role = user.TaiKhoan_VaiTro.FirstOrDefault();
                if (role != null)
                {
                    Session["UserRole"] = role.VaiTro.TenVaiTro;
                }

                var khachHang = db.KhachHangs.FirstOrDefault(k => k.TaiKhoanID == user.TaiKhoanID);
                if (khachHang != null)
                {
                    Session["KhachHangID"] = khachHang.KhachHangID;
                    Session["FullName"] = khachHang.HoTen;
                }
                else
                {
                    var nhanVien = db.NhanViens.FirstOrDefault(nv => nv.TaiKhoanID == user.TaiKhoanID);
                    if (nhanVien != null)
                    {
                        Session["NhanVienID"] = nhanVien.NhanVienID;
                        Session["FullName"] = nhanVien.HoTen;
                    }
                }

                return RedirectToAction("Index", "Home");
            }

            ViewBag.ErrorMessage = "Tên đăng nhập hoặc mật khẩu không đúng!";
            return View("Login");
        }

        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(string username, string email, string phone, string password, string confirmPassword)
        {
            if (password != confirmPassword)
            {
                ViewBag.ErrorMessage = "Mật khẩu xác nhận không khớp!";
                return View();
            }
            if (db.TaiKhoans.Any(t => t.TenDangNhap == username))
            {
                ViewBag.ErrorMessage = "Tên đăng nhập đã tồn tại!";
                return View();
            }
            if (db.TaiKhoans.Any(t => t.Email == email))
            {
                ViewBag.ErrorMessage = "Email đã được sử dụng!";
                return View();
            }
            if (db.TaiKhoans.Any(t => t.SDT == phone))
            {
                ViewBag.ErrorMessage = "Số điện thoại đã được sử dụng cho tài khoản khác!";
                return View();
            }

            using (var scope = new TransactionScope())
            {
                try
                {
                    var newUser = new TaiKhoan
                    {
                        TenDangNhap = username,
                        MatKhau = SecurityHelper.HashPassword(password),
                        Email = email,
                        SDT = phone,
                        HoatDong = true,
                        NgayTao = DateTime.Now
                    };
                    db.TaiKhoans.Add(newUser);
                    db.SaveChanges(); 

                    var defaultRole = db.VaiTroes.FirstOrDefault(v => v.TenVaiTro == "Khách Hàng");
                    if (defaultRole == null) throw new Exception("Không tìm thấy quyền Khách hàng");

                    var userRole = new TaiKhoan_VaiTro
                    {
                        TaiKhoanID = newUser.TaiKhoanID,
                        VaiTroID = defaultRole.VaiTroID
                    };
                    db.TaiKhoan_VaiTro.Add(userRole);

                    var newCustomer = new KhachHang
                    {
                        HoTen = username,
                        SDT = phone,
                        TaiKhoanID = newUser.TaiKhoanID,
                        DiemTichLuy = 0
                    };
                    db.KhachHangs.Add(newCustomer);


                    db.SaveChanges();

                    scope.Complete();

                    TempData["SuccessMessage"] = "Đăng ký thành công! Mời bạn đăng nhập.";
                    return RedirectToAction("Login");
                }
                catch (Exception ex)
                {
                    ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                    return View();
                }
            }
        }

        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Login");

        }
    }
}