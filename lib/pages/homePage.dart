import 'package:flutter/material.dart';
import 'package:pulsecall/controllers/call_studio_controller.dart';
import 'package:pulsecall/models/call_models.dart';
import 'package:pulsecall/pages/fakeCallPage.dart';
import 'package:pulsecall/theme/app_theme.dart';
import 'package:pulsecall/utils/constants.dart';
import 'package:pulsecall/widgets/home_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final CallStudioController _controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = CallStudioController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
      lowerBound: 0.985,
      upperBound: 1.015,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scheduleCall() {
    final ok = _controller.scheduleCalls(_launchScheduledCall);
    if (!ok) {
      _showSnack('Caller name daalo pehle');
      return;
    }

    final delayLabel = formatDurationShort(Duration(seconds: _controller.delaySeconds));
    _showSnack(
      _controller.repeatCount == 1
          ? 'Call scheduled in $delayLabel'
          : '${_controller.repeatCount} calls scheduled',
    );
  }

  void _launchScheduledCall(String id) {
    final call = _controller.popCall(id);
    if (call == null || !mounted) return;
    _openCall(call);
  }

  void _previewCall() {
    _controller.recordPreview();
    final profile = _controller.currentProfile;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FakeCallPage(
          isVibrate: _controller.vibrate,
          callerName: _controller.callerName,
          callerNumber: _controller.callerNumber,
          callerImageUrl: userImageAsset,
          screenFlash: _controller.screenFlash,
          showCallerNumber: _controller.showCallerNumber,
          callNote: _controller.callNote,
          callProfile: profile.label,
          profileAccent: profile.accent,
          autoEndSeconds: _controller.resolvedAutoEndSeconds,
        ),
      ),
    );
  }

  void _openCall(ScheduledCall call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FakeCallPage(
          isVibrate: call.vibrate,
          callerName: call.name,
          callerNumber: call.number,
          callerImageUrl: userImageAsset,
          screenFlash: call.screenFlash,
          showCallerNumber: call.showCallerNumber,
          callNote: call.callNote,
          callProfile: call.callProfile,
          profileAccent: call.profileAccent,
          autoEndSeconds: call.autoEndSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final isWide = width >= 940;

        return Scaffold(
          body: PulseBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 28 : 18,
                      18,
                      isWide ? 28 : 18,
                      18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Column(
                            children: [
                              HomeHeader(
                                scheduledCount: _controller.scheduled.length,
                                onPreview: _previewCall,
                              ),
                              const SizedBox(height: 18),
                              StatusStrip(
                                delay: formatDurationShort(
                                  Duration(seconds: _controller.delaySeconds),
                                ),
                                repeatCount: _controller.repeatCount,
                                vibrate: _controller.vibrate,
                                flash: _controller.screenFlash,
                              ),
                              const SizedBox(height: 18),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: _buildSelectedPage(isWide),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AppNavigationBar(
            selectedIndex: _controller.selectedPage,
            queuedCount: _controller.scheduled.length,
            historyCount: _controller.history.length,
            onDestinationSelected: _controller.selectPage,
          ),
        );
      },
    );
  }

  Widget _buildSelectedPage(bool isWide) {
    switch (_controller.selectedPage) {
      case 1:
        return _buildTemplatesPage();
      case 2:
        return _buildQueuePage();
      case 3:
        return HistoryPanel(key: const ValueKey('history'), history: _controller.history);
      case 4:
        return _buildSettingsPage(isWide);
      default:
        return _buildStudioPage(isWide);
    }
  }

  Widget _buildStudioPage(bool isWide) {
    final preview = PhonePreview(
      callerName: _controller.callerName,
      callerNumber: _controller.callerNumber,
      isVibrate: _controller.vibrate,
      screenFlash: _controller.screenFlash,
      showCallerNumber: _controller.showCallerNumber,
      callNote: _controller.callNote,
      profile: _controller.currentProfile,
      delayLabel: formatDurationShort(Duration(seconds: _controller.delaySeconds)),
      onPreview: _previewCall,
    );
    final composer = _buildComposer();

    return KeyedSubtree(
      key: const ValueKey('studio'),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: preview),
                const SizedBox(width: 18),
                Expanded(flex: 7, child: composer),
              ],
            )
          : Column(children: [preview, const SizedBox(height: 16), composer]),
    );
  }

  Widget _buildTemplatesPage() {
    return KeyedSubtree(
      key: const ValueKey('templates'),
      child: Column(
        children: [
          TemplatesHero(onQuickStart: _scheduleCall),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 3 : 1;
              final cardWidth = (constraints.maxWidth - (14 * (columns - 1))) / columns;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: callTemplates
                    .map(
                      (template) => SizedBox(
                        width: cardWidth,
                        child: TemplateCard(
                          template: template,
                          onUse: () => _controller.applyTemplate(template),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePage() {
    return KeyedSubtree(
      key: const ValueKey('queue'),
      child: Column(
        children: [
          QueueHero(
            queuedCount: _controller.scheduled.length,
            nextCall: _controller.scheduled.isEmpty ? null : _controller.scheduled.first,
            onClearAll: () => _controller.clearQueue(context.pulse.amber),
          ),
          const SizedBox(height: 16),
          UpcomingPanel(
            scheduled: _controller.scheduled,
            onCancel: (id) => _controller.cancelCall(id, context.pulse.danger),
            onClearAll: () => _controller.clearQueue(context.pulse.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(bool isWide) {
    final defaults = _buildDefaultSettings();
    final about = _buildAboutSettings();
    return KeyedSubtree(
      key: const ValueKey('settings'),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: defaults),
                const SizedBox(width: 16),
                Expanded(child: about),
              ],
            )
          : Column(children: [defaults, const SizedBox(height: 16), about]),
    );
  }

  Widget _buildComposer() {
    return Column(
      children: [
        PulseGlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PulseSectionTitle(
                icon: Icons.contacts_outlined,
                title: 'Caller Identity',
                subtitle: 'Caller',
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;
                  final cards = List.generate(callerPresets.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == callerPresets.length - 1 ? 0 : 10,
                      ),
                      child: PresetCard(
                        preset: callerPresets[index],
                        selected: index == _controller.selectedPreset,
                        onTap: () => _controller.applyPreset(index),
                      ),
                    );
                  });
                  if (compact) return Column(children: cards);
                  return Row(
                    children: cards
                        .map(
                          (card) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: card,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              PulseTextInput(
                controller: _controller.nameController,
                label: 'Name',
                icon: Icons.person_outline,
                hintText: 'e.g. Angad Kumar',
              ),
              const SizedBox(height: 12),
              PulseTextInput(
                controller: _controller.numberController,
                label: 'Number',
                icon: Icons.dialpad_outlined,
                hintText: '+91 98765 43210',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PulseGlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PulseSectionTitle(
                icon: Icons.tune_outlined,
                title: 'Call Behavior',
                subtitle: 'Timing',
              ),
              const SizedBox(height: 16),
              DelaySelector(
                delays: _controller.quickDelays,
                selectedDelay: _controller.delaySeconds,
                onSelected: _controller.setDelay,
              ),
              const SizedBox(height: 18),
              RepeatSelector(
                repeatCount: _controller.repeatCount,
                onChanged: _controller.setRepeat,
              ),
              const SizedBox(height: 12),
              PulseSwitchTile(
                icon: Icons.vibration_outlined,
                title: 'Vibration',
                subtitle: 'Ring',
                value: _controller.vibrate,
                onChanged: _controller.setVibrate,
              ),
              const SizedBox(height: 10),
              PulseSwitchTile(
                icon: Icons.flash_on_outlined,
                title: 'Screen Flash',
                subtitle: 'Pulse',
                value: _controller.screenFlash,
                onChanged: _controller.setScreenFlash,
              ),
              const SizedBox(height: 16),
              AdvancedCallPanel(
                profiles: callProfiles,
                selectedProfile: _controller.selectedProfile,
                showCallerNumber: _controller.showCallerNumber,
                autoEndCall: _controller.autoEndCall,
                autoEndSeconds: _controller.autoEndSeconds,
                noteController: _controller.noteController,
                onProfileChanged: _controller.setProfile,
                onShowNumberChanged: _controller.setShowCallerNumber,
                onAutoEndChanged: _controller.setAutoEndCall,
                onAutoEndSecondsChanged: _controller.setAutoEndSeconds,
              ),
              const SizedBox(height: 18),
              ScaleTransition(
                scale: _pulseController,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _scheduleCall,
                    icon: const Icon(Icons.add_call),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Schedule Call',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSettings() {
    return PulseGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PulseSectionTitle(
            icon: Icons.settings_outlined,
            title: 'Default Behavior',
            subtitle: 'Defaults',
          ),
          const SizedBox(height: 16),
          PulseSwitchTile(
            icon: Icons.vibration_outlined,
            title: 'Default Vibration',
            subtitle: 'Vibrate',
            value: _controller.vibrate,
            onChanged: _controller.setVibrate,
          ),
          const SizedBox(height: 10),
          PulseSwitchTile(
            icon: Icons.flash_on_outlined,
            title: 'Default Flash',
            subtitle: 'Flash',
            value: _controller.screenFlash,
            onChanged: _controller.setScreenFlash,
          ),
          const SizedBox(height: 16),
          RepeatSelector(
            repeatCount: _controller.repeatCount,
            onChanged: _controller.setRepeat,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return const PulseGlassPanel(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseSectionTitle(
            icon: Icons.auto_awesome_outlined,
            title: 'PulseCall',
            subtitle: 'v1.0',
          ),
          SizedBox(height: 18),
          SettingsInfoTile(
            icon: Icons.phone_iphone_outlined,
            title: 'Studio',
            value: 'Ready',
          ),
          SizedBox(height: 10),
          SettingsInfoTile(
            icon: Icons.event_note_outlined,
            title: 'Queue',
            value: 'Active',
          ),
          SizedBox(height: 10),
          SettingsInfoTile(
            icon: Icons.play_circle_outline,
            title: 'Preview',
            value: 'Enabled',
          ),
        ],
      ),
    );
  }
}
