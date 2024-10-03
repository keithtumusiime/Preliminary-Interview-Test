using Admin.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Admin
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

            services.AddDbContext<ApplicationDbContext>(options =>
                options.UseSqlServer(Configuration.GetConnectionString("DefaultConnection")));
            services.AddIdentity<IdentityUser, IdentityRole>(options =>
            {
                // Password settings
                options.Password.RequireDigit = true;                // Require at least one digit
                options.Password.RequireLowercase = true;            // Require at least one lowercase letter
                options.Password.RequireUppercase = true;            // Require at least one uppercase letter
                options.Password.RequireNonAlphanumeric = true;      // Require at least one non-alphanumeric character
                options.Password.RequiredLength = 6;                 // Minimum length
                options.Password.RequiredUniqueChars = 1;           // Minimum unique characters
            })
            .AddEntityFrameworkStores<ApplicationDbContext>()
            .AddDefaultTokenProviders();

            services.AddHttpClient();
            services.AddControllersWithViews();

            // Optional: Add Swagger for API documentation
            services.AddSwaggerGen(c =>
            {
                // Only include API controllers with [ApiController] attribute
                c.DocInclusionPredicate((docName, apiDesc) =>
                {
                    return apiDesc.ActionDescriptor.EndpointMetadata
                        .OfType<ApiControllerAttribute>().Any(); // Filters controllers that have [ApiController]
                });

                c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
                {
                    Title = "DFCU HRIS API",
                    Version = "v1"
                });

                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    In = ParameterLocation.Header,
                    Description = "Please enter the server key into the text field below using the following format: `Bearer {server_key}`",
                    Name = "Authorization",
                    Type = SecuritySchemeType.ApiKey
                });

                // Add a security requirement to the operation
                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    { new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }, new string[] { } }
                });
            });

            services.ConfigureApplicationCookie(options =>
            {
                options.LoginPath = "/Home/Login"; // Set the login path
                options.LogoutPath = "/Home/Logout"; //Logout Path
                options.AccessDeniedPath = "/Home/AccessDenied"; // Optional: Set a custom access denied path
                options.ExpireTimeSpan = TimeSpan.FromMinutes(60);  // Cookie expiration
                options.SlidingExpiration = true;  // Refresh cookie expiration on activity
            });

        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IConfiguration configuration)
        {
            app.UseMiddleware<ApiLoggingMiddleware>();

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
            }

            app.UseStaticFiles();

            app.UseRouting();
            // Use the API key middleware
            app.UseMiddleware<ApiKeyMiddleware>(configuration["AppSettings:ServerKey"]);

            // Add this to ensure authentication middleware is invoked
            app.UseAuthentication();

            // Authorization middleware
            app.UseAuthorization();

            // Use Swagger in the request pipeline
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "DFCU HRIS API V1");
                c.RoutePrefix = "swagger";
            });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Login}");
            });
        }


        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        /*public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseMiddleware<ApiLoggingMiddleware>();
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
            }
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            // Use Swagger in the request pipeline
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {

                c.SwaggerEndpoint("/swagger/v1/swagger.json", "DFCU HRIS API V1");
                c.RoutePrefix = "swagger"; // Set Swagger UI at /swagger instead of the root
            });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Login}");
            });
        }*/
    }
}
