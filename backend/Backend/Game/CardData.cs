namespace Backend.GameLogic;

/// <summary>
/// 티어별 장수(40/30/20)·점수·코스트 총합 규칙을 따르는 생성 데이터.
/// 실제 스플랜더 정식 발매 카드 목록을 그대로 옮긴 것은 아니며, 필요 시 이 파일만 교체하면 된다.
/// </summary>
public static class CardData
{
    private static readonly GemType[] Colors =
    [
        GemType.Diamond, GemType.Sapphire, GemType.Emerald, GemType.Ruby, GemType.Onyx,
    ];

    public static IReadOnlyList<Card> GenerateCards()
    {
        var cards = new List<Card>();
        cards.AddRange(GenerateTier(1, [3, 3, 3, 3, 4, 4, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0]));
        cards.AddRange(GenerateTier(2, [5, 5, 6, 6, 7, 7], [1, 1, 2, 2, 3, 3]));
        cards.AddRange(GenerateTier(3, [7, 8, 8, 9], [3, 4, 4, 5]));
        return cards;
    }

    public static IReadOnlyList<Noble> GenerateNobles()
    {
        var nobles = new List<Noble>();
        for (var i = 0; i < 10; i++)
        {
            var step = i < 5 ? 1 : 2;
            var baseIndex = i % 5;
            var requirement = new Dictionary<GemType, int>
            {
                [Colors[baseIndex]] = 3,
                [Colors[(baseIndex + step) % 5]] = 3,
                [Colors[(baseIndex + (2 * step)) % 5]] = 3,
            };
            nobles.Add(new Noble($"N{i + 1}", 3, requirement));
        }
        return nobles;
    }

    private static IEnumerable<Card> GenerateTier(int tier, int[] costTotals, int[] points)
    {
        for (var colorIndex = 0; colorIndex < Colors.Length; colorIndex++)
        {
            var bonus = Colors[colorIndex];
            var otherColors = Colors.Where(c => c != bonus).ToArray();

            for (var i = 0; i < costTotals.Length; i++)
            {
                var cost = new Dictionary<GemType, int>();
                var remaining = costTotals[i];
                var cursor = i;
                while (remaining > 0)
                {
                    var color = otherColors[cursor % otherColors.Length];
                    cost[color] = cost.GetValueOrDefault(color) + 1;
                    remaining--;
                    cursor++;
                }

                yield return new Card($"T{tier}-{bonus}-{i + 1}", tier, points[i], bonus, cost);
            }
        }
    }
}
