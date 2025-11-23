using QLNha_Hang.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using System.Data.Entity;

namespace QLNha_Hang.Controllers
{
    public class MenuController : Controller
    {
        private QLNhaHangEntities1 db = new QLNhaHangEntities1();

        public ActionResult Index()
        {
            var menuData = db.LoaiMons
                             .Include("MonAns")
                             .ToList();

            return View(menuData);
        }
        public List<MonAn> LayDanhSachDatMon()
        {
            var lstMon = Session["OrderHistory"] as List<MonAn>;
            if (lstMon == null)
            {
                lstMon = new List<MonAn>();
                Session["OrderHistory"] = lstMon;
            }
            return lstMon;
        }
        public ActionResult OrderHistory()
        {
            if (Session["UserID"] == null)
                return RedirectToAction("Login", "Account");

            int userId = Convert.ToInt32(Session["UserID"]);

            var lst = Session["OrderHistory"] as List<MonAn>;
            if (lst == null)
                lst = new List<MonAn>();
            ViewBag.TongThanhTien = lst.Sum(ct => ct.DonGia);
            return View(lst);
        }
        public ActionResult DatMon(int monID, string returnUrl)
        {            
            var lst = Session["OrderHistory"] as List<MonAn>;
            if (lst == null)
            {
                lst = new List<MonAn>();
                Session["OrderHistory"] = lst;
            }
            var mon = db.MonAns.Find(monID);
            if (mon != null)
            {
                if (!lst.Any(m => m.MonAnID == monID))
                {
                    lst.Add(mon);
                    TempData["ThongBao"] = "Thêm món thành công!";
                }
                else
                {
                    TempData["ThongBao"] = $"Món '{mon.TenMon}' đã có trong danh sách!";
                }
            }
            return RedirectToAction("OrderHistory");
        }
    }
}
