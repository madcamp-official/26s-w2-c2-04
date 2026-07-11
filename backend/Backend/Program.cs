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

app.UseHttpsRedirection();

if (app.Environment.IsDevelopment())
{
    var testFrontendProvider = new PhysicalFileProvider(
        Path.Combine(builder.Environment.ContentRootPath, "testFrontend"));
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

app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();
app.MapRoomEndpoints();
app.MapHub<GameHub>("/hubs/game");

app.Run();
