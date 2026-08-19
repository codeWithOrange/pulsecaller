import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulsecall/models/call_models.dart';
import 'package:pulsecall/theme/app_theme.dart';
import 'package:vibration/vibration.dart';

class FakeCallPage extends StatefulWidget {
  const FakeCallPage({
    super.key,
    required this.isVibrate,
    required this.callerName,
    required this.callerNumber,
    required this.callerImageUrl,
    this.carrier = 'SIM 1 - Jio 5G',
    this.screenFlash = false,
    this.showCallerNumber = true,
    this.callNote = '',
    this.callProfile = 'Standard',
    this.skin = CallScreenSkin.ios,
    this.profileAccent = const Color(0xFF38BDF8),
    this.vibrationPattern = VibrationPatternType.standard,
    this.autoEndSeconds,
    this.proximityBlackout = true,
    this.onCallEnded,
  });

  final String callerName;
  final String callerNumber;
  final String callerImageUrl;
  final String carrier;
  final bool isVibrate;
  final bool screenFlash;
  final bool showCallerNumber;
  final String callNote;
  final String callProfile;
  final CallScreenSkin skin;
  final Color profileAccent;
  final VibrationPatternType vibrationPattern;
  final int? autoEndSeconds;
  final bool proximityBlackout;
  final void Function(CallStatus status, Duration duration)? onCallEnded;

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage>
    with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _ringController;
  late final AnimationController _flashController;
  late final AnimationController _waveController;

  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  bool _isActiveCall = false;
  bool _muted = false;
  bool _speaker = false;
  bool _onHold = false;
  bool _isProximityBlackout = false;
  bool _showKeypad = false;
  String _keypadDigits = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _startRingtone();
    if (widget.isVibrate &&
        widget.vibrationPattern != VibrationPatternType.silent) {
      _startVibration();
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _stopRingtone();
    _stopVibration();
    _ringController.dispose();
    _flashController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/ringtone1.mp3'));
    } catch (_) {}
  }

  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  Future<void> _startVibration() async {
    try {
      final hasVib = await Vibration.hasVibrator();
      if (hasVib == true) {
        final pattern = widget.vibrationPattern.pattern;
        if (pattern.isNotEmpty) {
          Vibration.vibrate(pattern: pattern, repeat: 0);
        } else {
          Vibration.vibrate(pattern: [500, 1000], repeat: 0);
        }
      }
    } catch (_) {}
  }

  void _stopVibration() {
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  void _acceptCall() {
    _stopRingtone();
    _stopVibration();
    _ringController.stop();
    HapticFeedback.heavyImpact();

    setState(() {
      _isActiveCall = true;
    });

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _callDuration += const Duration(seconds: 1));
        final autoEndSeconds = widget.autoEndSeconds;
        if (autoEndSeconds != null &&
            _callDuration.inSeconds >= autoEndSeconds) {
          _endCall(CallStatus.answered);
        }
      }
    });
  }

  void _endCall([CallStatus? status]) {
    final finalStatus =
        status ?? (_isActiveCall ? CallStatus.answered : CallStatus.declined);
    _callTimer?.cancel();
    _stopRingtone();
    _stopVibration();
    HapticFeedback.mediumImpact();

    if (widget.onCallEnded != null) {
      widget.onCallEnded!(finalStatus, _callDuration);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _toggleProximityBlackout() {
    if (!widget.proximityBlackout) return;
    setState(() {
      _isProximityBlackout = !_isProximityBlackout;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    if (_isProximityBlackout) {
      return GestureDetector(
        onTap: _toggleProximityBlackout,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text(
            'Screen dimmed for call\n(Tap anywhere to wake)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0x33FFFFFF),
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        _stopRingtone();
        _stopVibration();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Theme
            _buildBackground(),

            // Screen Flash Effect
            if (widget.screenFlash && !_isActiveCall)
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 0.22).animate(
                  CurvedAnimation(
                    parent: _flashController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(color: Colors.white),
              ),

            // Main Content Area
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Top helper (Proximity sensor helper only, native status bar handles time/tower)
                    _buildTopBar(),
                    const SizedBox(height: 8),

                    // Caller Info & Avatar
                    Expanded(
                      child: _isActiveCall
                          ? _buildActiveCallCenter()
                          : _buildIncomingCallCenter(),
                    ),

                    // Controls (Incoming vs Active)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: _isActiveCall
                          ? _buildActiveControls()
                          : _buildIncomingControls(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // In-Call Keypad Overlay Sheet
            if (_showKeypad) _buildKeypadOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    switch (widget.skin) {
      case CallScreenSkin.ios:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1C2438), Color(0xFF101624), Color(0xFF070A10)],
            ),
          ),
        );
      case CallScreenSkin.pixel:
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.1,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
            ),
          ),
        );
      case CallScreenSkin.oneUi:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF182234), Color(0xFF0E1422), Color(0xFF06090F)],
            ),
          ),
        );
      case CallScreenSkin.pulseDark:
        return Stack(
          children: [
            Container(color: const Color(0xFF050810)),
            Positioned(
              top: -80,
              left: -80,
              right: -80,
              height: 380,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.profileAccent.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTopBar() {
    if (!widget.proximityBlackout) return const SizedBox(height: 4);

    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: _toggleProximityBlackout,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(PulseRadius.pill),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sensors_rounded, color: Colors.white70, size: 12),
              SizedBox(width: 5),
              Text(
                'Ear Sim',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingCallCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Carrier / Network Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(PulseRadius.pill),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Text(
            widget.carrier.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Avatar with pulse animations
        _buildAvatar(),
        const SizedBox(height: 26),

        // Caller Name
        Text(
          widget.callerName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Caller Number / Subtitle
        Text(
          widget.showCallerNumber ? widget.callerNumber : 'Private Number',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Call note / prompt if present
        if (widget.callNote.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(PulseRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speaker_notes_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.callNote,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Utility actions (Remind Me, Message)
        const SizedBox(height: 28),
        _buildUtilityActions(),
      ],
    );
  }

  Widget _buildActiveCallCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing Live Connection Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(PulseRadius.pill),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimer(_callDuration),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Caller Avatar (Smaller in active mode)
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(widget.callerImageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 20),

        // Caller Name
        Text(
          widget.callerName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          widget.showCallerNumber ? widget.callerNumber : 'Private Number',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),

        // Script prompter card during active call
        if (widget.callNote.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(PulseRadius.md),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      color: Color(0xFF38BDF8),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CALL NOTE',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.callNote,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarScale = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    final ringOpacity = Tween<double>(begin: 0.12, end: 0.38).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    return ScaleTransition(
      scale: avatarScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing ripple
          FadeTransition(
            opacity: ringOpacity,
            child: Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.skin == CallScreenSkin.pulseDark
                    ? widget.profileAccent.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Inner avatar circle
          Container(
            width: 136,
            height: 136,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(widget.callerImageUrl, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGlassUtilityButton(
          icon: Icons.alarm_rounded,
          label: 'Remind Me',
          onTap: () {
            HapticFeedback.selectionClick();
            _endCall(CallStatus.declined);
          },
        ),
        const SizedBox(width: 44),
        _buildGlassUtilityButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Message',
          onTap: () {
            HapticFeedback.selectionClick();
            _endCall(CallStatus.declined);
          },
        ),
      ],
    );
  }

  Widget _buildGlassUtilityButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingControls() {
    if (widget.skin == CallScreenSkin.ios) {
      // iOS Slide-to-Answer or Round Decline / Accept Buttons
      return _IOSSlideToAnswer(
        onAccept: _acceptCall,
        onDecline: () => _endCall(CallStatus.declined),
      );
    }

    // Default Real-world Action Buttons
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CallActionButton(
          icon: Icons.call_end_rounded,
          label: 'Decline',
          color: const Color(0xFFEF4444),
          onTap: () => _endCall(CallStatus.declined),
        ),
        _CallActionButton(
          icon: Icons.call_rounded,
          label: 'Accept',
          color: const Color(0xFF10B981),
          onTap: _acceptCall,
        ),
      ],
    );
  }

  Widget _buildActiveControls() {
    return Column(
      key: const ValueKey('active_controls'),
      children: [
        // 6-Grid In-Call Tools
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.9,
          children: [
            _InCallCircleButton(
              icon: _muted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
              label: _muted ? 'Muted' : 'Mute',
              isActive: _muted,
              onTap: () => setState(() => _muted = !_muted),
            ),
            _InCallCircleButton(
              icon: Icons.dialpad_rounded,
              label: 'Keypad',
              isActive: _showKeypad,
              onTap: () => setState(() => _showKeypad = true),
            ),
            _InCallCircleButton(
              icon: _speaker
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              label: _speaker ? 'Speaker On' : 'Speaker',
              isActive: _speaker,
              onTap: () => setState(() => _speaker = !_speaker),
            ),
            _InCallCircleButton(
              icon: Icons.add_rounded,
              label: 'Add Call',
              onTap: () {
                HapticFeedback.selectionClick();
              },
            ),
            _InCallCircleButton(
              icon: _onHold ? Icons.play_arrow_rounded : Icons.pause_rounded,
              label: _onHold ? 'Resume' : 'Hold',
              isActive: _onHold,
              onTap: () => setState(() => _onHold = !_onHold),
            ),
            _InCallCircleButton(
              icon: Icons.contacts_rounded,
              label: 'Contacts',
              onTap: () {
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // End Call Pill / Button
        _CallActionButton(
          icon: Icons.call_end_rounded,
          label: 'End',
          color: const Color(0xFFEF4444),
          onTap: () => _endCall(CallStatus.answered),
        ),
      ],
    );
  }

  Widget _buildKeypadOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => setState(() => _showKeypad = false),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _keypadDigits.isEmpty ? 'Keypad' : _keypadDigits,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _buildInCallDialpad(),
              const Spacer(),
              _CallActionButton(
                icon: Icons.call_end_rounded,
                label: 'End Call',
                color: const Color(0xFFEF4444),
                onTap: () => _endCall(CallStatus.answered),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInCallDialpad() {
    final keys = [
      ['1', ''],
      ['2', 'ABC'],
      ['3', 'DEF'],
      ['4', 'GHI'],
      ['5', 'JKL'],
      ['6', 'MNO'],
      ['7', 'PQRS'],
      ['8', 'TUV'],
      ['9', 'WXYZ'],
      ['*', ''],
      ['0', '+'],
      ['#', ''],
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.2,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final number = keys[index][0];
          final letters = keys[index][1];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _keypadDigits += number);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (letters.isNotEmpty)
                    Text(
                      letters,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PulsePressable(
      onTap: onTap,
      borderRadius: PulseRadius.pill,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InCallCircleButton extends StatelessWidget {
  const _InCallCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return PulsePressable(
      onTap: onTap,
      borderRadius: PulseRadius.pill,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSSlideToAnswer extends StatefulWidget {
  const _IOSSlideToAnswer({required this.onAccept, required this.onDecline});

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<_IOSSlideToAnswer> createState() => _IOSSlideToAnswerState();
}

class _IOSSlideToAnswerState extends State<_IOSSlideToAnswer> {
  double _dragValue = 0.0;
  final double _trackWidth = 280.0;
  final double _thumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final maxDrag = _trackWidth - _thumbSize - 8.0;

    return Column(
      children: [
        // Slide to Answer Bar
        Container(
          width: _trackWidth,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Shimmer hint text
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'slide to answer',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Draggable Thumb
              Positioned(
                left: _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(
                        0.0,
                        maxDrag,
                      );
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragValue >= maxDrag * 0.75) {
                      widget.onAccept();
                    } else {
                      setState(() => _dragValue = 0.0);
                    }
                  },
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6610B981),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Or Decline Button
        GestureDetector(
          onTap: widget.onDecline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                SizedBox(width: 6),
                Text(
                  'Decline Call',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
