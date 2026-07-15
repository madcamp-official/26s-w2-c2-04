import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';
import 'play.dart';

/// 랭크 매칭 대기 화면. POST /matchmaking/{playerCount}/ranked를 백그라운드로
/// 호출하는 동안 Main page design/App.tsx의 MatchmakingScreen과 같은 느낌의
/// 탐색 애니메이션을 보여줍니다. 응답이 오면(최소 노출 시간을 채운 뒤) 곧바로
/// GameHub에 연결되는 게임 화면으로 넘어갑니다 — 방 목록/참가 같은 "방" UI는
/// 거치지 않습니다.
class MatchmakingScreen extends ConsumerStatefulWidget {
  final int players;
  const MatchmakingScreen({super.key, required this.players});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  static const _minimumDisplay = Duration(milliseconds: 1200);

  late final AnimationController _spinController;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _startMatching();
  }

  Future<void> _startMatching() async {
    final started = DateTime.now();
    try {
      final room = await ref.read(roomServiceProvider).rankedMatch(
            widget.players,
            isCancelled: () => _cancelled,
          );
      final elapsed = DateTime.now().difference(started);
      if (elapsed < _minimumDisplay) {
        await Future.delayed(_minimumDisplay - elapsed);
      }
      if (!mounted || _cancelled) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PlayScreen(room: room, autoConnect: true)),
      );
    } catch (e) {
      if (!mounted || _cancelled) return;
      // 매칭이 실패했는데도 경과 시간 타이머/스피너가 계속 돌면 "아직 찾는 중"
      // 처럼 보인다 — 실패를 보여줄 때는 반드시 멈춘다.
      _elapsedTimer?.cancel();
      _spinController.stop();
      setState(() => _error = '$e');
    }
  }

  Future<void> _cancelSearch() async {
    _cancelled = true;
    _elapsedTimer?.cancel();
    _spinController.stop();
    try {
      // 화면을 벗어나는 것 자체는 이 요청 성패와 무관하게 항상 허용한다 —
      // 대기열 정리는 베스트 에포트.
      await ref.read(roomServiceProvider).cancelRankedMatch(widget.players);
    } catch (_) {
      // 무시: 애초에 대기열에 없었거나(이미 매칭/오류) 네트워크 문제일 수 있음.
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _cancelled = true;
    _spinController.dispose();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String get _mm => (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
  String get _ss => (_elapsedSeconds % 60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GemBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _spinController,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.goldFaint, width: 2),
                          ),
                        ),
                      ),
                      const Icon(Icons.shield_outlined, size: 32, color: AppColors.gold),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('RANKED · ${widget.players} PLAYERS', style: kickerStyle(size: 11)),
                const SizedBox(height: 8),
                Text(
                  _error != null ? '매칭 실패' : 'Searching for a table…',
                  style: headingStyle(size: 18),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: 'Elapsed', value: '$_mm:$_ss'),
                    _Stat(label: 'Players', value: '${widget.players}'),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: _cancelSearch,
                  child: const Text('CANCEL SEARCH'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: AppColors.panelAlt,
      child: Column(
        children: [
          Text(value, style: headingStyle(size: 14)),
          const SizedBox(height: 4),
          Text(label, style: kickerStyle(size: 9)),
        ],
      ),
    );
  }
}
