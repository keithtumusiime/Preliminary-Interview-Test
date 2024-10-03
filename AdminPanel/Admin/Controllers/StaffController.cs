using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using Admin.Models;
using System.Text.Json;
using System.Linq;

namespace Admin.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StaffController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public StaffController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Staff Registration
        [HttpPost("register")]
        public async Task<IActionResult> RegisterStaff([FromBody] StaffRegistrationModel model)
        {
            if (!ModelState.IsValid)
            {
                await LogApiRequest("POST register", model, new { StatusCode = 400, Message = "Invalid data." }, 400);
                return BadRequest(new { StatusCode = 400, Message = "Invalid data." });
            }

            if (!IsValidUniqueCode(model.UniqueCode))
            {
                await LogApiRequest("POST register", model, new { StatusCode = 401, Message = "Invalid unique code." }, 401);
                return Unauthorized(new { StatusCode = 401, Message = "Invalid unique code." });
            }

            string employeeNumber;

            using (var transaction = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    employeeNumber = await GenerateEmployeeNumber();

                    var newStaff = new StaffMember
                    {
                        EmployeeNumber = employeeNumber,
                        Surname = model.Surname,
                        OtherNames = model.OtherNames,
                        DateOfBirth = model.DateOfBirth,
                        IDPhoto = model.IDPhoto,
                        UniqueCode = model.UniqueCode,
                        DateRegistered = DateTime.Now
                    };

                    _context.StaffMembers.Add(newStaff);
                    await _context.SaveChangesAsync();

                    await transaction.CommitAsync();
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    return StatusCode(500, new { StatusCode = 500, Message = "An error occurred while registering staff.", Error = ex.Message });
                }
            }

            var response = new { StatusCode = 200, Message = "Registration successful", EmployeeNumber = employeeNumber };
            await LogApiRequest("POST register", model, response, 200);
            return Ok(response);
        }

        // Staff Retrieval
        [HttpGet]
        public async Task<IActionResult> GetStaff(string employeeNumber = null)
        {
            if (string.IsNullOrEmpty(employeeNumber))
            {
                var allStaff = await _context.StaffMembers.ToListAsync();
                var response = new { StatusCode = 200, Data = allStaff };
                await LogApiRequest("GET staff/", null, response, 200);
                return Ok(response);
            }
            else
            {
                var staff = await _context.StaffMembers.FirstOrDefaultAsync(s => s.EmployeeNumber == employeeNumber);
                if (staff == null)
                {
                    var response = new { StatusCode = 404, Message = "Staff not found." };
                    await LogApiRequest($"GET staff/{employeeNumber}", null, response, 404);
                    return NotFound(response);
                }
                var responseData = new { StatusCode = 200, Data = staff };
                await LogApiRequest($"GET staff/{employeeNumber}", null, responseData, 200);
                return  Ok(responseData);
            }
        }

        // Staff Update
        [HttpPut("update")]
        public async Task<IActionResult> UpdateStaff([FromBody] StaffUpdateModel model)
        {
            if (!ModelState.IsValid)
            {
                await LogApiRequest($"PUT update/", model, new { StatusCode = 400, Message = "Invalid data." }, 400);
                return BadRequest(new { StatusCode = 400, Message = "Invalid data." });
            }

            var staff = await _context.StaffMembers.FirstOrDefaultAsync(s => s.EmployeeNumber == model.EmpNo);
            if (staff == null)
            {
                await LogApiRequest($"PUT update/", model, new { StatusCode = 404, Message = "Staff not found." }, 404);
                return NotFound(new { StatusCode = 404, Message = "Staff not found." });
            }

            staff.DateOfBirth = model.DateOfBirth;
            staff.IDPhoto = model.IDPhoto;
            staff.DateUpdated = DateTime.Now;

            await _context.SaveChangesAsync();

            var response = new { StatusCode = 200, Message = "Staff details updated successfully." };
            await LogApiRequest($"PUT update/", model, response, 200);
            return Ok(response);
        }

        // Helper methods
        private bool IsValidUniqueCode(string uniqueCode)
        {
            return uniqueCode.Length == 10 && !_context.StaffMembers.Any(s => s.UniqueCode == uniqueCode);
        }

        private async Task<string> GenerateEmployeeNumber()
        {
            var lastEmployee = await _context.StaffMembers
                .OrderByDescending(s => s.Id) // Assuming Id is the primary key
                .FirstOrDefaultAsync();

            int newId = lastEmployee != null ? int.Parse(lastEmployee.EmployeeNumber.Substring(4)) + 1 : 1; // Extracting the number part and incrementing
            return $"DFCU{newId:D4}"; // Format as DFCU0001, DFCU0002, etc.
        }

        private async Task LogApiRequest(string endpoint, object requestBody, object responseBody, int statusCode)
        {
            var log = new ApiRequestLog
            {
                Endpoint = endpoint,
                RequestBody = requestBody != null ? JsonSerializer.Serialize(requestBody) : null,
                ResponseBody = JsonSerializer.Serialize(responseBody),
                Timestamp = DateTime.UtcNow,
                StatusCode = statusCode
            };
            _context.ApiRequestLogs.Add(log);
            await _context.SaveChangesAsync();
        }
    }

    // Models
    public class StaffRegistrationModel
    {
        [Required]
        public string Surname { get; set; }

        [Required]
        public string OtherNames { get; set; }

        [Required]
        [DataType(DataType.Date)]
        public DateTime DateOfBirth { get; set; }

        public string IDPhoto { get; set; } // Base64 encoded string

        [Required]
        public string UniqueCode { get; set; }
    }

    public class StaffUpdateModel
    {
        [Required]
        public string EmpNo { get; set; }
        [DataType(DataType.Date)]
        public DateTime DateOfBirth { get; set; }
        //public DateTime DateUpdated  { get; set; }
        
        public string IDPhoto { get; set; } // Base64 encoded string
    }

}
