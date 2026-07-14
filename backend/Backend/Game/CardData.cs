namespace Backend.GameLogic;

/// <summary>
/// 실제 스플렌더 카드/귀족 코스트 값을 그대로 옮긴 생성 데이터.
/// 카드 Id는 프론트(frontend/lib/game/assets.dart)가 기대하는 "T{tier}-{Bonus}-{index}"
/// 포맷을 유지하며, index(1-based)는 자산 파일명(assets/image/cards/{bonus}_{nn}_{suffix}.png)의
/// 전역 번호(1~18)와 티어별로 대응한다.
/// </summary>
public static class CardData
{
    private static readonly GemType[] Colors =
    [
        GemType.Diamond, GemType.Sapphire, GemType.Emerald, GemType.Ruby, GemType.Onyx,
    ];

    private static Dictionary<GemType, int> Cost(params (GemType Gem, int Count)[] entries) =>
        entries.ToDictionary(e => e.Gem, e => e.Count);

    private static readonly Dictionary<GemType, int>[][] Tier1CostsByColor =
    [
        // Diamond
        [
            Cost((GemType.Ruby, 2), (GemType.Onyx, 1)),
            Cost((GemType.Sapphire, 3)),
            Cost((GemType.Sapphire, 1), (GemType.Emerald, 1), (GemType.Ruby, 1), (GemType.Onyx, 1)),
            Cost((GemType.Sapphire, 2), (GemType.Onyx, 2)),
            Cost((GemType.Sapphire, 1), (GemType.Emerald, 2), (GemType.Ruby, 1), (GemType.Onyx, 1)),
            Cost((GemType.Sapphire, 2), (GemType.Emerald, 2), (GemType.Onyx, 1)),
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 1), (GemType.Onyx, 1)),
            Cost((GemType.Emerald, 4)),
        ],
        // Sapphire
        [
            Cost((GemType.Diamond, 1), (GemType.Onyx, 2)),
            Cost((GemType.Onyx, 3)),
            Cost((GemType.Diamond, 1), (GemType.Emerald, 1), (GemType.Ruby, 1), (GemType.Onyx, 1)),
            Cost((GemType.Emerald, 2), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 1), (GemType.Emerald, 1), (GemType.Ruby, 2), (GemType.Onyx, 1)),
            Cost((GemType.Diamond, 1), (GemType.Emerald, 2), (GemType.Ruby, 2)),
            Cost((GemType.Sapphire, 1), (GemType.Emerald, 3), (GemType.Ruby, 1)),
            Cost((GemType.Ruby, 4)),
        ],
        // Emerald
        [
            Cost((GemType.Sapphire, 1), (GemType.Diamond, 2)),
            Cost((GemType.Ruby, 3)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 1), (GemType.Ruby, 1), (GemType.Onyx, 1)),
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 2)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 1), (GemType.Ruby, 2), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 2), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 1), (GemType.Emerald, 1), (GemType.Sapphire, 3)),
            Cost((GemType.Onyx, 4)),
        ],
        // Ruby
        [
            Cost((GemType.Sapphire, 2), (GemType.Emerald, 1)),
            Cost((GemType.Diamond, 3)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 1), (GemType.Emerald, 1), (GemType.Onyx, 1)),
            Cost((GemType.Diamond, 2), (GemType.Ruby, 2)),
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 1), (GemType.Emerald, 1), (GemType.Onyx, 1)),
            Cost((GemType.Diamond, 2), (GemType.Emerald, 1), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 1), (GemType.Ruby, 1), (GemType.Onyx, 3)),
            Cost((GemType.Diamond, 4)),
        ],
        // Onyx
        [
            Cost((GemType.Emerald, 2), (GemType.Ruby, 1)),
            Cost((GemType.Emerald, 3)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 1), (GemType.Emerald, 1), (GemType.Ruby, 1)),
            Cost((GemType.Diamond, 2), (GemType.Emerald, 2)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 2), (GemType.Emerald, 1), (GemType.Ruby, 1)),
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 2), (GemType.Ruby, 1)),
            Cost((GemType.Emerald, 1), (GemType.Ruby, 3), (GemType.Onyx, 1)),
            Cost((GemType.Sapphire, 4)),
        ],
    ];

    private static readonly Dictionary<GemType, int>[][] Tier2CostsByColor =
    [
        // Diamond
        [
            Cost((GemType.Emerald, 3), (GemType.Ruby, 2), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 3), (GemType.Ruby, 3)),
            Cost((GemType.Ruby, 5)),
            Cost((GemType.Emerald, 1), (GemType.Ruby, 4), (GemType.Onyx, 2)),
            Cost((GemType.Ruby, 5), (GemType.Onyx, 3)),
            Cost((GemType.Diamond, 6)),
        ],
        // Sapphire
        [
            Cost((GemType.Sapphire, 2), (GemType.Emerald, 2), (GemType.Ruby, 3)),
            Cost((GemType.Sapphire, 2), (GemType.Emerald, 3), (GemType.Onyx, 3)),
            Cost((GemType.Sapphire, 5)),
            Cost((GemType.Diamond, 2), (GemType.Ruby, 1), (GemType.Onyx, 4)),
            Cost((GemType.Sapphire, 3), (GemType.Diamond, 5)),
            Cost((GemType.Sapphire, 6)),
        ],
        // Emerald
        [
            Cost((GemType.Diamond, 2), (GemType.Sapphire, 3), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 3), (GemType.Emerald, 2), (GemType.Ruby, 3)),
            Cost((GemType.Emerald, 5)),
            Cost((GemType.Diamond, 4), (GemType.Sapphire, 2), (GemType.Onyx, 1)),
            Cost((GemType.Sapphire, 5), (GemType.Emerald, 3)),
            Cost((GemType.Emerald, 6)),
        ],
        // Ruby
        [
            Cost((GemType.Diamond, 2), (GemType.Ruby, 2), (GemType.Onyx, 3)),
            Cost((GemType.Diamond, 3), (GemType.Ruby, 2), (GemType.Onyx, 3)),
            Cost((GemType.Onyx, 5)),
            Cost((GemType.Diamond, 1), (GemType.Sapphire, 4), (GemType.Emerald, 2)),
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 5)),
            Cost((GemType.Ruby, 6)),
        ],
        // Onyx
        [
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 2), (GemType.Emerald, 2)),
            Cost((GemType.Diamond, 3), (GemType.Emerald, 3), (GemType.Onyx, 2)),
            Cost((GemType.Diamond, 5)),
            Cost((GemType.Sapphire, 1), (GemType.Emerald, 4), (GemType.Ruby, 2)),
            Cost((GemType.Emerald, 5), (GemType.Ruby, 3)),
            Cost((GemType.Onyx, 6)),
        ],
    ];

    private static readonly Dictionary<GemType, int>[][] Tier3CostsByColor =
    [
        // Diamond
        [
            Cost((GemType.Sapphire, 3), (GemType.Emerald, 3), (GemType.Ruby, 5), (GemType.Onyx, 3)),
            Cost((GemType.Onyx, 7)),
            Cost((GemType.Diamond, 3), (GemType.Ruby, 3), (GemType.Onyx, 6)),
            Cost((GemType.Diamond, 3), (GemType.Onyx, 7)),
        ],
        // Sapphire
        [
            Cost((GemType.Diamond, 3), (GemType.Emerald, 3), (GemType.Ruby, 3), (GemType.Onyx, 5)),
            Cost((GemType.Diamond, 7)),
            Cost((GemType.Diamond, 6), (GemType.Sapphire, 3), (GemType.Onyx, 3)),
            Cost((GemType.Diamond, 7), (GemType.Sapphire, 3)),
        ],
        // Emerald
        [
            Cost((GemType.Diamond, 5), (GemType.Sapphire, 3), (GemType.Ruby, 3), (GemType.Onyx, 3)),
            Cost((GemType.Sapphire, 7)),
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 6), (GemType.Emerald, 3)),
            Cost((GemType.Sapphire, 7), (GemType.Emerald, 3)),
        ],
        // Ruby
        [
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 5), (GemType.Emerald, 3), (GemType.Onyx, 3)),
            Cost((GemType.Emerald, 7)),
            Cost((GemType.Sapphire, 3), (GemType.Emerald, 6), (GemType.Ruby, 3)),
            Cost((GemType.Emerald, 7), (GemType.Ruby, 3)),
        ],
        // Onyx
        [
            Cost((GemType.Diamond, 3), (GemType.Sapphire, 3), (GemType.Emerald, 5), (GemType.Ruby, 3)),
            Cost((GemType.Ruby, 7)),
            Cost((GemType.Emerald, 3), (GemType.Ruby, 6), (GemType.Onyx, 3)),
            Cost((GemType.Ruby, 7), (GemType.Onyx, 3)),
        ],
    ];

    // 티어 내 위치별 점수. 제공된 카드 데이터에는 점수가 없어 기존 배치를 그대로 유지한다.
    private static readonly int[] Tier1Points = [0, 0, 0, 0, 0, 0, 0, 0];
    private static readonly int[] Tier2Points = [1, 1, 2, 2, 3, 3];
    private static readonly int[] Tier3Points = [3, 4, 4, 5];

    public static IReadOnlyList<Card> GenerateCards()
    {
        var cards = new List<Card>();
        for (var c = 0; c < Colors.Length; c++)
        {
            var bonus = Colors[c];
            cards.AddRange(BuildTier(1, bonus, Tier1CostsByColor[c], Tier1Points));
            cards.AddRange(BuildTier(2, bonus, Tier2CostsByColor[c], Tier2Points));
            cards.AddRange(BuildTier(3, bonus, Tier3CostsByColor[c], Tier3Points));
        }
        return cards;
    }

    private static IEnumerable<Card> BuildTier(int tier, GemType bonus, Dictionary<GemType, int>[] costs, int[] points)
    {
        for (var i = 0; i < costs.Length; i++)
            yield return new Card($"T{tier}-{bonus}-{i + 1}", tier, points[i], bonus, costs[i]);
    }

    public static IReadOnlyList<Noble> GenerateNobles()
    {
        var requirements = new[]
        {
            Cost((GemType.Ruby, 4), (GemType.Emerald, 4)),
            Cost((GemType.Ruby, 3), (GemType.Onyx, 3), (GemType.Diamond, 3)),
            Cost((GemType.Sapphire, 4), (GemType.Diamond, 4)),
            Cost((GemType.Onyx, 4), (GemType.Diamond, 4)),
            Cost((GemType.Sapphire, 4), (GemType.Emerald, 4)),
            Cost((GemType.Sapphire, 3), (GemType.Emerald, 3), (GemType.Ruby, 3)),
            Cost((GemType.Sapphire, 3), (GemType.Emerald, 3), (GemType.Diamond, 3)),
            Cost((GemType.Ruby, 4), (GemType.Onyx, 4)),
            Cost((GemType.Sapphire, 3), (GemType.Diamond, 3), (GemType.Onyx, 3)),
            Cost((GemType.Ruby, 3), (GemType.Emerald, 3), (GemType.Onyx, 3)),
        };

        var nobles = new List<Noble>();
        for (var i = 0; i < requirements.Length; i++)
            nobles.Add(new Noble($"N{i + 1}", 3, requirements[i]));
        return nobles;
    }
}
