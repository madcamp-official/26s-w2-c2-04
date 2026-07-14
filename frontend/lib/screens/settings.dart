import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 설정 화면. README 구현명세서의 "음성/그래픽/기타/편의 기능" 항목은 백엔드나
/// 로컬 저장이 아직 없어서, 이 화면은 로컬 위젯 상태로만 토글을 보여줍니다
/// (재시작하면 초기화됩니다). 실제 영속화는 서버/로컬 스토리지 설계가 정해지면 붙입니다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _reducedMotion = false;
  bool _showEmotes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: GemBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const OrnateTitle(kicker: 'Preferences', title: '설정'),
              const SizedBox(height: 24),
              const _SectionLabel('사운드'),
              SwitchListTile(
                title: const Text('효과음'),
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              SwitchListTile(
                title: const Text('배경음악'),
                value: _musicEnabled,
                onChanged: (v) => setState(() => _musicEnabled = v),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('그래픽 / 편의'),
              SwitchListTile(
                title: const Text('애니메이션 최소화'),
                subtitle: const Text('보석 파티클 등 장식 효과를 줄입니다'),
                value: _reducedMotion,
                onChanged: (v) => setState(() => _reducedMotion = v),
              ),
              SwitchListTile(
                title: const Text('인게임 이모트 표시'),
                value: _showEmotes,
                onChanged: (v) => setState(() => _showEmotes = v),
              ),
              const SizedBox(height: 24),
              Text(
                '이 설정은 현재 기기에서만 임시로 적용되며, 앱을 다시 시작하면 초기화됩니다.',
                style: kickerStyle(size: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text.toUpperCase(), style: kickerStyle(size: 11)),
    );
  }
}
