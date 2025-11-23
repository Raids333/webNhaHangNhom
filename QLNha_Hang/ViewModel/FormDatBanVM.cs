using System;
using System.ComponentModel.DataAnnotations;

namespace QLNha_Hang.Models
{
    public class FormDatBanVM
    {
        [Required(ErrorMessage = "Vui lòng nhập họ tên")]
        [Display(Name = "Họ Tên")]
        [StringLength(100, ErrorMessage = "Tên không được quá 100 ký tự")]
        public string HoTen { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập số điện thoại")]
        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        [Display(Name = "Số Điện Thoại")]
        public string SDT { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn thời gian bắt đầu")]
        [Display(Name = "Thời Gian Bắt Đầu")]
        [DataType(DataType.DateTime)]
        public DateTime ThoiGianBatDau { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn thời gian kết thúc dự kiến")]
        [Display(Name = "Thời Gian Kết Thúc")]
        [DataType(DataType.DateTime)]
        public DateTime ThoiGianKetThuc { get; set; }

        [Required]
        [Range(1, 50, ErrorMessage = "Số người từ 1 đến 50")]
        [Display(Name = "Số Lượng Khách")]
        public int SoNguoi { get; set; }

        [Display(Name = "Ghi Chú Yêu Cầu")]
        [StringLength(255)]
        public string GhiChu { get; set; }
    }
}