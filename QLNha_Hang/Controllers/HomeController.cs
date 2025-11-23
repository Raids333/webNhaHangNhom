using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using QLNha_Hang.Models;

namespace QLNha_Hang.Controllers
{
    public class HomeController : Controller
    {
        private QLNhaHangEntities1 db = new QLNhaHangEntities1();

        public ActionResult Index()
        {
            var monAnList = db.MonAns.Include("LoaiMon")
                .OrderBy(m => m.TenMon)
                .ToList();

            return View(monAnList);
        }

    }
}