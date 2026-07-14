// 게임 시작 전 참가 중인 방을 앱 전역에서 기억해두는 상태.
// PlayScreen을 벗어나도(뒤로가기) 이 값이 남아있는 동안은 main.dart가
// 좌하단에 "방으로 돌아가기" 배지를 띄운다. 게임이 시작되거나 명시적으로
// 방을 나가면 null로 비워 배지를 없앤다.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gameroom.dart';

final activeRoomProvider = StateProvider<GameRoom?>((ref) => null);

/// 현재 PlayScreen이 화면 맨 위에 떠 있는지(=Navigator에 mount된 상태인지) 여부.
/// 배지는 activeRoomProvider가 채워져 있어도 이 값이 true인 동안은(즉 이미 그
/// 방 화면을 보고 있는 동안은) 숨어야 한다 — 그렇지 않으면 배지가 자기 자신이
/// 띄운 화면 위에 계속 겹쳐 보이고, 다시 눌러 중복 push를 유발한다.
///
/// true로 켜는 건 PlayScreen.initState, false로 끄는 건 PlayScreen이
/// [playRouteObserver]로 구독하는 RouteAware.didPop이다 — pop이 "시작"되는
/// 순간 Navigator가 동기적으로 호출해주므로, pop 애니메이션이 끝난 뒤에나
/// 실행되는(그리고 teardown 과정의 사정에 따라 누락될 수 있는) dispose에
/// 의존하지 않는다.
final roomScreenVisibleProvider = StateProvider<bool>((ref) => false);

/// PlayScreen이 자신의 라우트 pop을 감지하는 데 쓰는 전역 RouteObserver.
/// main.dart의 MaterialApp.navigatorObservers에 등록된다.
final playRouteObserver = RouteObserver<ModalRoute<void>>();
