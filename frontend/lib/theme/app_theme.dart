// "길드의 보석 상인" 컨셉 다크/골드 테마.
// Main page design/ 목업(App.tsx)의 색상·톤을 Flutter 위젯 스타일로 옮긴 것입니다.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF08050A);
  static const panel = Color(0xFF100B13);
  static const panelAlt = Color(0xFF130D19);
  static const surface = Color(0xFF1A1420);

  static const gold = Color(0xFFD2AE55);
  static const goldBright = Color(0xFFF0CF76);
  static const goldFaint = Color(0x40D2AE55); // ~25% opacity
  static const goldHairline = Color(0x26D2AE55); // ~15% opacity

  static const textHeading = Color(0xFFF6E6BD);
  static const textPrimary = Color(0xFFF5EAD4);
  static const textMuted = Color(0xFFD7C8AA);

  static const emerald = Color(0xFF4CA879);
  static const ruby = Color(0xFFBD3045);
  static const sapphire = Color(0xFF357FC7);
  static const amethyst = Color(0xFF8D58A1);

  static const success = Color(0xFF76D09C);
  static const danger = Color(0xFFE3737F);
}

/// 카드/아바타 톤 배정을 방/유저 이름 해시로 결정할 때 씁니다.
const List<Color> avatarTones = [
  Color(0xFF762034),
  Color(0xFF1B7058),
  Color(0xFF315786),
  Color(0xFF4E4655),
  Color(0xFF80582A),
  Color(0xFF34213F),
];

Color avatarToneFor(String seed) =>
    avatarTones[seed.isEmpty ? 0 : seed.codeUnitAt(0) % avatarTones.length];

/// 헤더/타이틀에 쓰는 넓은 자간의 대문자 스타일 (Cinzel 계열 느낌의 대체).
TextStyle headingStyle({
  double size = 20,
  Color color = AppColors.textHeading,
  FontWeight weight = FontWeight.w700,
  double letterSpacing = 2.2,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    color: color,
    height: 1.2,
  );
}

/// 부제/캡션에 쓰는 넓은 자간의 소문자 스타일 (Lato 계열 느낌의 대체).
TextStyle kickerStyle({
  double size = 11,
  Color color = const Color(0xFFAF9868),
  double letterSpacing = 3,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: letterSpacing,
    color: color,
  );
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.gold,
    onPrimary: Color(0xFF160D13),
    secondary: AppColors.sapphire,
    onSecondary: AppColors.textPrimary,
    surface: AppColors.panel,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: Color(0xFF160D13),
  );

  final baseTextTheme = ThemeData.dark().textTheme;
  final textTheme = baseTextTheme.copyWith(
    titleLarge: headingStyle(size: 22),
    titleMedium: headingStyle(size: 16, letterSpacing: 1.6),
    titleSmall: headingStyle(size: 13, letterSpacing: 1.4),
    bodyLarge: const TextStyle(color: AppColors.textPrimary),
    bodyMedium: const TextStyle(color: AppColors.textPrimary),
    bodySmall: const TextStyle(color: AppColors.textMuted),
    labelLarge: const TextStyle(
      color: AppColors.gold,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
    ),
  );

  const outlineInput = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: AppColors.goldHairline),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    dividerColor: AppColors.goldHairline,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textHeading,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: AppColors.textHeading,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.panelAlt,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.goldHairline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      titleTextStyle: headingStyle(size: 17),
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: const Color(0xFF160D13),
        disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.25),
        disabledForegroundColor: const Color(0xFF160D13).withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.goldFaint),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.6),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.gold),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.panelAlt,
      border: outlineInput,
      enabledBorder: outlineInput,
      focusedBorder: outlineInput.copyWith(
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      errorBorder: outlineInput.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      labelStyle: kickerStyle(size: 12, color: AppColors.gold.withValues(alpha: 0.75)),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.goldBright
            : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.goldFaint
            : AppColors.panelAlt,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.goldHairline),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.gold,
      unselectedLabelColor: AppColors.textMuted,
      indicatorColor: AppColors.gold,
      labelStyle: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.panelAlt,
      side: BorderSide(color: AppColors.goldHairline),
      labelStyle: TextStyle(color: AppColors.gold, fontSize: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.gold,
      textColor: AppColors.textPrimary,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.panelAlt,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.goldHairline),
      ),
    ),
  );
}

/// 화면 상단에 반복적으로 쓰이는 "SPLENDOR" 톤의 장식 제목.
class OrnateTitle extends StatelessWidget {
  final String title;
  final String? kicker;
  const OrnateTitle({super.key, required this.title, this.kicker});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (kicker != null) ...[
          Text(kicker!.toUpperCase(), style: kickerStyle()),
          const SizedBox(height: 8),
        ],
        Text(title, style: headingStyle(size: 24), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 1, color: AppColors.goldFaint),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.auto_awesome, size: 14, color: AppColors.goldFaint),
            ),
            Container(width: 44, height: 1, color: AppColors.goldFaint),
          ],
        ),
      ],
    );
  }
}

/// 폼류 화면(로그인/회원가입/설정 등)에서 쓰는, 스크롤 대신 "통째로 축소"해서
/// 항상 화면 안에 들어오게 하는 컨테이너. 기기 글꼴 배율이 크거나 화면이 작아
/// 콘텐츠가 세로로 넘치면, 잘려서 안 보이거나 스크롤해야 하는 대신 가로·세로
/// 비율을 유지한 채 통째로 줄어들어 항상 한 화면에 다 보인다.
class ScaleToFitForm extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;

  const ScaleToFitForm({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                // FittedBox는 자식 크기를 잴 때 제약을 무한대로 풀어버리므로,
                // 실제 화면 너비로 다시 못 박아줘야 TextField 등이 정상적으로
                // 자기 너비를 계산할 수 있다(안 그러면 무한 너비 오류가 난다).
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Padding(
                  padding: padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 다크 패널 배경 위의 은은한 방사형 하이라이트 배경.
class GemBackdrop extends StatelessWidget {
  final Widget child;
  const GemBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.1,
          colors: [Color(0xFF241322), AppColors.background],
        ),
      ),
      child: child,
    );
  }
}
