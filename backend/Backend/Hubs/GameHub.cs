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

/// cardId(특정 카드 지정)와 tier(블라인드 드로우) 중 하나만 채워진다.
/// 프론트(Dart) SignalR 클라이언트가 List&lt;Object&gt; 위치 인자에 null을 못 담기 때문에
/// 객체 하나로 감싸서 받는다.
public record ReserveCardRequest(string? CardId, int? Tier);

[Authorize]
public class GameHub(GameStateStore stateStore, AppDbContext db) : Hub
{
    public async Task JoinRoom(int roomId)
    {
        var userId = Context.User!.GetUserId();
        var isMember = await db.RoomPlayers.AnyAsync(p => p.RoomId == roomId && p.UserId == userId);
        if (!isMember)
            throw new HubException("NOT_A_MEMBER");

        await Groups.AddToGroupAsync(Context.ConnectionId, GameHubMessages.GroupName(roomId));

        var state = await stateStore.LoadAsync(roomId);
        if (state is not null)
            await Clients.Caller.SendAsync("StateSync", GameHubMessages.BuildFullSync(state));

        var nickname = await db.Users.Where(u => u.Id == userId).Select(u => u.Nickname).FirstAsync();
        await Clients.OthersInGroup(GameHubMessages.GroupName(roomId)).SendAsync("PlayerJoined", new { userId, nickname });
    }

    public async Task LeaveRoom(int roomId)
    {
        var userId = Context.User!.GetUserId();
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GameHubMessages.GroupName(roomId));
        var nickname = await db.Users.Where(u => u.Id == userId).Select(u => u.Nickname).FirstAsync();
        await Clients.OthersInGroup(GameHubMessages.GroupName(roomId)).SendAsync("PlayerLeft", new { userId, nickname });
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

        await Clients.Group(GameHubMessages.GroupName(roomId)).SendAsync("StateSync", GameHubMessages.BuildFullSync(state));
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

    public async Task ReserveCard(int roomId, ReserveCardRequest request)
    {
        var userId = Context.User!.GetUserId();
        await HandleActionAsync(roomId, userId, "ReserveCard", new { request.CardId, request.Tier },
            state => GameEngine.ReserveCard(state, userId, request.CardId, request.Tier));
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

    public async Task SendChatMessage(int roomId, string text)
    {
        // TODO: README 7절 명세는 "발신자의 친구 목록"에게만 전달하도록 되어 있으나,
        // 친구(Friend) 기능이 아직 백엔드에 구현되어 있지 않아 우선 방 전체 브로드캐스트로 둔다.
        var userId = Context.User!.GetUserId();
        await Clients.OthersInGroup(GameHubMessages.GroupName(roomId))
            .SendAsync("ChatMessage", new { playerId = userId, text, ts = DateTime.UtcNow });
    }

    public async Task SendEmote(int roomId, string emoteId)
    {
        var userId = Context.User!.GetUserId();
        await Clients.OthersInGroup(GameHubMessages.GroupName(roomId))
            .SendAsync("EmoteReceived", new { playerId = userId, emoteId, ts = DateTime.UtcNow });
    }

    public async Task RequestResync(int roomId, int lastSequence)
    {
        var state = await stateStore.LoadAsync(roomId) ?? throw new HubException("GAME_NOT_FOUND");
        await Clients.Caller.SendAsync("StateSync", GameHubMessages.BuildFullSync(state));
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

        var group = Clients.Group(GameHubMessages.GroupName(roomId));
        await group.SendAsync("StateSync", GameHubMessages.BuildFullSync(state));

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

            await RecordResultsAsync(db, game.Id, room, state, outcome.FinalScores!);
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

    private static async Task RecordResultsAsync(
        AppDbContext db, int gameId, Room room, GameState state, IReadOnlyList<PlayerScore> finalScores)
    {
        var playerCount = state.PlayerOrder.Count;
        var isRanked = room.Ruleset == RoomRuleset.Official;

        for (var i = 0; i < finalScores.Count; i++)
        {
            var result = finalScores[i];
            db.GamePlayerResults.Add(new GamePlayerResult
            {
                GameId = gameId,
                UserId = result.PlayerId,
                PlayerCount = playerCount,
                Place = i + 1,
                Score = result.Score,
                IsRanked = isRanked,
            });
        }

        if (!isRanked)
            return;

        var userIds = finalScores.Select(s => s.PlayerId).ToList();
        var rankings = await db.PlayerRankings
            .Where(pr => pr.PlayerCount == playerCount && userIds.Contains(pr.UserId))
            .ToDictionaryAsync(pr => pr.UserId);

        foreach (var userId in userIds)
        {
            if (rankings.ContainsKey(userId))
                continue;

            var newRanking = new PlayerRanking { UserId = userId, PlayerCount = playerCount };
            db.PlayerRankings.Add(newRanking);
            rankings[userId] = newRanking;
        }

        var eloInput = finalScores
            .Select((s, i) => (UserId: s.PlayerId, Place: i + 1, Mmr: rankings[s.PlayerId].Mmr))
            .ToList();
        var deltas = RankingCalculator.CalculateMmrDeltas(eloInput);

        foreach (var (userId, place, _) in eloInput)
        {
            var ranking = rankings[userId];
            ranking.Mmr += deltas[userId];
            ranking.GamesPlayed++;
            ranking.TotalPlaceSum += place;
            ranking.UpdatedAt = DateTime.UtcNow;
        }
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
}
