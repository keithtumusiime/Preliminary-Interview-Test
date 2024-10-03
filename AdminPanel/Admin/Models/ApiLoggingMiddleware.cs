using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Admin.Models
{
    public class ApiLoggingMiddleware
    {
        private readonly RequestDelegate _next;
        private static int _totalRequests = 0;
        private static int _successfulRequests = 0;
        private static int _failedRequests = 0;
        private static long _totalResponseTime = 0; // To accumulate response times

        public ApiLoggingMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            // Check if the request is for the specific API controller
            if (context.Request.Path.StartsWithSegments("/api/Staff"))
            {
                Interlocked.Increment(ref _totalRequests);
                var stopwatch = Stopwatch.StartNew(); // Start measuring time

                try
                {
                    await _next(context); // Process the request
                    if (context.Response.StatusCode < 400)
                    {
                        Interlocked.Increment(ref _successfulRequests);
                    }
                    else
                    {
                        Interlocked.Increment(ref _failedRequests);
                    }
                }
                catch
                {
                    Interlocked.Increment(ref _failedRequests);
                    throw; // Re-throw the exception to maintain normal error handling
                }
                finally
                {
                    stopwatch.Stop(); // Stop measuring time
                    Interlocked.Add(ref _totalResponseTime, stopwatch.ElapsedMilliseconds); // Add to total response time
                }
            }
            else
            {
                await _next(context);
            }
        }

        public static (int Total, int Successful, int Failed, long AverageResponseTime) GetMetrics()
        {
            var averageResponseTime = _totalRequests > 0 ? _totalResponseTime / _totalRequests : 0;
            return (_totalRequests, _successfulRequests, _failedRequests, averageResponseTime);
        }
    }

}
