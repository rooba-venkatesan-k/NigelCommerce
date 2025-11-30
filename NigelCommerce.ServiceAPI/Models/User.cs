namespace NigelCommerce.ServiceAPI.Models
{
    public class UserRegisterRequestDTO
    {
        public string EmailId { get; set; }
        public string UserPassword { get; set; }
        public string? Gender { get; set; }
        public DateOnly DOB { get; set; }
        public string? Address { get; set; }
    }
}
