using Microsoft.AspNetCore.Authentication.JwtBearer;
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

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

IConfiguration configuration = builder.Configuration;

string  cognitoUserPoolId = configuration["Cognito:UserPoolId"];
string  cognitoAppClientId = configuration["Cognito:AppClientId"];

// Serilog 설정 (appsettings.json에서 설정을 읽어옴)
builder.Host.UseSerilog((context, services, configuration) =>
{
    configuration.ReadFrom.Configuration(context.Configuration); // appsettings.json에서 설정을 읽어옴
});

//cognito인증설정
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://cognito-idp.ap-northeast-2.amazonaws.com/YOUR_USER_POOL_ID";
        options.Audience = "YOUR_APP_CLIENT_ID";
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true
        };
    });

// CORS 정책 설정
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()  // 모든 도메인에서 요청 허용
                  .AllowAnyHeader()  // 모든 헤더 허용
                  .AllowAnyMethod(); // 모든 HTTP 메서드 허용
        });
});

builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseMySql(
    builder.Configuration.GetConnectionString("UserDbConnection"),
    new MySqlServerVersion(new Version(8, 0, 40))
));


builder.Services.AddDbContext<GameDbContext>(options =>
    options.UseMySql(
    builder.Configuration.GetConnectionString("GameDbConnection"),
    new MySqlServerVersion(new Version(8, 0, 40))
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

app.Run();

