import 'package:flutter/material.dart';

@immutable
class PulseColors extends ThemeExtension<PulseColors> {
  const PulseColors({
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.surfaceSubtle,
    required this.line,
    required this.cyan,
    required this.mint,
    required this.coral,
    required this.amber,
    required this.purple,
    required this.danger,
    required this.success,
  });

  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color surfaceSubtle;
  final Color line;
  final Color cyan;
  final Color mint;
  final Color coral;
  final Color amber;
  final Color purple;
  final Color danger;
  final Color success;

  static const dark = PulseColors(
    ink: Color(0xFFF8FAFC),
    inkMuted: Color(0xFF94A3B8),
    inkSubtle: Color(0xFF64748B),
    background: Color(0xFF04070D),
    surface: Color(0xFF0C121D),
    surfaceStrong: Color(0xFF141C2B),
    surfaceSubtle: Color(0xFF070B12),
    line: Color(0xFF1A2333),
    cyan: Color(0xFF38BDF8),
    mint: Color(0xFF10B981),
    coral: Color(0xFFF43F5E),
    amber: Color(0xFFF59E0B),
    purple: Color(0xFFA855F7),
    danger: Color(0xFFEF4444),
    success: Color(0xFF10B981),
  );

  @override
  PulseColors copyWith({
    Color? ink,
    Color? inkMuted,
    Color? inkSubtle,
    Color? background,
    Color? surface,
    Color? surfaceStrong,
    Color? surfaceSubtle,
    Color? line,
    Color? cyan,
    Color? mint,
    Color? coral,
    Color? amber,
    Color? purple,
    Color? danger,
    Color? success,
  }) {
    return PulseColors(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      line: line ?? this.line,
      cyan: cyan ?? this.cyan,
      mint: mint ?? this.mint,
      coral: coral ?? this.coral,
      amber: amber ?? this.amber,
      purple: purple ?? this.purple,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  PulseColors lerp(ThemeExtension<PulseColors>? other, double t) {
    if (other is! PulseColors) return this;
    return PulseColors(
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkSubtle: Color.lerp(inkSubtle, other.inkSubtle, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      line: Color.lerp(line, other.line, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension PulseThemeX on BuildContext {
  PulseColors get pulse =>
      Theme.of(this).extension<PulseColors>() ?? PulseColors.dark;
}

abstract final class PulseRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class PulseSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

class PulseTheme {
  const PulseTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF38BDF8),
      brightness: Brightness.dark,
      primary: const Color(0xFF38BDF8),
      secondary: const Color(0xFF10B981),
      error: const Color(0xFFEF4444),
      surface: const Color(0xFF0C121D),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF04070D),
      extensions: const [PulseColors.dark],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF141C2B),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13.5,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0C121D),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        prefixIconColor: const Color(0xFF38BDF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.sm),
          borderSide: const BorderSide(color: Color(0xFF141C2B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.sm),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: const Color(0xFF040810),
          backgroundColor: const Color(0xFF38BDF8),
          disabledBackgroundColor: const Color(0xFF141C2B),
          disabledForegroundColor: const Color(0xFF64748B),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulseRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFF64748B),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF38BDF8)
              : const Color(0xFF141C2B),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF05080E),
        indicatorColor: const Color(0xFF38BDF8).withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF38BDF8)
                : const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF38BDF8)
                : const Color(0xFF64748B),
            size: 22,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF141C2B),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulseRadius.sm),
          side: const BorderSide(color: Color(0xFF1A2333)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class PulseBackground extends StatelessWidget {
  const PulseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF04070D),
      child: child,
    );
  }
}

/// Clean Inset Grouped Container for iOS/Nothing-OS style settings sections.
/// Replaces all bulky card panels.
class PulseInsetGroup extends StatelessWidget {
  const PulseInsetGroup({
    super.key,
    required this.children,
    this.title,
  });

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                color: pulse.inkSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: pulse.surface,
            borderRadius: BorderRadius.circular(PulseRadius.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PulseRadius.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class PulsePressable extends StatefulWidget {
  const PulsePressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 10.0,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  State<PulsePressable> createState() => _PulsePressableState();
}

class _PulsePressableState extends State<PulsePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.8 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
