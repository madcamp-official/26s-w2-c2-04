import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';
import 'play.dart';

/// "Create room" 단계. setup.dart에서 이미 정해진 인원수로 방을 만듭니다.
/// Main page design/App.tsx의 layer === "create" 화면에 대응합니다.
///
/// 방 이름은 백엔드 Room 모델에 저장되는 필드가 아니라(RoomResponse에 name이 없음),
/// 이 기기에서만 보여줄 표시용 라벨입니다. 실제 방 식별은 roomId로 이뤄집니다.
class CreateRoomScreen extends ConsumerStatefulWidget {
  final int players;
  const CreateRoomScreen({super.key, required this.players});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController(text: '새로운 보석 상회');
  final _passwordController = TextEditingController();
  bool _isPrivate = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_isPrivate && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final room = await ref.read(lobbyControllerProvider.notifier).createRoom(
            maxPlayers: widget.players,
            isPrivate: _isPrivate,
            password: _isPrivate ? _passwordController.text : null,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlayScreen(room: room, localLabel: _nameController.text),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: '설정으로 돌아가기',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('CREATE ROOM'),
      ),
      body: GemBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                const OrnateTitle(kicker: 'Host a table', title: '방 만들기'),
                const SizedBox(height: 28),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '테이블 이름 (이 기기에만 표시)'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.goldHairline)),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_outlined, size: 18),
                      const SizedBox(width: 12),
                      Text('${widget.players}인 테이블', style: headingStyle(size: 14)),
                      const Spacer(),
                      Text('SETUP에서 선택됨', style: kickerStyle(size: 9)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('비공개 방으로 설정'),
                  value: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                ),
                if (_isPrivate) ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _create,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text('CREATE YOUR TABLE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
