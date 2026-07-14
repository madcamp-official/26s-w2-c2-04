using Backend.GameLogic;

namespace Backend.Tests;

public class GameEngineTests
{
    private static readonly GemType[] RealColors =
        [GemType.Diamond, GemType.Sapphire, GemType.Emerald, GemType.Ruby, GemType.Onyx];

    private static GameState CreateState(params int[] playerIds)
    {
        var state = new GameState { PlayerOrder = [.. playerIds] };
        foreach (var id in playerIds)
            state.Players[id] = new PlayerState { UserId = id };

        foreach (var color in RealColors)
            state.TokenBank[color] = 4;
        state.TokenBank[GemType.Gold] = 5;

        foreach (var tier in new[] { 1, 2, 3 })
        {
            state.Board[tier] = [];
            state.Decks[tier] = [];
        }

        return state;
    }

    [Fact]
    public void TakeTokens_ThreeDistinctColors_MovesToNextPlayer()
    {
        var state = CreateState(1, 2);

        var outcome = GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int>
        {
            [GemType.Diamond] = 1,
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
        });

        Assert.Equal(3, state.Players[1].TotalTokens);
        Assert.Equal(3, state.TokenBank[GemType.Diamond]);
        Assert.Equal(2, state.CurrentPlayerId);
        Assert.False(outcome.GameOver);
    }

    [Fact]
    public void TakeTokens_TwoDifferentColors_ThrowsInvalidSelection()
    {
        var state = CreateState(1, 2);

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int>
        {
            [GemType.Diamond] = 1,
            [GemType.Sapphire] = 1,
        }));

        Assert.Equal("INVALID_TOKEN_SELECTION", ex.Code);
    }

    [Fact]
    public void TakeTokens_TwoSameColor_RequiresBankOfFour()
    {
        var state = CreateState(1, 2);
        state.TokenBank[GemType.Diamond] = 3;

        var ex = Assert.Throws<GameRuleException>(() =>
            GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int> { [GemType.Diamond] = 2 }));

        Assert.Equal("INVALID_TOKEN_SELECTION", ex.Code);
    }

    [Fact]
    public void TakeTokens_NotCurrentPlayer_ThrowsNotYourTurn()
    {
        var state = CreateState(1, 2);

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.TakeTokens(state, 2, new Dictionary<GemType, int>
        {
            [GemType.Diamond] = 1,
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
        }));

        Assert.Equal("NOT_YOUR_TURN", ex.Code);
    }

    [Fact]
    public void PurchaseCard_FromBoard_DeductsTokensAndAddsBonus()
    {
        var state = CreateState(1, 2);
        var card = new Card("T1-Diamond-1", 1, 0, GemType.Diamond, new Dictionary<GemType, int> { [GemType.Sapphire] = 2 });
        state.Board[1].Add(card);
        state.Players[1].Tokens[GemType.Sapphire] = 2;

        GameEngine.PurchaseCard(state, 1, card.Id, "Board");

        Assert.Equal(0, state.Players[1].Tokens.GetValueOrDefault(GemType.Sapphire));
        Assert.Equal(1, state.Players[1].Bonuses[GemType.Diamond]);
        Assert.Contains(card, state.Players[1].PurchasedCards);
        Assert.DoesNotContain(card, state.Board[1]);
        Assert.Equal(2, state.CurrentPlayerId);
    }

    [Fact]
    public void PurchaseCard_InsufficientTokens_ThrowsInsufficientCost()
    {
        var state = CreateState(1, 2);
        var card = new Card("T1-Diamond-1", 1, 0, GemType.Diamond, new Dictionary<GemType, int> { [GemType.Sapphire] = 2 });
        state.Board[1].Add(card);

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.PurchaseCard(state, 1, card.Id, "Board"));
        Assert.Equal("INSUFFICIENT_COST", ex.Code);
    }

    [Fact]
    public void ReserveCard_MoreThanThree_ThrowsReserveLimitExceeded()
    {
        var state = CreateState(1, 2);
        for (var i = 0; i < 3; i++)
            state.Players[1].ReservedCards.Add(new Card($"c{i}", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));
        state.Board[1].Add(new Card("extra", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.ReserveCard(state, 1, "extra", null));
        Assert.Equal("RESERVE_LIMIT_EXCEEDED", ex.Code);
    }

    [Fact]
    public void ReserveCard_GrantsGoldToken()
    {
        var state = CreateState(1, 2);
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));

        GameEngine.ReserveCard(state, 1, "c1", null);

        Assert.Equal(1, state.Players[1].Tokens.GetValueOrDefault(GemType.Gold));
        Assert.Equal(4, state.TokenBank[GemType.Gold]);
    }

    [Fact]
    public void TakeTokens_OverTenTokens_HoldsTurnUntilDiscard()
    {
        var state = CreateState(1, 2);
        state.Players[1].Tokens[GemType.Diamond] = 4;
        state.Players[1].Tokens[GemType.Sapphire] = 4;
        state.Players[1].Tokens[GemType.Emerald] = 2;

        var outcome = GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int>
        {
            [GemType.Ruby] = 1,
            [GemType.Onyx] = 1,
            [GemType.Diamond] = 1,
        });

        Assert.Equal(13, state.Players[1].TotalTokens);
        Assert.Equal(1, state.CurrentPlayerId);
        Assert.False(outcome.GameOver);

        var blocked = Assert.Throws<GameRuleException>(() =>
            GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        Assert.Equal("TOKEN_LIMIT_EXCEEDED", blocked.Code);

        GameEngine.DiscardTokens(state, 1, new Dictionary<GemType, int> { [GemType.Diamond] = 2, [GemType.Sapphire] = 1 });

        Assert.Equal(10, state.Players[1].TotalTokens);
        Assert.Equal(2, state.CurrentPlayerId);
    }

    [Fact]
    public void PurchaseCard_MeetingNobleRequirement_AutoAwardsSingleEligibleNoble()
    {
        var state = CreateState(1, 2);
        var noble = new Noble("N1", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 });
        state.BoardNobles.Add(noble);
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));

        var outcome = GameEngine.PurchaseCard(state, 1, "c1", "Board");

        Assert.Contains("N1", outcome.AutoAwardedNobleIds);
        Assert.Contains("N1", state.Players[1].Nobles);
        Assert.DoesNotContain(noble, state.BoardNobles);
    }

    [Fact]
    public void PurchaseCard_MultipleEligibleNobles_RequiresChoiceAndHoldsTurn()
    {
        var state = CreateState(1, 2);
        state.BoardNobles.Add(new Noble("N1", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.BoardNobles.Add(new Noble("N2", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));

        var outcome = GameEngine.PurchaseCard(state, 1, "c1", "Board");

        Assert.Equal(2, outcome.NobleChoiceCandidateIds.Count);
        Assert.Empty(outcome.AutoAwardedNobleIds);
        Assert.Equal(1, state.CurrentPlayerId);

        GameEngine.ClaimNoble(state, 1, "N1");

        Assert.Contains("N1", state.Players[1].Nobles);
        Assert.Equal(2, state.CurrentPlayerId);
    }

    [Fact]
    public void PurchaseCard_Reaching15Points_TriggersFinalRoundThenGameOver()
    {
        var state = CreateState(1, 2);
        state.Players[1].PurchasedCards.Add(new Card("dummy", 3, 14, GemType.Diamond, new Dictionary<GemType, int>()));
        state.Board[3].Add(new Card("winner", 3, 1, GemType.Sapphire, new Dictionary<GemType, int>()));

        var outcome = GameEngine.PurchaseCard(state, 1, "winner", "Board");

        Assert.True(outcome.FinalRoundTriggered);
        Assert.False(outcome.GameOver);
        Assert.Equal(GamePhase.FinalRound, state.Phase);
        Assert.Equal(2, state.LastTurnPlayerId);
        Assert.Equal(2, state.CurrentPlayerId);

        var finalOutcome = GameEngine.TakeTokens(state, 2, new Dictionary<GemType, int>
        {
            [GemType.Diamond] = 1,
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
        });

        Assert.True(finalOutcome.GameOver);
        Assert.Equal(1, finalOutcome.WinnerId);
        Assert.Equal(GamePhase.Finished, state.Phase);
    }

    [Fact]
    public void Initialize_CreatesBoardAndNoblesForPlayerCount()
    {
        var state = GameEngine.Initialize([1, 2, 3], new Random(42));

        Assert.Equal(4, state.Board[1].Count);
        Assert.Equal(4, state.Board[2].Count);
        Assert.Equal(4, state.Board[3].Count);
        Assert.Equal(4, state.BoardNobles.Count);
        Assert.Equal(5, state.TokenBank[GemType.Diamond]);
        Assert.Equal(5, state.TokenBank[GemType.Gold]);
    }

    [Fact]
    public void Initialize_DuplicatePlayerIds_ThrowsInvalidPayload()
    {
        var ex = Assert.Throws<GameRuleException>(() => GameEngine.Initialize([1, 2, 1]));
        Assert.Equal("INVALID_PAYLOAD", ex.Code);
    }

    [Fact]
    public void ClaimNoble_WhileAwaitingDiscard_ThrowsTokenLimitExceeded()
    {
        var state = CreateState(1, 2);
        state.Players[1].Tokens[GemType.Diamond] = 11;
        state.BoardNobles.Add(new Noble("N1", 3, new Dictionary<GemType, int>()));

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.ClaimNoble(state, 1, "N1"));
        Assert.Equal("TOKEN_LIMIT_EXCEEDED", ex.Code);
    }

    [Fact]
    public void DiscardTokens_NegativeAmount_ThrowsInvalidPayload()
    {
        var state = CreateState(1, 2);
        state.Players[1].Tokens[GemType.Diamond] = 11;

        var ex = Assert.Throws<GameRuleException>(() =>
            GameEngine.DiscardTokens(state, 1, new Dictionary<GemType, int> { [GemType.Diamond] = -1, [GemType.Sapphire] = 2 }));
        Assert.Equal("INVALID_PAYLOAD", ex.Code);
    }

    [Fact]
    public void PurchaseCard_MultipleEligibleNobles_BlocksOtherActionsUntilClaimed()
    {
        var state = CreateState(1, 2);
        state.BoardNobles.Add(new Noble("N1", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.BoardNobles.Add(new Noble("N2", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));

        GameEngine.PurchaseCard(state, 1, "c1", "Board");
        Assert.Equal(2, state.PendingNobleChoiceIds.Count);

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int>
        {
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
            [GemType.Ruby] = 1,
        }));
        Assert.Equal("NOBLE_CHOICE_PENDING", ex.Code);

        GameEngine.ClaimNoble(state, 1, "N1");
        Assert.Empty(state.PendingNobleChoiceIds);

        // 이제는 다시 정상적으로 다른 액션을 할 수 있어야 함(턴은 이미 2로 넘어감).
        var outcome = GameEngine.TakeTokens(state, 2, new Dictionary<GemType, int>
        {
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
            [GemType.Ruby] = 1,
        });
        Assert.False(outcome.GameOver);
    }

    [Fact]
    public void RemovePlayer_CurrentPlayerLeaves_AdvancesToNextAndClearsPendingChoice()
    {
        var state = CreateState(1, 2, 3);
        state.BoardNobles.Add(new Noble("N1", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.BoardNobles.Add(new Noble("N2", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));
        GameEngine.PurchaseCard(state, 1, "c1", "Board");
        Assert.Equal(2, state.PendingNobleChoiceIds.Count);

        var removed = GameEngine.RemovePlayer(state, 1);

        Assert.True(removed);
        Assert.DoesNotContain(1, state.PlayerOrder);
        Assert.False(state.Players.ContainsKey(1));
        Assert.Empty(state.PendingNobleChoiceIds);
        Assert.Equal(2, state.CurrentPlayerId);
    }

    [Fact]
    public void RemovePlayer_NotCurrentPlayer_KeepsCurrentPlayerTurn()
    {
        var state = CreateState(1, 2, 3);
        // 현재 턴은 1번. 2번(현재 턴이 아닌 플레이어)을 제거해도 1번 턴은 유지되어야 함.
        var removed = GameEngine.RemovePlayer(state, 2);

        Assert.True(removed);
        Assert.Equal(1, state.CurrentPlayerId);
        Assert.Equal([1, 3], state.PlayerOrder);
    }

    [Fact]
    public void RemovePlayer_UnknownPlayer_ReturnsFalse()
    {
        var state = CreateState(1, 2);
        Assert.False(GameEngine.RemovePlayer(state, 999));
    }

    [Fact]
    public void RemovePlayer_DuringFinalRound_ReassignsLastTurnPlayer()
    {
        var state = CreateState(1, 2, 3);
        state.Players[1].PurchasedCards.Add(new Card("dummy", 3, 14, GemType.Diamond, new Dictionary<GemType, int>()));
        state.Board[3].Add(new Card("winner", 3, 1, GemType.Sapphire, new Dictionary<GemType, int>()));
        GameEngine.PurchaseCard(state, 1, "winner", "Board");
        Assert.Equal(GamePhase.FinalRound, state.Phase);
        Assert.Equal(3, state.LastTurnPlayerId); // 트리거한 1번의 바로 앞 순번(3번)이 마지막 차례

        // LastTurnPlayerId(3번)가 탈주하면, 그 앞 순번(2번)으로 재지정돼야 라운드가 정상적으로 끝남.
        GameEngine.RemovePlayer(state, 3);

        Assert.Equal(2, state.LastTurnPlayerId);
    }

    [Fact]
    public void Initialize_SeedsTurnTimerForAllPlayers()
    {
        var state = GameEngine.Initialize([1, 2, 3], new Random(42));

        Assert.Equal(30, state.TimeBankSeconds[1]);
        Assert.Equal(30, state.TimeBankSeconds[2]);
        Assert.Equal(30, state.TimeBankSeconds[3]);
        Assert.NotNull(state.TurnDeadlineUtc);
        Assert.True(state.TurnDeadlineUtc > DateTime.UtcNow.AddSeconds(25));
    }

    [Fact]
    public void TakeTokens_EndingTurnEarly_BankIncrementIsCappedAt30()
    {
        var state = CreateState(1, 2);
        state.TimeBankSeconds[1] = 20;
        state.TurnDeadlineUtc = DateTime.UtcNow.AddSeconds(100); // 아직 넉넉히 남아있다고 가정

        GameEngine.TakeTokens(state, 1, new Dictionary<GemType, int>
        {
            [GemType.Diamond] = 1,
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
        });

        Assert.Equal(30, state.TimeBankSeconds[1]); // remaining(~100)+10 이지만 30으로 캡
    }

    [Fact]
    public void ResolveTimeout_AdvancesTurnAndGrantsTenSecondBank()
    {
        var state = CreateState(1, 2);
        state.TimeBankSeconds[1] = 30;
        state.TimeBankSeconds[2] = 30;
        state.TurnDeadlineUtc = DateTime.UtcNow.AddSeconds(-1); // 이미 마감 지남

        var outcome = GameEngine.ResolveTimeout(state, 1);

        Assert.True(outcome.TimedOut);
        Assert.False(outcome.GameOver);
        Assert.Equal(2, state.CurrentPlayerId);
        Assert.Equal(10, state.TimeBankSeconds[1]); // 0(이미 지남) + 10
        Assert.NotNull(state.TurnDeadlineUtc);
    }

    [Fact]
    public void ResolveTimeout_WhilePendingNobleChoice_ForfeitsAndUnblocksNextPlayer()
    {
        var state = CreateState(1, 2);
        state.BoardNobles.Add(new Noble("N1", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.BoardNobles.Add(new Noble("N2", 3, new Dictionary<GemType, int> { [GemType.Diamond] = 1 }));
        state.Board[1].Add(new Card("c1", 1, 0, GemType.Diamond, new Dictionary<GemType, int>()));
        GameEngine.PurchaseCard(state, 1, "c1", "Board");
        Assert.Equal(2, state.PendingNobleChoiceIds.Count);
        Assert.Equal(1, state.CurrentPlayerId); // 노블 선택 대기라 아직 1번 턴

        GameEngine.ResolveTimeout(state, 1);

        Assert.Empty(state.PendingNobleChoiceIds);
        Assert.Equal(2, state.CurrentPlayerId);

        // 전역 잠금(EnsureNoPendingNobleChoice)이 풀려서 2번이 정상적으로 행동할 수 있어야 한다.
        var outcome = GameEngine.TakeTokens(state, 2, new Dictionary<GemType, int>
        {
            [GemType.Sapphire] = 1,
            [GemType.Emerald] = 1,
            [GemType.Ruby] = 1,
        });
        Assert.False(outcome.GameOver);
    }

    [Fact]
    public void ResolveTimeout_NotCurrentPlayer_ThrowsNotYourTurn()
    {
        var state = CreateState(1, 2);

        var ex = Assert.Throws<GameRuleException>(() => GameEngine.ResolveTimeout(state, 2));
        Assert.Equal("NOT_YOUR_TURN", ex.Code);
    }

    [Fact]
    public void ResolveTimeout_WithExcessTokens_StillAdvancesTurnUnconditionally()
    {
        var state = CreateState(1, 2);
        state.Players[1].Tokens[GemType.Diamond] = 4;
        state.Players[1].Tokens[GemType.Sapphire] = 4;
        state.Players[1].Tokens[GemType.Emerald] = 3; // 11개, 원래는 반납이 필요한 상태

        GameEngine.ResolveTimeout(state, 1);

        Assert.Equal(2, state.CurrentPlayerId);
        Assert.Equal(11, state.Players[1].TotalTokens); // 자동 반납 없이 그대로 유지
    }
}
