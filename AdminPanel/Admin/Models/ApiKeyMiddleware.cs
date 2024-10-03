using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace Admin.Models
{
    public class ApiKeyMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly string _apiKey;

        public ApiKeyMiddleware(RequestDelegate next, string apiKey)
        {
            _next = next;
            _apiKey = "Bearer "+apiKey;
        }

        public async Task Invoke(HttpContext context)
        {
            if (context.Request.Path.StartsWithSegments("/api/Staff"))
            {
                if (!context.Request.Headers.TryGetValue("Authorization", out var extractedApiKey))
                {
                    context.Response.StatusCode = 401; // Unauthorized
                    var response = new { StatusCode = 401, Message = "Authorization header missing."};
                    context.Response.ContentType = "application/json";
                    var jsonResponse = JsonSerializer.Serialize(response);
                    await context.Response.WriteAsync(jsonResponse);
                    return;
                }

                if (!string.Equals(extractedApiKey, _apiKey, StringComparison.OrdinalIgnoreCase))
                {
                    context.Response.StatusCode = 403; // Forbidden
                    var response = new { StatusCode = 403, Message = "Unauthorized access. Invalid Server key." };
                    context.Response.ContentType = "application/json";
                    var jsonResponse = JsonSerializer.Serialize(response);
                    await context.Response.WriteAsync(jsonResponse);
                    return;
                }
            }
            await _next(context);

        }
    }

}
