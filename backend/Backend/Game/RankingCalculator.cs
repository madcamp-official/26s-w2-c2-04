namespace Backend.GameLogic;

/// <summary>
/// 2~4인 자유경쟁(등수 기반) 결과를 다인전 Elo로 환산한다.
/// 모든 플레이어 쌍을 가상 1:1로 분해해 Elo 델타를 계산한 뒤,
/// 플레이어별로 자신이 연루된 쌍들의 델타를 평균 내서 인원수와 무관하게 변동폭을 비슷한 스케일로 맞춘다.
/// </summary>
public static class RankingCalculator
{
    private const int KFactor = 32;

    public static IReadOnlyDictionary<int, int> CalculateMmrDeltas(IReadOnlyList<(int UserId, int Place, int Mmr)> players)
    {
        var totals = players.ToDictionary(p => p.UserId, _ => 0.0);
        if (players.Count < 2)
            return totals.ToDictionary(kv => kv.Key, kv => 0);

        for (var i = 0; i < players.Count; i++)
        {
            for (var j = i + 1; j < players.Count; j++)
            {
                var a = players[i];
                var b = players[j];

                var expectedA = 1.0 / (1.0 + Math.Pow(10, (b.Mmr - a.Mmr) / 400.0));
                var scoreA = a.Place == b.Place ? 0.5 : (a.Place < b.Place ? 1.0 : 0.0);
                var deltaA = KFactor * (scoreA - expectedA);

                totals[a.UserId] += deltaA;
                totals[b.UserId] -= deltaA;
            }
        }

        var opponentCount = players.Count - 1;
        var averaged = totals.ToDictionary(kv => kv.Key, kv => kv.Value / opponentCount);

        // 개별 반올림을 그대로 쓰면 정수 합이 정확히 0이 안 될 수 있다(누적되면 전체 MMR 총량이 드리프트함).
        // UserId 오름차순으로 마지막 한 명을 제외하고 반올림한 뒤, 마지막 한 명은 "나머지 합의 음수"로
        // 확정해서 델타 합이 항상 정확히 0이 되도록 한다.
        var orderedKeys = averaged.Keys.OrderBy(k => k).ToList();
        var result = new Dictionary<int, int>();
        var runningSum = 0;
        for (var i = 0; i < orderedKeys.Count - 1; i++)
        {
            var rounded = (int)Math.Round(averaged[orderedKeys[i]]);
            result[orderedKeys[i]] = rounded;
            runningSum += rounded;
        }
        result[orderedKeys[^1]] = -runningSum;
        return result;
    }
}
