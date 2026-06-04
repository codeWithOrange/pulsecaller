import 'dart:math' as math;
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
    surface: Color(0xD60A131C),
    surfaceStrong: Color(0xF0101E2A),
    line: Color(0x24FFFFFF),
    cyan: Color(0xFF67E8F9),
    mint: Color(0xFF86EFAC),
    coral: Color(0xFFFB7185),
    amber: Color(0xFFFBBF24),
    danger: Color(0xFFFF4D67),
    success: Color(0xFF22C55E),
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
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 8.0;
  static const pill = 99.0;
}

abstract final class PulseGradients {
  static const app = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF03070B),
      Color(0xFF09131A),
      Color(0xFF0B1F22),
      Color(0xFF111016),
    ],
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
          fontSize: 32,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: PulseColors.dark.ink,
          fontSize: 22,
          fontWeight: FontWeight.w900,
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
          foregroundColor: const Color(0xFF031016),
          backgroundColor: PulseColors.dark.cyan,
          disabledBackgroundColor: PulseColors.dark.surfaceStrong,
          disabledForegroundColor: PulseColors.dark.inkSubtle,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulseRadius.sm),
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
      duration: const Duration(seconds: 14),
    )..repeat();
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
            builder: (context, _) => CustomPaint(
              painter: _PulseBackdropPainter(
                progress: _controller.value,
                line: pulse.line,
                cyan: pulse.cyan,
                coral: pulse.coral,
              ),
            ),
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

class _PulseBackdropPainter extends CustomPainter {
  const _PulseBackdropPainter({
    required this.progress,
    required this.line,
    required this.cyan,
    required this.coral,
  });

  final double progress;
  final Color line;
  final Color cyan;
  final Color coral;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final topLight = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          -0.72 + math.sin(progress * math.pi * 2) * 0.08,
          -0.92 + math.cos(progress * math.pi * 2) * 0.04,
        ),
        radius: 0.86,
        colors: [
          cyan.withValues(alpha: 0.18),
          cyan.withValues(alpha: 0.055),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, topLight);

    final sideLight = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.92,
          -0.2 + math.sin(progress * math.pi * 2 + 1.2) * 0.12,
        ),
        radius: 0.72,
        colors: [
          coral.withValues(alpha: 0.11),
          coral.withValues(alpha: 0.032),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, sideLight);

    final diagonalSheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.08 + progress * 0.54, -0.82),
        end: Alignment(0.42 + progress * 0.54, 1.0),
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.035),
          cyan.withValues(alpha: 0.045),
          Colors.transparent,
        ],
        stops: const [0.08, 0.42, 0.58, 0.92],
      ).createShader(rect);
    canvas.drawRect(rect, diagonalSheen);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = line.withValues(alpha: 0.18);
    for (var index = 0; index < 5; index++) {
      final inset = 42.0 + index * 74;
      final drift = math.sin(progress * math.pi * 2 + index) * 14;
      final path = Path()
        ..moveTo(-30, size.height * 0.18 + index * 58 + drift)
        ..cubicTo(
          size.width * 0.32,
          inset,
          size.width * 0.55,
          size.height - inset,
          size.width + 34,
          size.height * 0.38 + index * 38 - drift,
        );
      canvas.drawPath(path, linePaint);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = cyan.withValues(alpha: 0.055);
    for (var index = 0; index < 3; index++) {
      final phase = (progress + index / 3) % 1;
      final radius = 90 + phase * size.shortestSide * 0.9;
      final opacity = (1 - phase).clamp(0.0, 1.0);
      wavePaint.color = cyan.withValues(alpha: 0.06 * opacity);
      canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.18),
        radius,
        wavePaint,
      );
    }

    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < 18; index++) {
      final seed = index * 37.0;
      final x = (size.width * ((index * 0.173) % 1.0)) +
          math.sin(progress * math.pi * 2 + seed) * 18;
      final baseY = size.height * ((index * 0.097 + 0.12) % 1.0);
      final y = (baseY - progress * 54 + size.height) % size.height;
      final pulse = 0.5 + math.sin(progress * math.pi * 2 + seed) * 0.5;
      particlePaint.color = (index.isEven ? cyan : coral).withValues(
        alpha: 0.035 + pulse * 0.035,
      );
      canvas.drawCircle(Offset(x, y), 1.4 + pulse * 1.2, particlePaint);
    }

    final bottomDepth = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.34),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bottomDepth);

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.46),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _PulseBackdropPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        line != oldDelegate.line ||
        cyan != oldDelegate.cyan ||
        coral != oldDelegate.coral;
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
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 34,
                offset: const Offset(0, 22),
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
