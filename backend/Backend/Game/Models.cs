namespace Backend.GameLogic;

public enum GemType
{
    Diamond,
    Sapphire,
    Emerald,
    Ruby,
    Onyx,
    Gold,
}

public record Card(
    string Id,
    int Tier,
    int Points,
    GemType Bonus,
    Dictionary<GemType, int> Cost);

public record Noble(
    string Id,
    int Points,
    Dictionary<GemType, int> Requirement);
