using Amazon;
using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using MyApi.Data;
using MyApi.Services;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using Serilog;
using System;
using System.Collections.Concurrent;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;


var configBuilder = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

IConfiguration configuration = configBuilder.Build(); // IConfiguration 생성

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, services, configuration) =>
{
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .WriteTo.Console(new Serilog.Formatting.Json.JsonFormatter())
        .WriteTo.File(new Serilog.Formatting.Json.JsonFormatter(), "/var/log/api/app.log", rollingInterval: RollingInterval.Day);
});

// 환경 변수에서 데이터베이스 및 Cognito 정보 가져오기
// string agw_url = Environment.GetEnvironmentVariable("AGW_URL") ??;
string dbEndpoint = Environment.GetEnvironmentVariable("DB_ENDPOINT") ?? configuration["ConnectionStrings:UserDbConnection"];
string dbUsername = Environment.GetEnvironmentVariable("DB_USERNAME") ?? "root";
string dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "";
string cognitoUserPoolId = Environment.GetEnvironmentVariable("COGNITO_USER_POOL") ?? configuration["Cognito:UserPoolId"];
string cognitoAppClientId = Environment.GetEnvironmentVariable("COGNITO_APP_CLIENT") ?? configuration["Cognito:AppClientId"];

string bucketName = Environment.GetEnvironmentVariable("S3_LOG_BUCKET");

if (string.IsNullOrEmpty(bucketName))
{
    Console.WriteLine("환경 변수 'S3_LOG_BUCKET'이 설정되지 않았습니다.");
    return;
}

// builder.Configuration에 적용
builder.Configuration["Kestrel:Endpoints:Http:Url"] = "http://127.0.0.1:5000";
builder.Configuration["ConnectionStrings:UserDbConnection"] = $"Server={dbEndpoint};Database=userDB;User={dbUsername};Password={dbPassword};SslMode=Preferred;";
builder.Configuration["ConnectionStrings:GameDbConnection"] = $"Server={dbEndpoint};Database=gameDB;User={dbUsername};Password={dbPassword};SslMode=Preferred;";
builder.Configuration["ConnectionStrings:ChatDbConnection"] = $"Server={dbEndpoint};Database=chatDB;User={dbUsername};Password={dbPassword};SslMode=Preferred;";
builder.Configuration["Cognito:UserPoolId"] = cognitoUserPoolId;
builder.Configuration["Cognito:AppClientId"] = cognitoAppClientId;

//cognito인증설정
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://cognito-idp.ap-northeast-2.amazonaws.com/" + cognitoUserPoolId;
        options.Audience = cognitoAppClientId;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ClockSkew = TimeSpan.FromSeconds(5) // 토큰 만료 유예시간 단축
        };
    });

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.JsonSerializerOptions.WriteIndented = true;
});

//CORS 정책 설정
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(origin =>
        {
            if (origin.StartsWith("http://192.168.0.")) return true;
            if (origin == "http://localhost:3000") return true;
            if (origin == "http://nat.1bean.shop") return true;
            if (origin.Contains("www.1bean.shop")) return true;
            if (origin.Contains("backend.internal")) return true;
            // 필요하다면 더 추가
            return false;
        })
        .WithMethods("GET", "POST")
        .AllowAnyHeader()
        .AllowCredentials();
    });
});

builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("UserDbConnection"),
        new MySqlServerVersion(new Version(8, 0, 40)),
        mySqlOptions => mySqlOptions.EnableRetryOnFailure(5)
));


builder.Services.AddDbContext<GameDbContext>(options =>
options.UseMySql(
        builder.Configuration.GetConnectionString("GameDbConnection"),
        new MySqlServerVersion(new Version(8, 0, 40)),
        mySqlOptions => mySqlOptions.EnableRetryOnFailure(5)
));

builder.Services.AddDbContext<ChatDbContext>(options =>
options.UseMySql(
        builder.Configuration.GetConnectionString("ChatDbConnection"),
        new MySqlServerVersion(new Version(8, 0, 40)),
        mySqlOptions => mySqlOptions.EnableRetryOnFailure(5)
));

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddScoped<CognitoService>();
builder.Services.AddScoped<IPasswordHasher, BcryptPasswordHasher>();

WebApplication app = builder.Build();

// CORS 미들웨어 추가
app.UseRouting();
app.UseCors("AllowAll");
app.Use(async (context, next) =>
{
    try
    {
        var culture = context.Request.Headers["Accept-Language"].ToString();
        if (!string.IsNullOrEmpty(culture))
        {
            var parsedCulture = new CultureInfo(culture);
            CultureInfo.CurrentCulture = parsedCulture;
            CultureInfo.CurrentUICulture = parsedCulture;
        }
    }
    catch (CultureNotFoundException)
    {

    }

    await next();
});
app.UseMiddleware<RequestLoggingMiddleware>();
// Configure the HTTP request pipeline.
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

string directoryPath = "/var/log/api/";
string s3Folder = "API_Server/DotNet/";

using var s3Client = new AmazonS3Client(Amazon.RegionEndpoint.APNortheast2);
TransferUtility fileTransferUtility = new TransferUtility(s3Client);

var watcher = new FileSystemWatcher(directoryPath)
{
    NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite,
    Filter = "*.log",
    EnableRaisingEvents = true
};

ConcurrentQueue<string> uploadQueue = new ConcurrentQueue<string>();
ConcurrentDictionary<string, bool> processedFiles = new ConcurrentDictionary<string, bool>();

watcher.Created += (sender, e) => EnqueueFile(e.FullPath);

void EnqueueFile(string filePath)
{
    if (!processedFiles.ContainsKey(filePath))
    {
        uploadQueue.Enqueue(filePath);
        processedFiles[filePath] = true;
    }
}

Task.Run(async () =>
{
    while (true)
    {
        if (uploadQueue.TryDequeue(out string filePath))
        {
            await UploadToS3(filePath);
        }
        await Task.Delay(5000);
    }
});

async Task UploadToS3(string filePath, string httpMethod = "PUT", string requestBody = "", string queryString = "")
{
    string bucketName = Environment.GetEnvironmentVariable("S3_LOG_BUCKET") ?? "my-log-bucket";

    string fileName = Path.GetFileNameWithoutExtension(filePath);
    string extension = Path.GetExtension(filePath);
    var koreaTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"));

    string timestamp = koreaTime.ToString("yyyyMMdd-HHmmss-fff");
    string uniqueFileName = $"{fileName}-{timestamp}{extension}";
    string keyName = $"{s3Folder}{uniqueFileName}";

    string eventTime = koreaTime.ToString("yyyy-MM-ddTHH:mm:ss.fffK");
    string awsRegion = "ap-northeast-2";
    string eventName = "UploadLog";
    string eventSource = "DotNetAPIServer";
    string sourceIPAddress = GetLocalIPAddress();
    string userAgent = "dotnet-uploader/1.0";

    try
    {
        await fileTransferUtility.UploadAsync(filePath, bucketName, keyName);

        object requestParams;

        if (httpMethod.ToUpper() == "POST")
        {
            requestParams = new
            {
                httpMethod,
                requestPath = "/upload",
                message = requestBody,
                statusCode = 200
            };
        }
        else
        {
            requestParams = new
            {
                httpMethod,
                requestPath = "/upload",
                queryString,
                statusCode = 200
            };
        }

        var logObject = new
        {
            Records = new[]
            {
                new
                {
                    eventSource,
                    awsRegion,
                    eventTime,
                    eventName,
                    requestParameters = requestParams,
                    sourceIPAddress,
                    userAgent
                }
            }
        };

        string jsonLog = JsonSerializer.Serialize(logObject, new JsonSerializerOptions { WriteIndented = false });
        Log.Information(jsonLog);

        processedFiles.TryRemove(filePath, out _);
    }
    catch (Exception ex)
    {
        Log.Error(ex, "업로드 실패: {FilePath}", filePath);
    }
}

string GetLocalIPAddress()
{
    try
    {
        var host = Dns.GetHostEntry(Dns.GetHostName());
        foreach (var ip in host.AddressList)
        {
            if (ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                return ip.ToString();
        }
    }
    catch
    {
        // ignore
    }
    return "unknown";
}

try
{
    app.Run();
}
finally
{
    Log.CloseAndFlush();
}