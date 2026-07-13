using Backend.GameLogic;

namespace Backend.Tests;

public class MatchmakingGrouperTests
{
    private static QueueEntry Entry(int userId, int mmr, double secondsAgo) =>
        new(userId, mmr, DateTimeOffset.UtcNow.AddSeconds(-secondsAgo).ToUnixTimeMilliseconds());

    [Fact]
    public void NotEnoughPlayers_NoGroupFormed()
    {
        var entries = new List<QueueEntry> { Entry(1, 1500, 0), Entry(2, 1500, 0) };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 3, DateTime.UtcNow);

        Assert.Empty(groups);
    }

    [Fact]
    public void SimilarMmr_GroupsImmediately()
    {
        var entries = new List<QueueEntry>
        {
            Entry(1, 1500, 0),
            Entry(2, 1520, 0),
            Entry(3, 1480, 0),
        };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 3, DateTime.UtcNow);

        Assert.Single(groups);
        Assert.Equal(3, groups[0].Count);
    }

    [Fact]
    public void FarApartMmr_DoesNotGroupWhileWaitIsShort()
    {
        var entries = new List<QueueEntry> { Entry(1, 1000, 0), Entry(2, 2000, 0) };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 2, DateTime.UtcNow);

        Assert.Empty(groups);
    }

    [Fact]
    public void FarApartMmr_GroupsOnceLongWaitExpandsRange()
    {
        var entries = new List<QueueEntry>
        {
            Entry(1, 1000, secondsAgo: 300), // 오래 대기해서 탐색 범위가 넓어진 상태
            Entry(2, 2000, secondsAgo: 0),
        };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 2, DateTime.UtcNow);

        Assert.Single(groups);
    }

    [Fact]
    public void PicksClosestMmrCandidateOverFartherOne()
    {
        var entries = new List<QueueEntry>
        {
            Entry(1, 1500, 0), // 앵커(가장 먼저 큐에 들어옴)
            Entry(2, 1900, 0), // 멀리 떨어짐 - 초기 범위 밖
            Entry(3, 1550, 0), // 가까움 - 초기 범위 안
        };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 2, DateTime.UtcNow);

        Assert.Single(groups);
        Assert.Contains(groups[0], e => e.UserId == 1);
        Assert.Contains(groups[0], e => e.UserId == 3);
        Assert.DoesNotContain(groups[0], e => e.UserId == 2);
    }

    [Fact]
    public void MultipleCompatibleGroups_AllGetFormed()
    {
        var entries = new List<QueueEntry>
        {
            Entry(1, 1500, 0),
            Entry(2, 1510, 0),
            Entry(3, 3000, 0),
            Entry(4, 3010, 0),
        };

        var groups = MatchmakingGrouper.FindGroups(entries, groupSize: 2, DateTime.UtcNow);

        Assert.Equal(2, groups.Count);
        Assert.All(groups, g => Assert.Equal(2, g.Count));
    }
}
