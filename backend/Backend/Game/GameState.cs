namespace Backend.GameLogic;

public enum GamePhase
{
    Playing,
    FinalRound,
    Finished,
}

public class PlayerState
{
    public int UserId { get; set; }
    public Dictionary<GemType, int> Tokens { get; set; } = new();
    public Dictionary<GemType, int> Bonuses { get; set; } = new();
    public List<Card> ReservedCards { get; set; } = new();
    public List<Card> PurchasedCards { get; set; } = new();
    public List<string> Nobles { get; set; } = new();

    public int Points => PurchasedCards.Sum(c => c.Points) + (Nobles.Count * 3);
    public int TotalTokens => Tokens.Values.Sum();
}

public class GameState
{
    public int GameId { get; set; }
    public List<int> PlayerOrder { get; set; } = new();
    public Dictionary<int, PlayerState> Players { get; set; } = new();
    public Dictionary<GemType, int> TokenBank { get; set; } = new();
    public Dictionary<int, List<Card>> Board { get; set; } = new();
    public Dictionary<int, List<Card>> Decks { get; set; } = new();
    public List<Noble> BoardNobles { get; set; } = new();
    public int CurrentPlayerIndex { get; set; }
    public int TurnNumber { get; set; } = 1;
    public GamePhase Phase { get; set; } = GamePhase.Playing;
    public int? LastTurnPlayerId { get; set; }
    public int Sequence { get; set; }
    public List<string> PendingNobleChoiceIds { get; set; } = new();

    /// <summary>피셔 룰 턴 타이머: playerId -> 다음 턴에 쓸 수 있는 뱅크(초), 항상 30 이하.</summary>
    public Dictionary<int, int> TimeBankSeconds { get; set; } = new();

    /// <summary>현재 턴이 끝나는 서버 기준(UTC) 마감 시각. 게임 종료 시 null.</summary>
    public DateTime? TurnDeadlineUtc { get; set; }

    public int CurrentPlayerId => PlayerOrder[CurrentPlayerIndex];
}
