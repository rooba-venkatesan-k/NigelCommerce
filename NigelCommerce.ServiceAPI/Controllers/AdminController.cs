using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NigelCommerce.DAL;
using NigelCommerce.ServiceAPI.Models;

namespace NigelCommerce.ServiceAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class AdminController : Controller
    {
        NigelCommerceRepository repository;

        public AdminController(NigelCommerceRepository repository)
        {
            this.repository = repository;
        }

        [HttpPut]
        [Authorize(Policy = "OwnerPolicy")]
        public IActionResult UpdateRoleForUsers([FromBody] RoleDTO roleDTO)
        {
            if (roleDTO == null || string.IsNullOrEmpty(roleDTO.EmailId) || string.IsNullOrEmpty(roleDTO.Role))
            {
                return BadRequest("EmailId and Role are required.");
            }

            try
            {
                bool status = repository.ChangeUserRole(roleDTO.EmailId, roleDTO.Role);
                if (status)
                    return Ok(new { Message = "Role updated successfully." });

                return NotFound(new { Message = "User not found or role not updated." });
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
