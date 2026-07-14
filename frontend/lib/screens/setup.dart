import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';
import 'create_room.dart';
import 'matchmaking.dart';
import 'play.dart';
import 'rooms.dart';

enum _GameMode { normal, ranked }

enum _JoinMethod { random, create, join }

/// "Game setup" 단계. 모드(일반/랭크) -> (일반이면) 입장 방식(랜덤/생성/참가) ->
/// 인원수를 순서대로 고르고, 완료되면 다음 화면으로 넘어갑니다.
/// Main page design/App.tsx의 layer === "setup" 화면에 대응합니다.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  _GameMode? _mode;
  _JoinMethod? _method;
  int? _players;
  bool _matchingRandom = false;

  bool get _complete => _mode == _GameMode.ranked ? _players != null : (_method != null && _players != null);

  Future<void> _enter() async {
    switch (_mode) {
      case _GameMode.ranked:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MatchmakingScreen(players: _players!)),
        );
      case _GameMode.normal:
        switch (_method) {
          case _JoinMethod.join:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RoomsScreen(players: _players!)),
            );
          case _JoinMethod.create:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CreateRoomScreen(players: _players!)),
            );
          case _JoinMethod.random:
            await _enterRandomTable();
          case null:
            break;
        }
      case null:
        break;
    }
  }

  /// "랜덤 매칭"용 전용 백엔드 API는 아직 없어서, 대기 중인 방 목록에서 빈 자리가
  /// 있는 공개방을 찾아 바로 참가하고, 없으면 새로 만들어 대기실로 들어갑니다.
  Future<void> _enterRandomTable() async {
    setState(() => _matchingRandom = true);
    try {
      final roomService = ref.read(roomServiceProvider);
      final list = await roomService.listRooms(limit: 100);
      final candidate = list.rooms.where(
        (r) => r.maxPlayers == _players && !r.isPrivate && r.players.length < r.maxPlayers,
      ).firstOrNull;

      final room = candidate != null
          ? await roomService.joinRoom(candidate.roomId)
          : await roomService.createRoom(maxPlayers: _players!);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlayScreen(room: room)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _matchingRandom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GAME SETUP')),
      body: GemBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              children: [
                const OrnateTitle(kicker: 'Multiplayer', title: '게임 설정'),
                const SizedBox(height: 32),
                _ChoiceGroup<_GameMode>(
                  label: '모드를 선택하세요',
                  selected: _mode,
                  options: const [
                    _ChoiceOption(
                      value: _GameMode.normal,
                      title: '일반 시장',
                      subtitle: '내 페이스대로 즐기기',
                      icon: Icons.groups_outlined,
                    ),
                    _ChoiceOption(
                      value: _GameMode.ranked,
                      title: '경쟁 길드',
                      subtitle: 'MMR과 등급을 겨루기',
                      icon: Icons.shield_outlined,
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _mode = v;
                    _method = null;
                  }),
                ),
                if (_mode == _GameMode.normal) ...[
                  const SizedBox(height: 24),
                  _ChoiceGroup<_JoinMethod>(
                    label: '어떻게 입장할까요?',
                    selected: _method,
                    options: const [
                      _ChoiceOption(
                        value: _JoinMethod.random,
                        title: '랜덤 매칭',
                        subtitle: '즉시 테이블 찾기',
                        icon: Icons.shuffle,
                      ),
                      _ChoiceOption(
                        value: _JoinMethod.create,
                        title: '방 만들기',
                        subtitle: '내가 테이블 열기',
                        icon: Icons.add,
                      ),
                      _ChoiceOption(
                        value: _JoinMethod.join,
                        title: '방 참가',
                        subtitle: '열린 테이블 둘러보기',
                        icon: Icons.login,
                      ),
                    ],
                    onChanged: (v) => setState(() => _method = v),
                  ),
                ],
                if (_mode != null && (_mode == _GameMode.ranked || _method != null)) ...[
                  const SizedBox(height: 24),
                  _ChoiceGroup<int>(
                    label: '인원수',
                    compact: true,
                    selected: _players,
                    options: const [
                      _ChoiceOption(value: 2, title: '2명', subtitle: '짧은 대결', icon: Icons.bolt),
                      _ChoiceOption(value: 3, title: '3명', subtitle: '균형 잡힌 시장', icon: Icons.groups_outlined),
                      _ChoiceOption(value: 4, title: '4명', subtitle: '거대한 교역', icon: Icons.groups),
                    ],
                    onChanged: (v) => setState(() => _players = v),
                  ),
                ],
                if (_complete) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _matchingRandom ? null : _enter,
                      child: _matchingRandom
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : const Text('ENTER THE MARKET'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceOption<T> {
  final T value;
  final String title;
  final String subtitle;
  final IconData icon;
  const _ChoiceOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ChoiceGroup<T> extends StatelessWidget {
  final String label;
  final List<_ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final bool compact;

  const _ChoiceGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kickerStyle(size: 11)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: compact ? 3 : (options.length == 3 ? 3 : 2),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: compact ? 0.95 : 1.5,
          children: [
            for (final option in options)
              _ChoiceTile(
                option: option,
                selected: selected == option.value,
                onTap: () => onChanged(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceTile<T> extends StatelessWidget {
  final _ChoiceOption<T> option;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceTile({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: selected ? AppColors.goldFaint.withValues(alpha: 0.14) : null,
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.goldHairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, size: 18, color: selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.55)),
            const SizedBox(height: 8),
            Text(option.title, style: headingStyle(size: 12)),
            const SizedBox(height: 4),
            Text(
              option.subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
