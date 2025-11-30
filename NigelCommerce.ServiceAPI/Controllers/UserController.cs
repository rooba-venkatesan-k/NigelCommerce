using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;
using NigelCommerce.ServiceAPI.Models;

namespace NigelCommerce.ServiceAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly NigelCommerceRepository _repository;

        public UserController(NigelCommerceRepository repository)
        {
            _repository = repository;
        }

        [HttpPost]
        public IActionResult NewUserRegistry([FromBody] UserRegisterRequestDTO request)
        {
            if (request == null || string.IsNullOrEmpty(request.EmailId) || string.IsNullOrEmpty(request.UserPassword))
            {
                return BadRequest(new { Message = "Email and password are required." });
            }

            var user = new User
            {
                EmailId = request.EmailId,
                UserPassword = request.UserPassword,
                Gender = request.Gender ?? "M",
                DOB = request.DOB,
                Address = request.Address ?? string.Empty,
                RoleId = 3 // default to Customer
            };

            var added = _repository.NewUserRegistraion(user);
            if (!added)
            {
                return Conflict(new { Message = "User already exists or could not be created." });
            }

            return Ok(new { Message = "Registration successful", Email = user.EmailId });
        }


        [HttpGet]
        [Authorize(Policy = "OwnerPolicy")]
        public IActionResult DisplayAllUsers()
        {
            var users = _repository.GetAllUsers();

            if (users == null && users.Count == 0)
            {
                return Conflict(new { Message = "No user record is found" });
            }

            return Ok(users);
        }
    }

}
