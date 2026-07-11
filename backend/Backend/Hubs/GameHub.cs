using System.Text.Json;
using Backend.Data;
using Backend.Extensions;
using Backend.GameLogic;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Hubs;

[Authorize]
public class GameHub(GameStateStore stateStore, AppDbContext db) : Hub
{
    public async Task JoinRoom(int roomId)
    {
        var userId = Context.User!.GetUserId();
        var state = await stateStore.LoadAsync(roomId) ?? throw new HubException("GAME_NOT_FOUND");
        if (!state.Players.ContainsKey(userId))
            throw new HubException("NOT_A_MEMBER");

        await Groups.AddToGroupAsync(Context.ConnectionId, GroupName(roomId));
        await Clients.Caller.SendAsync("StateSync", BuildFullSync(state));
        await Clients.OthersInGroup(GroupName(roomId)).SendAsync("PlayerJoined", new { userId });
    }

    public async Task LeaveRoom(int roomId)
    {
        var userId = Context.User!.GetUserId();
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupName(roomId));
        await Clients.OthersInGroup(GroupName(roomId)).SendAsync("PlayerLeft", new { userId });
    }

    public async Task StartGame(int roomId)
    {
        var userId = Context.User!.GetUserId();
        var room = await db.Rooms.FirstOrDefaultAsync(r => r.Id == roomId)
            ?? throw new HubException("ROOM_NOT_FOUND");
        if (room.HostId != userId)
            throw new HubException("ROOM_NOT_HOST");

        var state = await stateStore.LoadAsync(roomId)
            ?? throw new HubException("ROOM_NOT_STARTED");

        await Clients.Group(GroupName(roomId)).SendAsync("StateSync", BuildFullSync(state));
    }

    public async Task TakeTokens(int roomId, List<string> gems)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "TakeTokens", new { gems },
            state => GameEngine.TakeTokens(state, userId, ParseGems(gems)));
    }

    public async Task PurchaseCard(int roomId, string cardId, string source)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "PurchaseCard", new { cardId, source },
            state => GameEngine.PurchaseCard(state, userId, cardId, source));
    }

    public async Task ReserveCard(int roomId, string? cardId, int? tier)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "ReserveCard", new { cardId, tier },
            state => GameEngine.ReserveCard(state, userId, cardId, tier));
    }

    public async Task DiscardTokens(int roomId, List<string> gems)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "DiscardTokens", new { gems },
            state => GameEngine.DiscardTokens(state, userId, ParseGems(gems)));
    }

    public async Task ClaimNoble(int roomId, string nobleId)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "ClaimNoble", new { nobleId },
            state => GameEngine.ClaimNoble(state, userId, nobleId));
    }

    public async Task RequestResync(int roomId, int lastSequence)
    {
        var state = await stateStore.LoadAsync(roomId) ?? throw new HubException("GAME_NOT_FOUND");
        await Clients.Caller.SendAsync("StateSync", BuildFullSync(state));
    }

    private async Task HandleActionAsync(
        int roomId, int userId, string actionType, object payload, Func<GameState, ActionOutcome> action)
    {
        await using var gameLock = await stateStore.AcquireLockAsync(roomId);

        var state = await stateStore.LoadAsync(roomId) ?? throw new HubException("GAME_NOT_FOUND");
        var previousPlayerId = state.CurrentPlayerId;

        ActionOutcome outcome;
        try
        {
            outcome = action(state);
        }
        catch (GameRuleException ex)
        {
            throw new HubException(ex.Code);
        }

        await stateStore.SaveAsync(roomId, state);

        var game = await db.Games.FirstAsync(g => g.RoomId == roomId);
        db.GameActions.Add(new GameAction
        {
            GameId = game.Id,
            Sequence = state.Sequence,
            TurnNumber = state.TurnNumber,
            PlayerId = userId,
            ActionType = actionType,
            PayloadJson = JsonSerializer.Serialize(payload),
        });

        var group = Clients.Group(GroupName(roomId));
        await group.SendAsync("StateSync", BuildFullSync(state));

        foreach (var nobleId in outcome.AutoAwardedNobleIds)
            await group.SendAsync("NobleAwarded", new { playerId = userId, nobleId });

        if (outcome.NobleChoiceCandidateIds.Count > 0)
            await Clients.Caller.SendAsync("NobleChoiceRequired", new { playerId = userId, candidateNobleIds = outcome.NobleChoiceCandidateIds });

        if (outcome.FinalRoundTriggered)
            await group.SendAsync("FinalRoundTriggered", new { triggeredBy = userId, lastTurnPlayerId = state.LastTurnPlayerId });

        if (outcome.GameOver)
        {
            game.Status = GameStatus.Finished;
            game.WinnerId = outcome.WinnerId;
            game.FinishedAt = DateTime.UtcNow;
            game.StateJson = JsonSerializer.Serialize(state);

            var room = await db.Rooms.FirstAsync(r => r.Id == roomId);
            room.Status = RoomStatus.Waiting;

            await stateStore.RemoveAsync(roomId);

            await group.SendAsync("GameOver", new
            {
                winnerId = outcome.WinnerId,
                finalScores = outcome.FinalScores!.Select(s => new { userId = s.PlayerId, score = s.Score }),
            });
        }
        else if (state.CurrentPlayerId != previousPlayerId)
        {
            await group.SendAsync("TurnChanged", new { currentPlayerId = state.CurrentPlayerId, turnNumber = state.TurnNumber });
        }

        await db.SaveChangesAsync();
    }

    private static Dictionary<GemType, int> ParseGems(IEnumerable<string> gems)
    {
        var result = new Dictionary<GemType, int>();
        foreach (var gem in gems)
        {
            if (!Enum.TryParse<GemType>(gem, true, out var gemType))
                throw new HubException("INVALID_PAYLOAD");
            result[gemType] = result.GetValueOrDefault(gemType) + 1;
        }
        return result;
    }

    private static object BuildFullSync(GameState state) => new
    {
        type = "full",
        state,
        sequence = state.Sequence,
    };

    private static string GroupName(int roomId) => $"room-{roomId}";
}
