using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task Invoke(HttpContext context)
    {
        var request = context.Request;
        var method = request.Method;
        var path = request.Path + request.QueryString;
        var ip = context.Connection.RemoteIpAddress?.ToString();
        var userAgent = request.Headers["User-Agent"].ToString();

        string body = "";
        if (method == "POST" || method == "PUT")
        {
            request.EnableBuffering(); // Body를 여러 번 읽을 수 있도록
            using var reader = new StreamReader(request.Body, leaveOpen: true);
            body = await reader.ReadToEndAsync();
            request.Body.Position = 0; // 다시 읽을 수 있도록 포지션 초기화
        }

        var startTime = DateTime.UtcNow;
        var originalBody = context.Response.Body;

        using var memoryStream = new MemoryStream();
        context.Response.Body = memoryStream;

        await _next(context);

        memoryStream.Position = 0;
        var responseBody = await new StreamReader(memoryStream).ReadToEndAsync();
        memoryStream.Position = 0;
        await memoryStream.CopyToAsync(originalBody);

        var statusCode = context.Response.StatusCode;

        var logObject = new
        {
            Timestamp = startTime.ToString("o"),
            HttpMethod = method,
            RequestPath = path,
            ClientIP = ip,
            UserAgent = userAgent,
            Body = (method == "GET") ? null : body,
            StatusCode = statusCode
        };

        _logger.LogInformation("API 요청 로그: {@log}", logObject);
    }
}