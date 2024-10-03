using Admin.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        [HttpGet("metrics")]
        public IActionResult GetMetrics()
        {
            var metrics = ApiLoggingMiddleware.GetMetrics();
            return Ok(new
            {
                TotalRequests = metrics.Total,
                SuccessfulRequests = metrics.Successful,
                FailedRequests = metrics.Failed,
                AverageResponseTime = metrics.AverageResponseTime // Include average response time
            });
        }
    }

}
