using System.Text;
using Backend.Configuration;
using Backend.Data;
using Backend.Dtos;
using Backend.Endpoints;
using Backend.Hubs;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;

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
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddSignalR();

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
app.MapHub<RoomHub>("/hubs/room");

app.MapGet("/users", async (AppDbContext db) =>
    await db.Users
        .Select(u => new UserResponse(u.Id, u.Email, u.CreatedAt))
        .ToListAsync())
    .RequireAuthorization()
    .WithName("GetUsers");

app.Run();
