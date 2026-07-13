namespace Backend.GameLogic;

public record QueueEntry(int UserId, int Mmr, long JoinedAtUnixMs);

/// <summary>
/// 랭킹전 대기열을 MMR 유사도로 묶는다. 대기시간이 길어질수록 허용 MMR 범위가 넓어져
/// 오래 기다린 유저부터 매칭될 확률이 높아진다.
/// </summary>
public static class MatchmakingGrouper
{
    private const int InitialRange = 100;
    private const int RangePerSecond = 20;
    private const int MaxRange = 3000;

    public static int CalculateRange(double waitedSeconds) =>
        (int)Math.Min(MaxRange, InitialRange + (waitedSeconds * RangePerSecond));

    public static List<List<QueueEntry>> FindGroups(IReadOnlyList<QueueEntry> entries, int groupSize, DateTime nowUtc)
    {
        var pool = entries.OrderBy(e => e.JoinedAtUnixMs).ToList();
        var groups = new List<List<QueueEntry>>();

        while (pool.Count >= groupSize)
        {
            var anchor = pool[0];
            var anchorRange = CalculateRange(WaitedSeconds(anchor, nowUtc));

            var ranked = pool
                .Skip(1)
                .Select(e => (Entry: e, Diff: Math.Abs(e.Mmr - anchor.Mmr), Range: CalculateRange(WaitedSeconds(e, nowUtc))))
                // 둘 중 더 오래 기다려서 범위가 넓어진 쪽 기준으로 허용한다 - 안 그러면 먼저 큐에 들어와 범위가
                // 넓어진 사람이 방금 들어온 사람 때문에 계속 매칭에서 배제된다.
                .Where(c => c.Diff <= Math.Max(anchorRange, c.Range))
                .OrderBy(c => c.Diff)
                .ToList();

            if (ranked.Count < groupSize - 1)
            {
                pool.RemoveAt(0);
                continue;
            }

            var group = new List<QueueEntry> { anchor };
            group.AddRange(ranked.Take(groupSize - 1).Select(c => c.Entry));
            groups.Add(group);

            foreach (var member in group)
                pool.Remove(member);
        }

        return groups;
    }

    private static double WaitedSeconds(QueueEntry entry, DateTime nowUtc) =>
        Math.Max(0, (nowUtc - DateTimeOffset.FromUnixTimeMilliseconds(entry.JoinedAtUnixMs).UtcDateTime).TotalSeconds);
}
