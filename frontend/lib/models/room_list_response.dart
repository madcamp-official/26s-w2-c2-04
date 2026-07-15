// GET /rooms 응답을 파싱하는 모델. gameroom.dart의 GameRoom은 방 하나만
// 표현하므로, 페이지네이션 정보(total/page)까지 포함한 목록 응답은 이 wrapper로 감쌉니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'gameroom.dart';

part 'room_list_response.freezed.dart';
part 'room_list_response.g.dart';

@freezed
class RoomListResponse with _$RoomListResponse {
  const factory RoomListResponse({
    @Default([]) List<GameRoom> rooms,
    @Default(0) int total,
    @Default(1) int page,
  }) = _RoomListResponse;

  factory RoomListResponse.fromJson(Map<String, dynamic> json) =>
      _$RoomListResponseFromJson(json);
}
