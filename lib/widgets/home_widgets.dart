import 'package:flutter/material.dart';
import 'package:pulsecall/models/call_models.dart';
import 'package:pulsecall/theme/app_theme.dart';
import 'package:pulsecall/utils/constants.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.queuedCount,
    required this.historyCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int queuedCount;
  final int historyCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: const Color(0xFF061118),
      indicatorColor: pulse.cyan.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Studio',
        ),
        const NavigationDestination(
          icon: Icon(Icons.layers_outlined),
          selectedIcon: Icon(Icons.layers),
          label: 'Presets',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: queuedCount > 0,
            label: Text('$queuedCount'),
            child: const Icon(Icons.event_note_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: queuedCount > 0,
            label: Text('$queuedCount'),
            child: const Icon(Icons.event_note),
          ),
          label: 'Queue',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: historyCount > 0,
            label: Text('$historyCount'),
            child: const Icon(Icons.history_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: historyCount > 0,
            label: Text('$historyCount'),
            child: const Icon(Icons.history),
          ),
          label: 'Log',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'More',
        ),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.scheduledCount,
    required this.onPreview,
  });

  final int scheduledCount;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF061118),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: pulse.line),
          ),
          child: Icon(Icons.phone_in_talk, color: pulse.cyan),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge,
              ),
            ],
          ),
        ),
        QueueBadge(count: scheduledCount),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'Preview call',
          onPressed: onPreview,
          icon: const Icon(Icons.play_arrow_rounded),
        ),
      ],
    );
  }
}

class QueueBadge extends StatelessWidget {
  const QueueBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: pulse.cyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PulseRadius.pill),
        border: Border.all(color: pulse.cyan.withValues(alpha: 0.36)),
      ),
      child: Text(
        '$count queued',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: pulse.cyan, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.delay,
    required this.repeatCount,
    required this.vibrate,
    required this.flash,
  });

  final String delay;
  final int repeatCount;
  final bool vibrate;
  final bool flash;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      MetricPill(icon: Icons.schedule_outlined, label: 'Delay', value: delay),
      MetricPill(icon: Icons.repeat, label: 'Repeat', value: '${repeatCount}x'),
      MetricPill(
        icon: vibrate ? Icons.vibration : Icons.notifications_off_outlined,
        label: 'Vibrate',
        value: vibrate ? 'On' : 'Off',
      ),
      MetricPill(
        icon: flash ? Icons.flash_on : Icons.flash_off_outlined,
        label: 'Flash',
        value: flash ? 'On' : 'Off',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : 4;
        final width = (constraints.maxWidth - (10 * (columns - 1))) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics
              .map((metric) => SizedBox(width: width, child: metric))
              .toList(),
        );
      },
    );
  }
}

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: pulse.cyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: pulse.inkSubtle, fontSize: 11),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pulse.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PhonePreview extends StatelessWidget {
  const PhonePreview({
    super.key,
    required this.callerName,
    required this.callerNumber,
    required this.isVibrate,
    required this.screenFlash,
    required this.showCallerNumber,
    required this.callNote,
    required this.profile,
    required this.delayLabel,
    required this.onPreview,
  });

  final String callerName;
  final String callerNumber;
  final bool isVibrate;
  final bool screenFlash;
  final bool showCallerNumber;
  final String callNote;
  final CallProfile profile;
  final String delayLabel;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulseGlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Live Preview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                delayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: pulse.inkSubtle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 0.56,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF030913),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: pulse.line, width: 1.4),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: BoxDecoration(
                  gradient: PulseGradients.call,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 255,
                    height: 420,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '09:41',
                              style: TextStyle(color: pulse.inkMuted),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.signal_cellular_alt,
                              color: pulse.inkMuted,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.battery_5_bar,
                              color: pulse.inkMuted,
                              size: 17,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: pulse.cyan.withValues(alpha: 0.12),
                              ),
                            ),
                            Container(
                              width: 104,
                              height: 104,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: pulse.surfaceStrong,
                                border: Border.all(color: pulse.line),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  userImageAsset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          callerName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showCallerNumber ? callerNumber : 'Private Number',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: pulse.inkMuted, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: profile.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        if (callNote.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            callNote,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: pulse.inkSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MiniFeatureChip(
                              icon: isVibrate
                                  ? Icons.vibration
                                  : Icons.notifications_off,
                              label: isVibrate ? 'Vibrate' : 'Silent',
                            ),
                            const SizedBox(width: 8),
                            MiniFeatureChip(
                              icon: screenFlash
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              label: screenFlash ? 'Flash' : 'No flash',
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PreviewCallButton(
                              color: pulse.danger,
                              icon: Icons.call_end,
                            ),
                            PulsePressable(
                              onTap: onPreview,
                              borderRadius: PulseRadius.pill,
                              child: PreviewCallButton(
                                color: pulse.success,
                                icon: Icons.call,
                                emphasized: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniFeatureChip extends StatelessWidget {
  const MiniFeatureChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(PulseRadius.pill),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: pulse.cyan, size: 15),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 72),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: pulse.inkMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewCallButton extends StatelessWidget {
  const PreviewCallButton({
    super.key,
    required this.color,
    required this.icon,
    this.emphasized = false,
  });

  final Color color;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: emphasized ? 74 : 64,
      height: emphasized ? 74 : 64,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: emphasized ? 32 : 28),
    );
  }
}

class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final CallerPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onTap,
      borderRadius: PulseRadius.md,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 86,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? preset.accent.withValues(alpha: 0.14)
              : const Color(0xFF081522).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(PulseRadius.md),
          border: Border.all(color: selected ? preset.accent : pulse.line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: preset.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(preset.icon, color: preset.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    preset.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(Icons.check_circle, color: preset.accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class PulseTextInput extends StatelessWidget {
  const PulseTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: context.pulse.ink),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class DelaySelector extends StatelessWidget {
  const DelaySelector({
    super.key,
    required this.delays,
    required this.selectedDelay,
    required this.onSelected,
  });

  final List<int> delays;
  final int selectedDelay;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = ((constraints.maxWidth - 20) / 3).clamp(92.0, 180.0);
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: delays.map((seconds) {
            return SizedBox(
              width: itemWidth.toDouble(),
              child: DelayTile(
                label: formatDurationShort(Duration(seconds: seconds)),
                selected: seconds == selectedDelay,
                onTap: () => onSelected(seconds),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DelayTile extends StatelessWidget {
  const DelayTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onTap,
      borderRadius: PulseRadius.md,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? pulse.cyan.withValues(alpha: 0.18)
              : const Color(0xFF081522).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(PulseRadius.md),
          border: Border.all(color: selected ? pulse.cyan : pulse.line),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? pulse.ink : pulse.inkMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class RepeatSelector extends StatelessWidget {
  const RepeatSelector({
    super.key,
    required this.repeatCount,
    required this.onChanged,
  });

  final int repeatCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat, color: pulse.cyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Repeat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1x')),
              ButtonSegment(value: 2, label: Text('2x')),
              ButtonSegment(value: 3, label: Text('3x')),
            ],
            selected: {repeatCount},
            onSelectionChanged: (value) => onChanged(value.first),
          ),
        ],
      ),
    );
  }
}

class PulseSwitchTile extends StatelessWidget {
  const PulseSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? pulse.cyan : pulse.inkMuted),
          const SizedBox(width: 12),
          Expanded(
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
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class AdvancedCallPanel extends StatelessWidget {
  const AdvancedCallPanel({
    super.key,
    required this.profiles,
    required this.selectedProfile,
    required this.showCallerNumber,
    required this.autoEndCall,
    required this.autoEndSeconds,
    required this.noteController,
    required this.onProfileChanged,
    required this.onShowNumberChanged,
    required this.onAutoEndChanged,
    required this.onAutoEndSecondsChanged,
  });

  final List<CallProfile> profiles;
  final int selectedProfile;
  final bool showCallerNumber;
  final bool autoEndCall;
  final int autoEndSeconds;
  final TextEditingController noteController;
  final ValueChanged<int> onProfileChanged;
  final ValueChanged<bool> onShowNumberChanged;
  final ValueChanged<bool> onAutoEndChanged;
  final ValueChanged<int> onAutoEndSecondsChanged;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: pulse.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Advanced Call Layer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(profiles.length, (index) {
              final profile = profiles[index];
              final selected = selectedProfile == index;
              return PulsePressable(
                onTap: () => onProfileChanged(index),
                borderRadius: PulseRadius.pill,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? profile.accent.withValues(alpha: 0.16)
                        : pulse.surfaceStrong,
                    borderRadius: BorderRadius.circular(PulseRadius.pill),
                    border: Border.all(
                      color: selected ? profile.accent : pulse.line,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(profile.icon, color: profile.accent, size: 16),
                      const SizedBox(width: 7),
                      Text(
                        profile.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? pulse.ink : pulse.inkMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          PulseTextInput(
            controller: noteController,
            label: 'Note',
            hintText: '',
            icon: Icons.sticky_note_2_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          PulseSwitchTile(
            icon: Icons.visibility_outlined,
            title: 'Show Number',
            subtitle: 'Private',
            value: showCallerNumber,
            onChanged: onShowNumberChanged,
          ),
          const SizedBox(height: 10),
          PulseSwitchTile(
            icon: Icons.timer_off_outlined,
            title: 'Auto End',
            subtitle: 'Timer',
            value: autoEndCall,
            onChanged: onAutoEndChanged,
          ),
          if (autoEndCall) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Auto end',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: pulse.inkMuted),
                ),
                Expanded(
                  child: Slider(
                    min: 15,
                    max: 180,
                    divisions: 11,
                    value: autoEndSeconds.toDouble(),
                    onChanged: (value) =>
                        onAutoEndSecondsChanged(value.round()),
                  ),
                ),
                Text(
                  '${autoEndSeconds}s',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pulse.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class TemplatesHero extends StatelessWidget {
  const TemplatesHero({super.key, required this.onQuickStart});

  final VoidCallback onQuickStart;

  @override
  Widget build(BuildContext context) {
    return PulseGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: PulseGradients.action,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF061118)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presets',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${callTemplates.length} ready',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onQuickStart,
            icon: const Icon(Icons.flash_on),
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key, required this.template, required this.onUse});

  final CallTemplate template;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onUse,
      borderRadius: PulseRadius.lg,
      child: PulseGlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: template.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: template.accent.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Icon(template.icon, color: template.accent),
                ),
                const Spacer(),
                Text(
                  formatDurationShort(Duration(seconds: template.delaySeconds)),
                  style: TextStyle(
                    color: pulse.inkSubtle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              template.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              template.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: pulse.inkMuted),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: template.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QueueHero extends StatelessWidget {
  const QueueHero({
    super.key,
    required this.queuedCount,
    required this.nextCall,
    required this.onClearAll,
  });

  final int queuedCount;
  final ScheduledCall? nextCall;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final next = nextCall;

    return PulseGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: pulse.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: pulse.cyan.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.pending_actions_outlined, color: pulse.cyan),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$queuedCount calls queued',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  next == null
                      ? 'Idle'
                      : 'Next: ${next.name} in ${formatDurationShort(next.remaining)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: queuedCount == 0 ? null : onClearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class UpcomingPanel extends StatelessWidget {
  const UpcomingPanel({
    super.key,
    required this.scheduled,
    required this.onCancel,
    required this.onClearAll,
  });

  final List<ScheduledCall> scheduled;
  final ValueChanged<String> onCancel;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return PulseGlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulseSectionTitle(
                icon: Icons.notifications_active_outlined,
                title: 'Call Queue',
                subtitle: '${scheduled.length} calls',
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Clear all',
                onPressed: scheduled.isEmpty ? null : onClearAll,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (scheduled.isEmpty)
            const EmptyQueueState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scheduled.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final call = scheduled[index];
                return ScheduledCallTile(
                  call: call,
                  onCancel: () => onCancel(call.id),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ScheduledCallTile extends StatelessWidget {
  const ScheduledCallTile({
    super.key,
    required this.call,
    required this.onCancel,
  });

  final ScheduledCall call;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final remaining = call.remaining;
    final progress = 1 - (remaining.inSeconds / call.delaySeconds).clamp(0, 1);
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: pulse.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    call.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      color: pulse.cyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      call.number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${call.callProfile}${call.autoEndSeconds == null ? '' : ' - auto-end ${call.autoEndSeconds}s'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: call.profileAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatDurationShort(remaining),
                style: TextStyle(color: pulse.ink, fontWeight: FontWeight.w800),
              ),
              IconButton(
                tooltip: 'Cancel',
                onPressed: onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(PulseRadius.pill),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 6,
              backgroundColor: pulse.surfaceStrong,
              color: pulse.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyQueueState extends StatelessWidget {
  const EmptyQueueState({super.key});

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 42,
            color: pulse.inkSubtle,
          ),
          const SizedBox(height: 10),
          Text('Queue is clear', style: TextStyle(color: pulse.inkMuted)),
        ],
      ),
    );
  }
}

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({super.key, required this.history});

  final List<CallHistoryItem> history;

  @override
  Widget build(BuildContext context) {
    return PulseGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseSectionTitle(
            icon: Icons.history_outlined,
            title: 'Activity History',
            subtitle: '${history.length} items',
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const EmptyHistoryState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  HistoryTile(item: history[index]),
            ),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.item});

  final CallHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: item.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            formatClock(item.createdAt),
            style: TextStyle(
              color: pulse.inkSubtle,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            color: pulse.inkSubtle,
            size: 44,
          ),
          const SizedBox(height: 10),
          Text('No activity yet', style: TextStyle(color: pulse.inkMuted)),
        ],
      ),
    );
  }
}

class SettingsInfoTile extends StatelessWidget {
  const SettingsInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF081522).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PulseRadius.md),
        border: Border.all(color: pulse.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: pulse.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
