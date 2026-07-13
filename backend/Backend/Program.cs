using System.Text;
using Backend.Configuration;
using Backend.Data;
using Backend.Endpoints;
using Backend.Hubs;
using Backend.Models;
using Backend.Services;
using Backend.Services.OAuth;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
});

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddSingleton<IPasswordHasher<User>, PasswordHasher<User>>();
builder.Services.AddSingleton<IPasswordHasher<Room>, PasswordHasher<Room>>();
builder.Services.AddScoped<ITokenService, TokenService>();

var redisConnectionString = builder.Configuration.GetConnectionString("Redis")!;
builder.Services.AddSingleton<IConnectionMultiplexer>(
    ConnectionMultiplexer.Connect(redisConnectionString));
builder.Services.AddSingleton<GameStateStore>();
builder.Services.AddSingleton<MatchmakingQueueStore>();
builder.Services.AddHostedService<MatchmakingWorker>();

builder.Services
    .AddSignalR()
    .AddJsonProtocol(options =>
    {
        options.PayloadSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.PayloadSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
    })
    .AddStackExchangeRedis(redisConnectionString, options =>
    {
        options.Configuration.ChannelPrefix = RedisChannel.Literal("splendor-online");
    });

builder.Services.AddHttpClient<IOAuthProvider, KakaoOAuthProvider>();
builder.Services.AddHttpClient<IOAuthProvider, NaverOAuthProvider>();
builder.Services.AddHttpClient<IOAuthProvider, GoogleOAuthProvider>();
builder.Services.AddScoped<OAuthProviderResolver>();

var jwtSection = builder.Configuration.GetSection("Jwt");
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSection["Issuer"],
            ValidAudience = jwtSection["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Key"]!)),
        };
        // SignalR 웹소켓 연결은 Authorization 헤더를 못 보내므로 쿼리스트링의 access_token으로 인증한다.
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(accessToken) && context.HttpContext.Request.Path.StartsWithSegments("/hubs"))
                    context.Token = accessToken;
                return Task.CompletedTask;
            },
        };
    });
builder.Services.AddAuthorization();

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("DevFlutterWeb", policy =>
            policy.SetIsOriginAllowed(_ => true)
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials());
    });
}

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    options.SerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "Backend API v1");
    });
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

if (app.Environment.IsDevelopment())
{
    // 로컬/도커 연동 테스트는 마이그레이션을 수동으로 돌리지 않아도 되게
    // 시작 시 자동으로 최신 스키마로 맞춥니다.
    using var scope = app.Services.CreateScope();
    scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.Migrate();
}

var testFrontendPath = Path.Combine(builder.Environment.ContentRootPath, "testFrontend");
if (app.Environment.IsDevelopment() && Directory.Exists(testFrontendPath))
{
    // testFrontend/는 dotnet publish 결과물에 포함되지 않는 수동 테스트용 정적
    // 페이지라, 컨테이너 이미지처럼 없는 환경에서는 조용히 건너뜁니다.
    var testFrontendProvider = new PhysicalFileProvider(testFrontendPath);
    app.UseDefaultFiles(new DefaultFilesOptions
    {
        FileProvider = testFrontendProvider,
        RequestPath = "/test",
    });
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = testFrontendProvider,
        RequestPath = "/test",
    });
}

if (app.Environment.IsDevelopment())
{
    app.UseCors("DevFlutterWeb");
}

app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();
app.MapRoomEndpoints();
app.MapMatchmakingEndpoints();
app.MapLeaderboardEndpoints();
app.MapHub<GameHub>("/hubs/game");

app.Run();
