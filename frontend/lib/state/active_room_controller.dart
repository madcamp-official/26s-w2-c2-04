// 게임 시작 전 참가 중인 방을 앱 전역에서 기억해두는 상태.
// PlayScreen을 벗어나도(뒤로가기) 이 값이 남아있는 동안은 main.dart가
// 좌하단에 "방으로 돌아가기" 배지를 띄운다. 게임이 시작되거나 명시적으로
// 방을 나가면 null로 비워 배지를 없앤다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gameroom.dart';

final activeRoomProvider = StateProvider<GameRoom?>((ref) => null);
