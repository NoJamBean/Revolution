using Amazon;
using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using MyApi.Data;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using Serilog;
using System;
using System.IO;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Net;

var configBuilder = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

IConfiguration configuration = configBuilder.Build(); // IConfiguration 생성

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, services, loggerConfiguration) =>
{
    loggerConfiguration
        .ReadFrom.Configuration(context.Configuration)
        .WriteTo.Console(outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss} {Level:u3}] {Message}{NewLine}{Exception}")
        .WriteTo.File("/var/log/api/app.log", rollingInterval: RollingInterval.Day);
});

// 환경 변수에서 데이터베이스 및 Cognito 정보 가져오기
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

// CORS 정책 설정
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()   // 모든 도메인에서 요청 허용
                  .AllowAnyHeader()   // 모든 헤더 허용
                  .AllowAnyMethod(); // 모든 HTTP 메서드 허용
        });
});

builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseMySql(
        configuration.GetConnectionString("UserDbConnection"),
        new MySqlServerVersion(new Version(8, 0, 40)),
        mySqlOptions => mySqlOptions.EnableRetryOnFailure(5)
));


builder.Services.AddDbContext<GameDbContext>(options =>
options.UseMySql(
        configuration.GetConnectionString("GameDbConnection"),
        new MySqlServerVersion(new Version(8, 0, 40)),
        mySqlOptions => mySqlOptions.EnableRetryOnFailure(5)
));

// Add services to the container.
builder.Services.AddControllers();

WebApplication app = builder.Build();

// CORS 미들웨어 추가
app.UseRouting();
app.UseCors("AllowAll");

// Configure the HTTP request pipeline.
app.UseAuthorization();

app.MapControllers();

string directoryPath = "/var/log/api/";
string s3Folder = "DotNet/";

using var s3Client = new AmazonS3Client(Amazon.RegionEndpoint.APNortheast2);
var fileTransferUtility = new TransferUtility(s3Client);

var watcher = new FileSystemWatcher(directoryPath)
{
    NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite, // 파일 생성 또는 수정 감지
    Filter = "*.log", // .log 파일만 감지
    EnableRaisingEvents = true
};


ConcurrentQueue<string> uploadQueue = new ConcurrentQueue<string>();

watcher.Created += (sender, e) => uploadQueue.Enqueue(e.FullPath);
watcher.Changed += (sender, e) => uploadQueue.Enqueue(e.FullPath);

Task.Run(async () =>
{
    while (true)
    {
        if (uploadQueue.TryDequeue(out string filePath))
        {
            await UploadToS3(filePath);
        }
        await Task.Delay(5000); // 5초마다 체크
    }
});

try
{
    app.Run();
}
finally
{
    Log.CloseAndFlush();
}