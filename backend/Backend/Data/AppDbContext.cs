using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<ExternalLogin> ExternalLogins => Set<ExternalLogin>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<RoomPlayer> RoomPlayers => Set<RoomPlayer>();
    public DbSet<Game> Games => Set<Game>();
    public DbSet<GameAction> GameActions => Set<GameAction>();
    public DbSet<PlayerRanking> PlayerRankings => Set<PlayerRanking>();
    public DbSet<GamePlayerResult> GamePlayerResults => Set<GamePlayerResult>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<ExternalLogin>()
            .HasIndex(el => new { el.Provider, el.ProviderUserId })
            .IsUnique();

        modelBuilder.Entity<ExternalLogin>()
            .HasOne(el => el.User)
            .WithMany(u => u.ExternalLogins)
            .HasForeignKey(el => el.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RefreshToken>()
            .HasIndex(rt => rt.TokenHash)
            .IsUnique();

        modelBuilder.Entity<RefreshToken>()
            .HasOne(rt => rt.User)
            .WithMany()
            .HasForeignKey(rt => rt.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Room>()
            .HasOne(r => r.Host)
            .WithMany()
            .HasForeignKey(r => r.HostId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<RoomPlayer>()
            .HasOne(rp => rp.Room)
            .WithMany(r => r.Players)
            .HasForeignKey(rp => rp.RoomId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RoomPlayer>()
            .HasOne(rp => rp.User)
            .WithMany()
            .HasForeignKey(rp => rp.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RoomPlayer>()
            .HasIndex(rp => new { rp.RoomId, rp.UserId })
            .IsUnique();

        modelBuilder.Entity<Game>()
            .HasOne(g => g.Room)
            .WithOne(r => r.Game)
            .HasForeignKey<Game>(g => g.RoomId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GameAction>()
            .HasOne(a => a.Game)
            .WithMany(g => g.Actions)
            .HasForeignKey(a => a.GameId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GameAction>()
            .HasIndex(a => new { a.GameId, a.Sequence })
            .IsUnique();

        modelBuilder.Entity<PlayerRanking>()
            .HasOne(pr => pr.User)
            .WithMany()
            .HasForeignKey(pr => pr.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<PlayerRanking>()
            .HasIndex(pr => new { pr.UserId, pr.PlayerCount })
            .IsUnique();

        modelBuilder.Entity<PlayerRanking>()
            .HasIndex(pr => new { pr.PlayerCount, pr.Mmr });

        modelBuilder.Entity<GamePlayerResult>()
            .HasOne(r => r.Game)
            .WithMany()
            .HasForeignKey(r => r.GameId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GamePlayerResult>()
            .HasOne(r => r.User)
            .WithMany()
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GamePlayerResult>()
            .HasIndex(r => new { r.GameId, r.UserId })
            .IsUnique();
    }
}
