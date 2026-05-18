import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class PulseColors extends ThemeExtension<PulseColors> {
  const PulseColors({
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.surface,
    required this.surfaceStrong,
    required this.line,
    required this.cyan,
    required this.mint,
    required this.coral,
    required this.amber,
    required this.danger,
    required this.success,
  });

  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color surface;
  final Color surfaceStrong;
  final Color line;
  final Color cyan;
  final Color mint;
  final Color coral;
  final Color amber;
  final Color danger;
  final Color success;

  static const dark = PulseColors(
    ink: Color(0xFFF7FBFF),
    inkMuted: Color(0xFFB8C9D5),
    inkSubtle: Color(0xFF7F95A3),
    surface: Color(0xCC081522),
    surfaceStrong: Color(0xE60E2232),
    line: Color(0x2EFFFFFF),
    cyan: Color(0xFF5EE7DF),
    mint: Color(0xFF7EF7A6),
    coral: Color(0xFFFF8A8A),
    amber: Color(0xFFFFC857),
    danger: Color(0xFFFF4D67),
    success: Color(0xFF35D985),
  );

  @override
  PulseColors copyWith({
    Color? ink,
    Color? inkMuted,
    Color? inkSubtle,
    Color? surface,
    Color? surfaceStrong,
    Color? line,
    Color? cyan,
    Color? mint,
    Color? coral,
    Color? amber,
    Color? danger,
    Color? success,
  }) {
    return PulseColors(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      line: line ?? this.line,
      cyan: cyan ?? this.cyan,
      mint: mint ?? this.mint,
      coral: coral ?? this.coral,
      amber: amber ?? this.amber,
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
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      line: Color.lerp(line, other.line, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension PulseThemeX on BuildContext {
  PulseColors get pulse => Theme.of(this).extension<PulseColors>()!;
}

abstract final class PulseRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const pill = 99.0;
}

abstract final class PulseGradients {
  static const app = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07111F), Color(0xFF12343B), Color(0xFF1D3326)],
  );

  static const call = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF07111F), Color(0xFF0D2A35), Color(0xFF15261D)],
  );

  static const action = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5EE7DF), Color(0xFF7EF7A6)],
  );
}

class PulseTheme {
  const PulseTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PulseColors.dark.cyan,
      brightness: Brightness.dark,
      primary: PulseColors.dark.cyan,
      secondary: PulseColors.dark.mint,
      error: PulseColors.dark.danger,
      surface: const Color(0xFF0B1721),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
      extensions: const [PulseColors.dark],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: PulseColors.dark.ink,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: PulseColors.dark.ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: PulseColors.dark.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: PulseColors.dark.inkMuted),
        bodySmall: TextStyle(color: PulseColors.dark.inkSubtle),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PulseColors.dark.surface,
        labelStyle: TextStyle(color: PulseColors.dark.inkMuted),
        hintStyle: TextStyle(color: PulseColors.dark.inkSubtle),
        prefixIconColor: PulseColors.dark.inkMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.md),
          borderSide: BorderSide(color: PulseColors.dark.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulseRadius.md),
          borderSide: BorderSide(color: PulseColors.dark.cyan, width: 1.3),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: const Color(0xFF041017),
          backgroundColor: PulseColors.dark.cyan,
          disabledBackgroundColor: PulseColors.dark.surfaceStrong,
          disabledForegroundColor: PulseColors.dark.inkSubtle,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulseRadius.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PulseColors.dark.surface,
        selectedColor: PulseColors.dark.cyan.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: PulseColors.dark.inkMuted),
        secondaryLabelStyle: TextStyle(
          color: PulseColors.dark.ink,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: PulseColors.dark.cyan,
        side: BorderSide(color: PulseColors.dark.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulseRadius.pill),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF061118)
                : PulseColors.dark.inkMuted,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? PulseColors.dark.cyan
                : PulseColors.dark.surface,
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: PulseColors.dark.line),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PulseColors.dark.cyan
              : PulseColors.dark.inkSubtle,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PulseColors.dark.cyan.withValues(alpha: 0.28)
              : PulseColors.dark.surfaceStrong,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PulseColors.dark.ink,
          disabledForegroundColor: PulseColors.dark.inkSubtle,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0E1B26).withValues(alpha: 0.96),
        contentTextStyle: TextStyle(color: PulseColors.dark.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulseRadius.md),
        ),
      ),
    );
  }
}

class PulseBackground extends StatefulWidget {
  const PulseBackground({
    super.key,
    required this.child,
    this.gradient = PulseGradients.app,
    this.blurImageAsset,
    this.blurImageOpacity = 0.0,
  });

  final Widget child;
  final Gradient gradient;
  final String? blurImageAsset;
  final double blurImageOpacity;

  @override
  State<PulseBackground> createState() => _PulseBackgroundState();
}

class _PulseBackgroundState extends State<PulseBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: widget.gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = _controller.value;
              return Stack(
                fit: StackFit.expand,
                children: [
                  _AuroraGlow(
                    alignment: Alignment(-0.9 + value * 0.35, -0.86),
                    color: pulse.cyan,
                    size: 330,
                    opacity: 0.14,
                  ),
                  _AuroraGlow(
                    alignment: Alignment(0.84, -0.34 + value * 0.28),
                    color: pulse.mint,
                    size: 280,
                    opacity: 0.12,
                  ),
                  _AuroraGlow(
                    alignment: Alignment(-0.25 + value * 0.22, 0.92),
                    color: pulse.coral,
                    size: 260,
                    opacity: 0.08,
                  ),
                ],
              );
            },
          ),
          if (widget.blurImageAsset != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Image.asset(
                widget.blurImageAsset!,
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(widget.blurImageOpacity),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraGlow extends StatelessWidget {
  const _AuroraGlow({
    required this.alignment,
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class PulseGlassPanel extends StatelessWidget {
  const PulseGlassPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return ClipRRect(
      borderRadius: BorderRadius.circular(PulseRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: pulse.surface,
            borderRadius: BorderRadius.circular(PulseRadius.lg),
            border: Border.all(color: pulse.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class PulseSectionTitle extends StatelessWidget {
  const PulseSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: pulse.surfaceStrong,
            borderRadius: BorderRadius.circular(PulseRadius.sm),
            border: Border.all(color: pulse.line),
          ),
          child: Icon(icon, color: pulse.cyan, size: 19),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
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
    this.borderRadius = PulseRadius.md,
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
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
