namespace Backend.GameLogic;

public class GameRuleException(string code, string message) : Exception(message)
{
    public string Code { get; } = code;
}

public record PlayerScore(int PlayerId, int Score);

public record ActionOutcome(
    bool FinalRoundTriggered,
    IReadOnlyList<string> AutoAwardedNobleIds,
    IReadOnlyList<string> NobleChoiceCandidateIds,
    bool GameOver,
    int? WinnerId,
    IReadOnlyList<PlayerScore>? FinalScores,
    bool TimedOut = false);

public static class GameEngine
{
    // 피셔 룰 턴 타이머: 뱅크는 항상 30초로 캡되고, 턴이 끝날 때마다(정상 종료든 타임아웃이든) 10초 증가.
    private const int MaxTurnBankSeconds = 30;
    private const int TurnIncrementSeconds = 10;

    public static GameState Initialize(IReadOnlyList<int> playerIds, Random? random = null)
    {
        if (playerIds.Count is < 2 or > 4)
            throw new GameRuleException("INVALID_PAYLOAD", "플레이어는 2~4명이어야 합니다.");
        if (playerIds.Distinct().Count() != playerIds.Count)
            throw new GameRuleException("INVALID_PAYLOAD", "중복된 플레이어가 있습니다.");

        random ??= new Random();

        var tokensPerColor = playerIds.Count switch { 2 => 4, 3 => 5, _ => 7 };
        var state = new GameState
        {
            PlayerOrder = playerIds.ToList(),
            TokenBank = Enum.GetValues<GemType>()
                .Where(g => g != GemType.Gold)
                .ToDictionary(g => g, _ => tokensPerColor),
        };
        state.TokenBank[GemType.Gold] = 5;

        foreach (var playerId in playerIds)
            state.Players[playerId] = new PlayerState { UserId = playerId };

        var allCards = CardData.GenerateCards();
        foreach (var tier in new[] { 1, 2, 3 })
        {
            var deck = allCards.Where(c => c.Tier == tier).OrderBy(_ => random.Next()).ToList();
            state.Board[tier] = deck.Take(4).ToList();
            state.Decks[tier] = deck.Skip(4).ToList();
        }

        var allNobles = CardData.GenerateNobles().OrderBy(_ => random.Next()).ToList();
        state.BoardNobles = allNobles.Take(playerIds.Count + 1).ToList();

        foreach (var playerId in playerIds)
            state.TimeBankSeconds[playerId] = MaxTurnBankSeconds;
        state.TurnDeadlineUtc = DateTime.UtcNow.AddSeconds(MaxTurnBankSeconds);

        return state;
    }

    public static ActionOutcome TakeTokens(GameState state, int playerId, IReadOnlyDictionary<GemType, int> gems)
    {
        var player = GetActingPlayer(state, playerId);
        EnsureNotAwaitingDiscard(player);
        EnsureNoPendingNobleChoice(state);

        if (gems.Keys.Any(g => g == GemType.Gold))
            throw new GameRuleException("INVALID_TOKEN_SELECTION", "골드 토큰은 TakeTokens로 획득할 수 없습니다.");

        var isThreeDistinct = gems.Count == 3 && gems.Values.All(v => v == 1);
        var isTwoSame = gems.Count == 1 && gems.Values.Single() == 2;
        if (!isThreeDistinct && !isTwoSame)
            throw new GameRuleException("INVALID_TOKEN_SELECTION", "서로 다른 3색 1개씩 또는 동일 색 2개만 선택할 수 있습니다.");

        if (isTwoSame && state.TokenBank.GetValueOrDefault(gems.Keys.Single()) < 4)
            throw new GameRuleException("INVALID_TOKEN_SELECTION", "은행에 해당 색상이 4개 이상 있어야 2개를 가져올 수 있습니다.");

        foreach (var (color, amount) in gems)
        {
            if (state.TokenBank.GetValueOrDefault(color) < amount)
                throw new GameRuleException("INVALID_TOKEN_SELECTION", "은행에 토큰이 부족합니다.");
        }

        state.Sequence++;
        foreach (var (color, amount) in gems)
        {
            state.TokenBank[color] -= amount;
            player.Tokens[color] = player.Tokens.GetValueOrDefault(color) + amount;
        }

        return FinalizeTurn(state, player, holdForNobleChoice: false, []);
    }

    public static ActionOutcome PurchaseCard(GameState state, int playerId, string cardId, string source)
    {
        if (source is not ("Board" or "Reserved"))
            throw new GameRuleException("INVALID_PAYLOAD", "source는 Board 또는 Reserved 여야 합니다.");

        var player = GetActingPlayer(state, playerId);
        EnsureNotAwaitingDiscard(player);
        EnsureNoPendingNobleChoice(state);

        var card = source == "Reserved"
            ? player.ReservedCards.FirstOrDefault(c => c.Id == cardId)
                ?? throw new GameRuleException("CARD_NOT_OWNED", "예약한 카드가 아닙니다.")
            : state.Board.Values.SelectMany(cards => cards).FirstOrDefault(c => c.Id == cardId)
                ?? throw new GameRuleException("CARD_NOT_FOUND", "보드에서 카드를 찾을 수 없습니다.");

        var goldNeeded = 0;
        var colorPayment = new Dictionary<GemType, int>();
        foreach (var (color, amount) in card.Cost)
        {
            var afterBonus = Math.Max(0, amount - player.Bonuses.GetValueOrDefault(color));
            var fromColor = Math.Min(player.Tokens.GetValueOrDefault(color), afterBonus);
            colorPayment[color] = fromColor;
            goldNeeded += afterBonus - fromColor;
        }
        if (goldNeeded > player.Tokens.GetValueOrDefault(GemType.Gold))
            throw new GameRuleException("INSUFFICIENT_COST", "비용이 부족합니다.");

        state.Sequence++;

        foreach (var (color, amount) in colorPayment)
        {
            if (amount == 0) continue;
            player.Tokens[color] -= amount;
            state.TokenBank[color] = state.TokenBank.GetValueOrDefault(color) + amount;
        }
        if (goldNeeded > 0)
        {
            player.Tokens[GemType.Gold] -= goldNeeded;
            state.TokenBank[GemType.Gold] = state.TokenBank.GetValueOrDefault(GemType.Gold) + goldNeeded;
        }

        RemoveCardFromSource(state, player, card, source);
        player.PurchasedCards.Add(card);
        player.Bonuses[card.Bonus] = player.Bonuses.GetValueOrDefault(card.Bonus) + 1;

        var eligibleNobles = EvaluateNobles(state, player);
        List<string> autoAwarded = [];
        List<string> choiceCandidates = [];
        if (eligibleNobles.Count == 1)
        {
            AwardNoble(state, player, eligibleNobles[0]);
            autoAwarded.Add(eligibleNobles[0].Id);
        }
        else if (eligibleNobles.Count > 1)
        {
            choiceCandidates = eligibleNobles.Select(n => n.Id).ToList();
            state.PendingNobleChoiceIds = choiceCandidates;
        }

        return FinalizeTurn(state, player, holdForNobleChoice: choiceCandidates.Count > 0, autoAwarded, choiceCandidates);
    }

    public static ActionOutcome ReserveCard(GameState state, int playerId, string? cardId, int? tier)
    {
        var player = GetActingPlayer(state, playerId);
        EnsureNotAwaitingDiscard(player);
        EnsureNoPendingNobleChoice(state);

        if (player.ReservedCards.Count >= 3)
            throw new GameRuleException("RESERVE_LIMIT_EXCEEDED", "예약 카드는 3장을 초과할 수 없습니다.");

        Card card;
        if (cardId is not null)
        {
            card = state.Board.Values.SelectMany(cards => cards).FirstOrDefault(c => c.Id == cardId)
                ?? throw new GameRuleException("CARD_NOT_FOUND", "보드에서 카드를 찾을 수 없습니다.");
            state.Sequence++;
            state.Board[card.Tier].RemoveAll(c => c.Id == card.Id);
            RefillBoard(state, card.Tier);
        }
        else if (tier is not null)
        {
            if (!state.Decks.TryGetValue(tier.Value, out var deck) || deck.Count == 0)
                throw new GameRuleException("CARD_NOT_FOUND", "해당 티어의 덱이 비어 있습니다.");
            card = deck[^1];
            deck.RemoveAt(deck.Count - 1);
            state.Sequence++;
        }
        else
        {
            throw new GameRuleException("INVALID_PAYLOAD", "cardId 또는 tier 중 하나가 필요합니다.");
        }

        player.ReservedCards.Add(card);

        if (state.TokenBank.GetValueOrDefault(GemType.Gold) > 0)
        {
            state.TokenBank[GemType.Gold]--;
            player.Tokens[GemType.Gold] = player.Tokens.GetValueOrDefault(GemType.Gold) + 1;
        }

        return FinalizeTurn(state, player, holdForNobleChoice: false, []);
    }

    public static ActionOutcome DiscardTokens(GameState state, int playerId, IReadOnlyDictionary<GemType, int> gems)
    {
        var player = GetActingPlayer(state, playerId);
        if (player.TotalTokens <= 10)
            throw new GameRuleException("INVALID_PAYLOAD", "반납이 필요한 상태가 아닙니다.");

        foreach (var (color, amount) in gems)
        {
            if (amount < 0)
                throw new GameRuleException("INVALID_PAYLOAD", "반납 수량은 음수일 수 없습니다.");
            if (player.Tokens.GetValueOrDefault(color) < amount)
                throw new GameRuleException("INVALID_PAYLOAD", "보유한 토큰보다 많이 반납할 수 없습니다.");
        }

        var totalDiscard = gems.Values.Sum();
        if (player.TotalTokens - totalDiscard != 10)
            throw new GameRuleException("TOKEN_LIMIT_EXCEEDED", "정확히 10개가 되도록 반납해야 합니다.");

        state.Sequence++;
        foreach (var (color, amount) in gems)
        {
            player.Tokens[color] -= amount;
            state.TokenBank[color] = state.TokenBank.GetValueOrDefault(color) + amount;
        }

        return FinalizeTurn(state, player, holdForNobleChoice: false, []);
    }

    public static ActionOutcome ClaimNoble(GameState state, int playerId, string nobleId)
    {
        var player = GetActingPlayer(state, playerId);
        EnsureNotAwaitingDiscard(player);

        var noble = state.BoardNobles.FirstOrDefault(n => n.Id == nobleId)
            ?? throw new GameRuleException("NOBLE_NOT_ELIGIBLE", "존재하지 않는 귀족입니다.");

        if (!noble.Requirement.All(kv => player.Bonuses.GetValueOrDefault(kv.Key) >= kv.Value))
            throw new GameRuleException("NOBLE_NOT_ELIGIBLE", "귀족 조건을 충족하지 않습니다.");

        state.Sequence++;
        AwardNoble(state, player, noble);
        state.PendingNobleChoiceIds = [];

        return FinalizeTurn(state, player, holdForNobleChoice: false, [noble.Id]);
    }

    /// <summary>
    /// 턴 제한시간 초과 시 서버가 대신 호출하는 무조건 패스. 노블 선택 대기 중이었다면
    /// 포기 처리(PendingNobleChoiceIds는 전역 상태라 안 지우면 다음 플레이어까지 막히므로 필수)하고,
    /// 토큰을 10개 초과 보유 중이었다면 정확히 10개가 되도록 무작위로 반납시킨 뒤,
    /// 그 외에는 아무 것도 확인/자동 수행하지 않고 무조건 다음 플레이어에게 턴을 넘긴다.
    /// </summary>
    public static ActionOutcome ResolveTimeout(GameState state, int playerId, Random? random = null)
    {
        if (state.CurrentPlayerId != playerId)
            throw new GameRuleException("NOT_YOUR_TURN", "이미 턴이 넘어갔습니다.");

        random ??= new Random();

        state.PendingNobleChoiceIds = [];
        RandomlyDiscardExcessTokens(state, state.Players[playerId], random);
        state.Sequence++;

        var gameOver = AdvanceTurnAndResetClock(state, playerId);
        if (!gameOver)
            return new ActionOutcome(false, [], [], false, null, null, TimedOut: true);

        var (winnerId, scores) = FinishGame(state);
        return new ActionOutcome(false, [], [], true, winnerId, scores, TimedOut: true);
    }

    /// <summary>
    /// 보유 토큰이 10개를 초과하면, 초과분만큼 색상을 무작위로 골라 한 개씩 은행에 반납한다.
    /// ResolveTimeout 전용 — 사람이 직접 고르는 DiscardTokens와 달리 서버가 대신 결정한다.
    /// </summary>
    private static void RandomlyDiscardExcessTokens(GameState state, PlayerState player, Random random)
    {
        var excess = player.TotalTokens - 10;
        for (var i = 0; i < excess; i++)
        {
            var heldColors = player.Tokens.Where(kv => kv.Value > 0).Select(kv => kv.Key).ToList();
            if (heldColors.Count == 0)
                break; // 방어적: 이미 10개 이하인데 호출된 경우 등

            var color = heldColors[random.Next(heldColors.Count)];
            player.Tokens[color]--;
            state.TokenBank[color] = state.TokenBank.GetValueOrDefault(color) + 1;
        }
    }

    /// <summary>
    /// 부분 탈주(2명 이상 남는 경우) 확정 시 그 플레이어를 게임에서 완전히 제거한다.
    /// 남은 인원이 1명 이하가 되는 경우는 호출부(RoomDepartureService)가 별도로
    /// 게임 강제 종료 경로를 타므로 이 메서드를 쓰지 않는다.
    /// </summary>
    public static bool RemovePlayer(GameState state, int playerId)
    {
        if (!state.Players.ContainsKey(playerId))
            return false;

        var wasCurrentPlayer = state.CurrentPlayerId == playerId;
        var removedIndex = state.PlayerOrder.IndexOf(playerId);
        var nextPlayerId = wasCurrentPlayer
            ? state.PlayerOrder[(removedIndex + 1) % state.PlayerOrder.Count]
            : state.CurrentPlayerId;

        // FinalRound 중 LastTurnPlayerId가 나간 사람이면 그 앞 순번으로 재지정해야 라운드가 정상적으로 끝난다.
        if (state.Phase == GamePhase.FinalRound && state.LastTurnPlayerId == playerId)
            state.LastTurnPlayerId = state.PlayerOrder[(removedIndex - 1 + state.PlayerOrder.Count) % state.PlayerOrder.Count];

        state.PlayerOrder.RemoveAt(removedIndex);
        state.Players.Remove(playerId);

        if (wasCurrentPlayer)
        {
            state.PendingNobleChoiceIds = []; // 선택 못 하고 나갔으면 포기 처리(귀족은 보드에 남아 재평가됨)
            state.TurnNumber++;
        }
        state.CurrentPlayerIndex = state.PlayerOrder.IndexOf(nextPlayerId);
        state.Sequence++;

        if (wasCurrentPlayer)
        {
            // 나간 사람은 뱅크 증가 대상이 아니므로(턴을 정상적으로 끝낸 게 아님) 그냥 지우고,
            // 다음 플레이어의 기존 뱅크로 새 데드라인만 세팅한다.
            state.TimeBankSeconds.Remove(playerId);
            state.TurnDeadlineUtc = DateTime.UtcNow.AddSeconds(
                state.TimeBankSeconds.GetValueOrDefault(state.CurrentPlayerId, MaxTurnBankSeconds));
        }
        return true;
    }

    private static PlayerState GetActingPlayer(GameState state, int playerId)
    {
        if (state.CurrentPlayerId != playerId)
            throw new GameRuleException("NOT_YOUR_TURN", "당신의 턴이 아닙니다.");
        return state.Players[playerId];
    }

    private static void EnsureNoPendingNobleChoice(GameState state)
    {
        if (state.PendingNobleChoiceIds.Count > 0)
            throw new GameRuleException("NOBLE_CHOICE_PENDING", "먼저 귀족을 선택해야 합니다.");
    }

    private static void EnsureNotAwaitingDiscard(PlayerState player)
    {
        if (player.TotalTokens > 10)
            throw new GameRuleException("TOKEN_LIMIT_EXCEEDED", "토큰이 10개를 초과해 먼저 반납해야 합니다.");
    }

    private static List<Noble> EvaluateNobles(GameState state, PlayerState player) =>
        state.BoardNobles.Where(n => n.Requirement.All(kv => player.Bonuses.GetValueOrDefault(kv.Key) >= kv.Value)).ToList();

    private static void AwardNoble(GameState state, PlayerState player, Noble noble)
    {
        state.BoardNobles.RemoveAll(n => n.Id == noble.Id);
        player.Nobles.Add(noble.Id);
    }

    private static void RemoveCardFromSource(GameState state, PlayerState player, Card card, string source)
    {
        if (source == "Reserved")
        {
            player.ReservedCards.RemoveAll(c => c.Id == card.Id);
            return;
        }

        state.Board[card.Tier].RemoveAll(c => c.Id == card.Id);
        RefillBoard(state, card.Tier);
    }

    private static void RefillBoard(GameState state, int tier)
    {
        var deck = state.Decks[tier];
        if (deck.Count == 0)
            return;

        var next = deck[^1];
        deck.RemoveAt(deck.Count - 1);
        state.Board[tier].Add(next);
    }

    private static bool AdvanceTurn(GameState state)
    {
        var finishedPlayerId = state.CurrentPlayerId;
        if (state.Phase == GamePhase.FinalRound && finishedPlayerId == state.LastTurnPlayerId)
        {
            state.Phase = GamePhase.Finished;
            return true;
        }

        state.CurrentPlayerIndex = (state.CurrentPlayerIndex + 1) % state.PlayerOrder.Count;
        state.TurnNumber++;
        return false;
    }

    /// <summary>
    /// AdvanceTurn을 감싸서 피셔 룰 타이머(뱅크 증가 + 캡, 다음 턴 데드라인)까지 같이 갱신한다.
    /// FinalizeTurn과 ResolveTimeout이 공유하는 유일한 턴-전환 경로.
    /// </summary>
    private static bool AdvanceTurnAndResetClock(GameState state, int endingPlayerId)
    {
        if (state.TurnDeadlineUtc is { } deadline && state.TimeBankSeconds.ContainsKey(endingPlayerId))
        {
            var remaining = Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            state.TimeBankSeconds[endingPlayerId] = (int)Math.Min(MaxTurnBankSeconds, remaining + TurnIncrementSeconds);
        }

        var gameOver = AdvanceTurn(state);
        state.TurnDeadlineUtc = gameOver
            ? null
            : DateTime.UtcNow.AddSeconds(state.TimeBankSeconds.GetValueOrDefault(state.CurrentPlayerId, MaxTurnBankSeconds));
        return gameOver;
    }

    private static (int WinnerId, IReadOnlyList<PlayerScore> Scores) FinishGame(GameState state)
    {
        var ranked = state.Players.Values
            .OrderByDescending(p => p.Points)
            .ThenBy(p => p.PurchasedCards.Count)
            .ThenBy(p => state.PlayerOrder.IndexOf(p.UserId))
            .ToList();

        var scores = ranked.Select(p => new PlayerScore(p.UserId, p.Points)).ToList();
        return (ranked[0].UserId, scores);
    }

    private static ActionOutcome FinalizeTurn(
        GameState state,
        PlayerState player,
        bool holdForNobleChoice,
        IReadOnlyList<string> autoAwardedNobleIds,
        IReadOnlyList<string>? nobleChoiceCandidateIds = null)
    {
        var finalRoundTriggered = false;
        if (state.Phase == GamePhase.Playing && player.Points >= 15)
        {
            state.Phase = GamePhase.FinalRound;
            var idx = state.PlayerOrder.IndexOf(player.UserId);
            state.LastTurnPlayerId = state.PlayerOrder[(idx - 1 + state.PlayerOrder.Count) % state.PlayerOrder.Count];
            finalRoundTriggered = true;
        }

        nobleChoiceCandidateIds ??= [];
        if (holdForNobleChoice || player.TotalTokens > 10)
            return new ActionOutcome(finalRoundTriggered, autoAwardedNobleIds, nobleChoiceCandidateIds, false, null, null);

        var gameOver = AdvanceTurnAndResetClock(state, player.UserId);
        if (!gameOver)
            return new ActionOutcome(finalRoundTriggered, autoAwardedNobleIds, nobleChoiceCandidateIds, false, null, null);

        var (winnerId, scores) = FinishGame(state);
        return new ActionOutcome(finalRoundTriggered, autoAwardedNobleIds, nobleChoiceCandidateIds, true, winnerId, scores);
    }
}
