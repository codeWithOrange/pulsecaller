import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pulsecall/theme/app_theme.dart';
import 'package:vibration/vibration.dart';

class FakeCallPage extends StatefulWidget {
  const FakeCallPage({
    super.key,
    required this.isVibrate,
    required this.callerName,
    required this.callerNumber,
    required this.callerImageUrl,
    this.screenFlash = false,
    this.showCallerNumber = true,
    this.callNote = '',
    this.callProfile = 'Standard',
    this.profileAccent = const Color(0xFF5EE7DF),
    this.autoEndSeconds,
  });

  final String callerName;
  final String callerNumber;
  final String callerImageUrl;
  final bool isVibrate;
  final bool screenFlash;
  final bool showCallerNumber;
  final String callNote;
  final String callProfile;
  final Color profileAccent;
  final int? autoEndSeconds;

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage>
    with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _ringController;
  late final AnimationController _flashController;
  late final Animation<double> _avatarScale;
  late final Animation<double> _ringOpacity;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  bool _isActiveCall = false;
  bool _muted = false;
  bool _speaker = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _avatarScale = Tween<double>(begin: 0.98, end: 1.08).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _ringOpacity = Tween<double>(begin: 0.16, end: 0.36).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _startRingtone();
    if (widget.isVibrate) {
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
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRingtone() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/ringtone1.mp3'));
  }

  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
  }

  Future<void> _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [450, 900, 450, 900], repeat: 0);
    }
  }

  void _stopVibration() {
    Vibration.cancel();
  }

  void _acceptCall() {
    _stopRingtone();
    _stopVibration();
    _ringController.stop();
    setState(() => _isActiveCall = true);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _callDuration += const Duration(seconds: 1));
        final autoEndSeconds = widget.autoEndSeconds;
        if (autoEndSeconds != null &&
            _callDuration.inSeconds >= autoEndSeconds) {
          _endCall();
        }
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _stopRingtone();
    _stopVibration();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        _stopRingtone();
        _stopVibration();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            PulseBackground(
              gradient: PulseGradients.call,
              blurImageAsset: widget.callerImageUrl,
              blurImageOpacity: 0.18,
              child: const SizedBox.expand(),
            ),
            if (widget.screenFlash && !_isActiveCall)
              FadeTransition(
                opacity: Tween<double>(begin: 0.02, end: 0.16).animate(
                  CurvedAnimation(
                    parent: _flashController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(color: context.pulse.ink),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: Column(
                  children: [
                    _PhoneStatusBar(
                      time: _isActiveCall
                          ? _formatTimer(_callDuration)
                          : _time(),
                    ),
                    const SizedBox(height: 18),
                    _CallStatePill(
                      label: _isActiveCall
                          ? 'connected'
                          : '${widget.callProfile} incoming call',
                      accent: widget.profileAccent,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CallerAvatar(
                            imageAsset: widget.callerImageUrl,
                            scale: _isActiveCall
                                ? const AlwaysStoppedAnimation(1)
                                : _avatarScale,
                            opacity: _isActiveCall
                                ? const AlwaysStoppedAnimation(0.2)
                                : _ringOpacity,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            widget.callerName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.showCallerNumber
                                ? widget.callerNumber
                                : 'Private Number',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 18,
                                  color: context.pulse.inkMuted,
                                ),
                          ),
                          if (widget.callNote.trim().isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _CallNote(note: widget.callNote),
                          ],
                          if (!_isActiveCall) ...[
                            const SizedBox(height: 30),
                            const _IncomingUtilityActions(),
                          ],
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isActiveCall
                          ? _ActiveControls(
                              muted: _muted,
                              speaker: _speaker,
                              onMute: () => setState(() => _muted = !_muted),
                              onSpeaker: () =>
                                  setState(() => _speaker = !_speaker),
                              onEnd: _endCall,
                            )
                          : _IncomingControls(
                              onDecline: _endCall,
                              onAccept: _acceptCall,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _time() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _CallNote extends StatelessWidget {
  const _CallNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: pulse.surfaceStrong,
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Text(
        note,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: pulse.inkMuted, height: 1.25),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Row(
      children: [
        Text(
          time,
          style: TextStyle(
            color: pulse.ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(Icons.signal_cellular_alt, color: pulse.ink, size: 17),
        const SizedBox(width: 6),
        Icon(Icons.wifi, color: pulse.ink, size: 17),
        const SizedBox(width: 6),
        Icon(Icons.battery_5_bar, color: pulse.ink, size: 18),
      ],
    );
  }
}

class _CallStatePill extends StatelessWidget {
  const _CallStatePill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(PulseRadius.pill),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _CallerAvatar extends StatelessWidget {
  const _CallerAvatar({
    required this.imageAsset,
    required this.scale,
    required this.opacity,
  });

  final String imageAsset;
  final Animation<double> scale;
  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return ScaleTransition(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: opacity,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pulse.ink,
              ),
            ),
          ),
          Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.36),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipOval(child: Image.asset(imageAsset, fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }
}

class _IncomingControls extends StatelessWidget {
  const _IncomingControls({required this.onDecline, required this.onAccept});

  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('incoming-controls'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NativeCallButton(
              color: context.pulse.danger,
              icon: Icons.call_end,
              label: 'Decline',
              onPressed: onDecline,
            ),
            _NativeCallButton(
              color: context.pulse.success,
              icon: Icons.call,
              label: 'Accept',
              onPressed: onAccept,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveControls extends StatelessWidget {
  const _ActiveControls({
    required this.muted,
    required this.speaker,
    required this.onMute,
    required this.onSpeaker,
    required this.onEnd,
  });

  final bool muted;
  final bool speaker;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('active-controls'),
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.86,
          children: [
            _InCallToolButton(
              active: muted,
              icon: muted ? Icons.mic_off : Icons.mic_none,
              label: 'mute',
              onPressed: onMute,
            ),
            _InCallToolButton(
              active: speaker,
              icon: Icons.volume_up_outlined,
              label: 'speaker',
              onPressed: onSpeaker,
            ),
            _InCallToolButton(
              icon: Icons.dialpad_outlined,
              label: 'keypad',
              onPressed: () {},
            ),
            _InCallToolButton(
              icon: Icons.add,
              label: 'add call',
              onPressed: () {},
            ),
            _InCallToolButton(
              icon: Icons.videocam_outlined,
              label: 'FaceTime',
              onPressed: () {},
            ),
            _InCallToolButton(
              icon: Icons.person_outline,
              label: 'contacts',
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        _NativeCallButton(
          color: context.pulse.danger,
          icon: Icons.call_end,
          label: 'End',
          onPressed: onEnd,
        ),
      ],
    );
  }
}

class _NativeCallButton extends StatelessWidget {
  const _NativeCallButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onPressed,
      borderRadius: PulseRadius.pill,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: pulse.ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _IncomingUtilityActions extends StatelessWidget {
  const _IncomingUtilityActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _UtilityAction(icon: Icons.alarm_outlined, label: 'Remind Me'),
        SizedBox(width: 34),
        _UtilityAction(icon: Icons.message_outlined, label: 'Message'),
      ],
    );
  }
}

class _UtilityAction extends StatelessWidget {
  const _UtilityAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: pulse.ink, size: 21),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: pulse.inkMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _InCallToolButton extends StatelessWidget {
  const _InCallToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onPressed,
      borderRadius: PulseRadius.pill,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? const Color(0xFF111827) : pulse.ink,
              size: 27,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: pulse.inkMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
