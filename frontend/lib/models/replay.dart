// GET /replay/{gameId} 응답을 파싱하는 모델.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'game_state.dart';

part 'replay.freezed.dart';
part 'replay.g.dart';

@freezed
class ReplayAction with _$ReplayAction {
  const factory ReplayAction({
    required int turnNumber,
    required int playerId,
    required String actionType, // 예: TAKE_TOKENS, PURCHASE_CARD, RESERVE_CARD ...
    @Default({}) Map<String, dynamic> actionPayload,
  }) = _ReplayAction;

  factory ReplayAction.fromJson(Map<String, dynamic> json) =>
      _$ReplayActionFromJson(json);
}

extension ReplayActionState on ReplayAction {
  // actionPayload.currentState에 담긴 그 시점의 전체 게임 상태(있을 때만)
  GameState? get currentState {
    final raw = actionPayload['currentState'];
    if (raw is! Map<String, dynamic>) return null;
    return GameState.fromJson(raw);
  }
}

@freezed
class ReplayResponse with _$ReplayResponse {
  const factory ReplayResponse({
    @Default([]) List<ReplayAction> actions,
    @Default(0) int actionsTotal,
  }) = _ReplayResponse;

  factory ReplayResponse.fromJson(Map<String, dynamic> json) =>
      _$ReplayResponseFromJson(json);
}
