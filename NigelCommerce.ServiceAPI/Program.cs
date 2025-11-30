using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using NigelCommerce.DAL.Models;
using NigelCommerce.DAL;

namespace NigelCommerce
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();

            // Configure JWT Authentication
            var jwtSettings = builder.Configuration["JWT:Key"];
            var key = Encoding.UTF8.GetBytes(jwtSettings);

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = builder.Configuration["JWT:Issuer"],
                    ValidAudience = builder.Configuration["JWT:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(key)
                };
            });

            // Configure Authorization Policies
            builder.Services.AddAuthorization(options =>
            {
                options.AddPolicy("CustomerPolicy", policy => policy.RequireRole("Customer", "Manager", "Owner"));
                options.AddPolicy("ManagerPolicy", policy => policy.RequireRole("Manager", "Owner"));
                options.AddPolicy("OwnerPolicy", policy => policy.RequireRole("Owner"));
            });
            builder.Services.AddSwaggerGen(options => options.CustomSchemaIds(type => type.FullName));


            builder.Services.AddTransient<NigelCommerceDbContext>();
            builder.Services.AddTransient<NigelCommerceRepository>(
               c => new NigelCommerceRepository(c.GetRequiredService<NigelCommerceDbContext>()));

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();
            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
