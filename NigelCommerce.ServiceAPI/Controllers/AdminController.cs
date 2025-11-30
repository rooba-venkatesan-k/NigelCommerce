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
        public bool UpdateRoleForUsers(RoleDTO roleDTO)
        {
            bool status = false;
            try
            {

                status = repository.ChangeUserRole(roleDTO.EmailId, roleDTO.Role);
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
    }
}
