using Backend.GameLogic;

namespace Backend.Tests;

public class RankingCalculatorTests
{
    [Fact]
    public void TwoPlayers_EqualMmr_WinnerGainsLoserLosesSameAmount()
    {
        var deltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
        ]);

        Assert.True(deltas[1] > 0);
        Assert.True(deltas[2] < 0);
        Assert.Equal(deltas[1], -deltas[2]);
    }

    [Fact]
    public void TwoPlayers_Underdog_GainsMoreThanEqualMmrWin()
    {
        var equalMmrDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
        ]);

        var underdogDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1200), // 낮은 MMR인데 이김(언더독)
            (UserId: 2, Place: 2, Mmr: 1800),
        ]);

        Assert.True(underdogDeltas[1] > equalMmrDeltas[1]);
    }

    [Fact]
    public void TwoPlayers_Favorite_LosingLosesMoreThanEqualMmrLoss()
    {
        var equalMmrDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
        ]);

        var upsetDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 2, Mmr: 1800), // 높은 MMR인데 짐
            (UserId: 2, Place: 1, Mmr: 1200),
        ]);

        Assert.True(upsetDeltas[1] < equalMmrDeltas[2]);
    }

    [Fact]
    public void FourPlayers_EqualMmr_DeltasOrderedByPlaceAndZeroSum()
    {
        var deltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
            (UserId: 3, Place: 3, Mmr: 1500),
            (UserId: 4, Place: 4, Mmr: 1500),
        ]);

        Assert.True(deltas[1] > deltas[2]);
        Assert.True(deltas[2] > deltas[3]);
        Assert.True(deltas[3] > deltas[4]);

        // 동일 MMR끼리는 pairwise 델타가 정확히 대칭이라 총합이 0이어야 함
        Assert.Equal(0, deltas.Values.Sum());
    }

    [Fact]
    public void FourPlayers_MagnitudeComparableToTwoPlayers()
    {
        var twoPlayerDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
        ]);

        var fourPlayerDeltas = RankingCalculator.CalculateMmrDeltas(
        [
            (UserId: 1, Place: 1, Mmr: 1500),
            (UserId: 2, Place: 2, Mmr: 1500),
            (UserId: 3, Place: 3, Mmr: 1500),
            (UserId: 4, Place: 4, Mmr: 1500),
        ]);

        // 상대별 델타를 평균 내므로 1등이 얻는 폭이 인원수와 무관하게 비슷한 스케일이어야 함
        Assert.InRange(fourPlayerDeltas[1], twoPlayerDeltas[1] - 5, twoPlayerDeltas[1] + 5);
    }
}
