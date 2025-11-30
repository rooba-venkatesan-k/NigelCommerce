using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace NigelCommerce.ServiceAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly NigelCommerceRepository _repository;
        private readonly IConfiguration _configuration;

        public AuthController(NigelCommerceRepository repository, IConfiguration configuration)
        {
            _repository = repository;
            _configuration = configuration;
        }

        [HttpPost]
        public IActionResult Login([FromBody] LoginRequest loginRequest)
        {
            if (loginRequest == null || string.IsNullOrEmpty(loginRequest.Email) || string.IsNullOrEmpty(loginRequest.Password))
            {
                return BadRequest(new { Message = "Email and password are required." });
            }

            // Validate user credentials
            var user = _repository.ValidateUser(loginRequest.Email, loginRequest.Password);

            if (user == null)
            {
                return Unauthorized(new { Message = "Invalid email or password." });
            }

            // Generate JWT token
            var token = GenerateJwtToken(user);

            return Ok(new
            {
                Token = token,
                Email = user.EmailId,
                Role = user.Role?.RoleName,
                Message = "Login successful"
            });
        }

        private string GenerateJwtToken(User user)
        {
            var key = Encoding.UTF8.GetBytes(_configuration["JWT:Key"]);
            var issuer = _configuration["JWT:Issuer"];
            var audience = _configuration["JWT:Audience"];
            var expiryInHours = int.Parse(_configuration["JWT:ExpiryInHours"]);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.EmailId),
                new Claim(JwtRegisteredClaimNames.Email, user.EmailId),
                new Claim(ClaimTypes.Role, user.Role?.RoleName ?? "User"),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var signingCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256
            );

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(expiryInHours),
                signingCredentials: signingCredentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class LoginRequest
    {
        public string Email { get; set; }
        public string Password { get; set; }
    }
}
