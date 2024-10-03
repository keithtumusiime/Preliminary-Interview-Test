using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System;

namespace Admin.Models
{

    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<StaffMember> StaffMembers { get; set; }
        public DbSet<ApiRequestLog> ApiRequestLogs { get; set; }
    }

    public class StaffMember
    {
        public int Id { get; set; }
        public string EmployeeNumber { get; set; }
        public string Surname { get; set; }
        public string OtherNames { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string IDPhoto { get; set; } // Base64 encoded string
        public string UniqueCode { get; set; } // Unique 10-digit code
        public DateTime DateRegistered { get; set; }
        public DateTime DateUpdated { get; set; } 
    }

    public class ApiRequestLog
    {
        public int Id { get; set; }
        public string Endpoint { get; set; }
        public string RequestBody { get; set; }
        public string ResponseBody { get; set; }
        public DateTime Timestamp { get; set; }
        public int StatusCode { get; set; }
    }

}
