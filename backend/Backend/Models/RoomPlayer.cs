namespace Backend.Models;

public class RoomPlayer
{
    public int Id { get; set; }
    public int RoomId { get; set; }
    public Room Room { get; set; } = null!;
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// null이면 정상 참여 중. 로그아웃/연결 끊김으로 유예 상태에 들어간 시각이 찍혀 있으면
    /// RoomDepartureWorker가 1분 뒤 확정 이탈 처리하고, 그 전에 재접속하면 다시 null로 되돌린다.
    /// </summary>
    public DateTime? DisconnectedAt { get; set; }

    /// <summary>
    /// 일반(캐주얼) 방 대기실에서 방장이 아닌 멤버의 준비 상태. 방장 본인에게는 의미 없다
    /// (항상 시작 주체). 게임이 끝나고 방이 다시 Waiting으로 돌아가면 전원 초기화된다.
    /// </summary>
    public bool IsReady { get; set; }
}
