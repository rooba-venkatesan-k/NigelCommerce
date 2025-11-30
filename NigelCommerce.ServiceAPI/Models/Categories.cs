using System.ComponentModel.DataAnnotations;

namespace NigelCommerce.ServiceAPI.Models
{
    public class Categories
    {
        public byte CategoryId { get; set; }

        [Required]
        public string CategoryName { get; set; }
    }
}
