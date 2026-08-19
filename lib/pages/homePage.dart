import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomePageState extends State<HomePage> {
  late final CallStudioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CallStudioController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _openCustomCallerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomCallerModalSheet(
        initialName: _controller.callerName,
        initialNumber: _controller.callerNumber,
        initialCarrier: _controller.selectedCarrier,
        initialNote: _controller.callNote,
        initialDelay: _controller.delaySeconds,
        initialRepeat: _controller.repeatCount,
        onSaveAsActive: (name, number, carrier, note) {
          _controller.setCustomCaller(
            name: name,
            number: number,
            carrier: carrier,
            note: note,
          );
          _showSnack('Active caller set: $name', isSuccess: true);
        },
        onSaveAndCall: (name, number, carrier, note) {
          _controller.setCustomCaller(
            name: name,
            number: number,
            carrier: carrier,
            note: note,
          );
          _previewCall();
        },
        onSchedule: (name, number, carrier, note, delay, repeat) {
          _controller.setCustomCaller(
            name: name,
            number: number,
            carrier: carrier,
            note: note,
          );
          _controller.delaySeconds = delay;
          _controller.repeatCount = repeat;
          _scheduleCall();
        },
      ),
    );
  }

  void _openScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NativeScheduleModalSheet(
        callerName: _controller.callerName,
        callerNumber: _controller.callerNumber,
        delaySeconds: _controller.delaySeconds,
        repeatCount: _controller.repeatCount,
        carrier: _controller.selectedCarrier,
        note: _controller.callNote,
        onConfirm: (name, number, delay, repeat, note, carrier) {
          _controller.setCustomCaller(
            name: name,
            number: number,
            carrier: carrier,
            note: note,
          );
          _controller.delaySeconds = delay;
          _controller.repeatCount = repeat;
          _scheduleCall();
        },
      ),
    );
  }

  void _scheduleCall() {
    final ok = _controller.scheduleCalls(_launchScheduledCall);
    if (!ok) {
      _showSnack('Please enter caller name first');
      return;
    }

    final delayLabel = formatDurationShort(
      Duration(seconds: _controller.delaySeconds),
    );
    HapticFeedback.mediumImpact();
    _showSnack(
      _controller.repeatCount == 1
          ? 'Call scheduled in $delayLabel'
          : '${_controller.repeatCount} calls scheduled in $delayLabel',
      isSuccess: true,
    );
  }

  void _quickEscape(int delaySeconds) {
    final ok = _controller.quickEscapeTrigger(
      delaySeconds,
      _launchScheduledCall,
    );
    if (!ok) {
      _showSnack('Please enter caller name first');
      return;
    }
    HapticFeedback.heavyImpact();
    _showSnack(
      'Call scheduled in ${formatDurationShort(Duration(seconds: delaySeconds))}',
      isSuccess: true,
    );
  }

  void _launchScheduledCall(String id) {
    final call = _controller.popCall(id);
    if (call == null || !mounted) return;
    _openCall(call);
  }

  void _previewCall() {
    _controller.recordCallResult(
      name: _controller.callerName,
      number: _controller.callerNumber,
      note: _controller.callNote,
      status: CallStatus.previewed,
      duration: Duration.zero,
      skin: _controller.selectedSkin,
      accent: _controller.currentProfile.accent,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FakeCallPage(
          isVibrate: _controller.vibrate,
          vibrationPattern: _controller.selectedVibration,
          callerName: _controller.callerName,
          callerNumber: _controller.callerNumber,
          callerImageUrl: userImageAsset,
          carrier: _controller.selectedCarrier,
          screenFlash: _controller.screenFlash,
          showCallerNumber: _controller.showCallerNumber,
          callNote: _controller.callNote,
          callProfile: _controller.currentProfile.label,
          skin: _controller.selectedSkin,
          profileAccent: _controller.currentProfile.accent,
          autoEndSeconds: _controller.resolvedAutoEndSeconds,
          proximityBlackout: _controller.proximityBlackout,
          onCallEnded: (status, duration) {
            _controller.recordCallResult(
              name: _controller.callerName,
              number: _controller.callerNumber,
              note: _controller.callNote,
              status: status,
              duration: duration,
              skin: _controller.selectedSkin,
              accent: _controller.currentProfile.accent,
            );
          },
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
          vibrationPattern: call.vibrationPattern,
          callerName: call.name,
          callerNumber: call.number,
          callerImageUrl: userImageAsset,
          carrier: call.carrier,
          screenFlash: call.screenFlash,
          showCallerNumber: call.showCallerNumber,
          callNote: call.callNote,
          callProfile: call.callProfile,
          skin: call.skin,
          profileAccent: call.profileAccent,
          autoEndSeconds: call.autoEndSeconds,
          proximityBlackout: _controller.proximityBlackout,
          onCallEnded: (status, duration) {
            _controller.recordCallResult(
              name: call.name,
              number: call.number,
              note: call.callNote,
              status: status,
              duration: duration,
              skin: call.skin,
              accent: call.profileAccent,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF04070D),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildCurrentTab(),
              ),
            ),
          ),
          bottomNavigationBar: NativeAppNavigationBar(
            selectedIndex: _controller.selectedPage,
            queuedCount: _controller.scheduled.length,
            historyCount: _controller.history.length,
            onDestinationSelected: _controller.selectPage,
          ),
        );
      },
    );
  }

  Widget _buildCurrentTab() {
    switch (_controller.selectedPage) {
      case 1:
        return _buildContactsTab();
      case 2:
        return _buildTriggersTab();
      case 3:
        return _buildRecentsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildKeypadHomeTab();
    }
  }

  // --- TAB 0: KEYPAD / DIALER (Native Mobile Home Screen) ---
  Widget _buildKeypadHomeTab() {
    final pulse = context.pulse;

    return SingleChildScrollView(
      key: const ValueKey('keypad_home_tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Native Header
          NativeTopBar(
            title: 'Phone',
            subtitle: _controller.scheduled.isEmpty
                ? 'Ready to call'
                : '${_controller.scheduled.length} call scheduled',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pulse.surface,
                borderRadius: BorderRadius.circular(PulseRadius.pill),
              ),
              child: Text(
                _controller.selectedCarrier,
                style: TextStyle(
                  color: pulse.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Favorites Contact Avatars Strip
          FavoritesAvatarStrip(
            presets: callerPresets,
            selectedIndex: _controller.selectedPreset,
            onSelected: (index) {
              _controller.applyPreset(index);
              HapticFeedback.selectionClick();
            },
            onAddCustom: _openCustomCallerBottomSheet,
          ),
          const SizedBox(height: 6),

          // Active Selected Caller Info Banner
          PulsePressable(
            onTap: _openCustomCallerBottomSheet,
            borderRadius: PulseRadius.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: pulse.surface,
                borderRadius: BorderRadius.circular(PulseRadius.md),
                border: Border.all(color: pulse.cyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pulse.cyan.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.person_rounded, color: pulse.cyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _controller.callerName.isNotEmpty
                                  ? _controller.callerName
                                  : 'Select / Custom Caller',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(PulseRadius.pill),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_controller.callerNumber}  •  ${_controller.selectedCarrier}',
                          style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_rounded, color: pulse.cyan, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Native Phone Keypad
          NativePhoneKeypad(
            controller: _controller.dialpadController,
            onDigit: _controller.dialDigit,
            onBackspace: _controller.dialBackspace,
            onSchedule: _openScheduleBottomSheet,
            onCallNow: () {
              final dialed = _controller.dialpadController.text.trim();
              if (dialed.isNotEmpty) {
                _controller.numberController.text = dialed;
                _controller.nameController.text = 'Direct Dial';
              }
              _previewCall();
            },
            onQuickSOS: () => _quickEscape(5),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: CONTACTS & PRESETS (Address Book Look) ---
  Widget _buildContactsTab() {
    final pulse = context.pulse;

    return SingleChildScrollView(
      key: const ValueKey('contacts_tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NativeTopBar(
            title: 'Contacts',
            subtitle: 'Saved caller identities & profiles',
          ),
          const SizedBox(height: 10),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: pulse.surface,
              borderRadius: BorderRadius.circular(PulseRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: pulse.inkSubtle, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Search contacts...',
                  style: TextStyle(color: pulse.inkSubtle, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Add Custom Contact Button
          PulsePressable(
            onTap: _openCustomCallerBottomSheet,
            borderRadius: PulseRadius.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: pulse.surface,
                borderRadius: BorderRadius.circular(PulseRadius.md),
                border: Border.all(color: pulse.cyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pulse.cyan.withValues(alpha: 0.18),
                    ),
                    child: Icon(Icons.person_add_rounded, color: pulse.cyan, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Custom Contact',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Create custom caller name, number & line',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: pulse.cyan, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contacts Inset Group
          PulseInsetGroup(
            title: 'All Contacts',
            children: List.generate(callerPresets.length, (index) {
              final preset = callerPresets[index];
              return Column(
                children: [
                  NativeContactRow(
                    preset: preset,
                    onCall: () {
                      _controller.applyPreset(index);
                      _previewCall();
                    },
                    onSchedule: () {
                      _controller.applyPreset(index);
                      _openScheduleBottomSheet();
                    },
                  ),
                  if (index < callerPresets.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Divider(height: 1, color: pulse.line),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: TRIGGERS (Control Center Escape Hub) ---
  Widget _buildTriggersTab() {
    final pulse = context.pulse;
    final scheduled = _controller.scheduled;

    return SingleChildScrollView(
      key: const ValueKey('triggers_tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NativeTopBar(
            title: 'Quick Triggers',
            subtitle: '1-tap escape shortcuts',
            trailing: scheduled.isNotEmpty
                ? TextButton(
                    onPressed: () => _controller.clearQueue(pulse.danger),
                    child: const Text(
                      'Cancel All',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),

          // Active Queue Banner if running
          if (scheduled.isNotEmpty) ...[
            PulseInsetGroup(
              title: 'Active Scheduled Queue',
              children: List.generate(scheduled.length, (index) {
                final call = scheduled[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          call.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        formatDurationShort(call.remaining),
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            _controller.cancelCall(call.id, pulse.danger),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
          ],

          // Quick Scenario Escape Cards
          PulseInsetGroup(
            title: 'Escape Scenarios',
            children: List.generate(callTemplates.length, (index) {
              final template = callTemplates[index];
              return Column(
                children: [
                  TriggerControlCard(
                    title: template.title,
                    subtitle: template.description,
                    callerName: template.name,
                    delaySeconds: template.delaySeconds,
                    icon: template.icon,
                    color: template.accent,
                    onTap: () {
                      _controller.applyTemplate(template);
                      _scheduleCall();
                    },
                  ),
                  if (index < callTemplates.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Divider(height: 1, color: pulse.line),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: RECENTS (Authentic Call History) ---
  Widget _buildRecentsTab() {
    final history = _controller.history;
    final pulse = context.pulse;

    return SingleChildScrollView(
      key: const ValueKey('recents_tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NativeTopBar(
            title: 'Recents',
            subtitle: 'Recent call activity & logs',
          ),
          const SizedBox(height: 10),

          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: pulse.inkSubtle,
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Recent Calls',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simulated and answered calls will appear here.',
                      style: TextStyle(color: pulse.inkSubtle, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            PulseInsetGroup(
              title: 'Call History',
              children: List.generate(history.length, (index) {
                final item = history[index];
                return InkWell(
                  onTap: () {
                    _controller.nameController.text = item.name;
                    _controller.numberController.text = item.number;
                    _controller.noteController.text = item.note;
                    _controller.selectedSkin = item.skin;
                    _previewCall();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.status.icon,
                          color: item.status.color,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item.note.isNotEmpty ? item.note : item.number,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: pulse.inkSubtle,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatClock(item.createdAt),
                              style: TextStyle(
                                color: pulse.inkMuted,
                                fontSize: 12,
                              ),
                            ),
                            if (item.duration.inSeconds > 0)
                              Text(
                                '${item.duration.inSeconds}s',
                                style: TextStyle(
                                  color: item.status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: pulse.inkSubtle,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  // --- TAB 4: SETTINGS (Authentic Real-World Native Settings) ---
  Widget _buildSettingsTab() {
    final pulse = context.pulse;

    return SingleChildScrollView(
      key: const ValueKey('settings_tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NativeTopBar(
            title: 'Settings',
            subtitle: 'Theme, haptics & preferences',
          ),
          const SizedBox(height: 10),

          // Profile Header
          const SettingsProfileHeader(),
          const SizedBox(height: 18),

          // Section 1: CALL APPEARANCE
          PulseInsetGroup(
            title: 'Call Appearance',
            children: [
              SettingsTile(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'Call Screen Theme',
                value: _controller.selectedSkin.label,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SettingsThemePickerSheet(
                      selectedSkin: _controller.selectedSkin,
                      onSelected: _controller.setSkin,
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.sim_card_rounded,
                iconColor: const Color(0xFF0EA5E9),
                title: 'Default Carrier Line',
                value: _controller.selectedCarrier,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SettingsCarrierPickerSheet(
                      selectedCarrier: _controller.selectedCarrier,
                      onSelected: _controller.setCarrier,
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.visibility_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Show Phone Number',
                subtitle: 'Display number on incoming call screen',
                trailing: Switch.adaptive(
                  value: _controller.showCallerNumber,
                  onChanged: _controller.setShowCallerNumber,
                ),
              ),
              SettingsTile(
                icon: Icons.timer_off_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Auto-End Call',
                subtitle: 'End call automatically after answered',
                trailing: Switch.adaptive(
                  value: _controller.autoEndCall,
                  onChanged: _controller.setAutoEndCall,
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section 2: SOUND & HAPTICS
          PulseInsetGroup(
            title: 'Sound & Haptics',
            children: [
              SettingsTile(
                icon: Icons.vibration_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Vibration Pattern',
                value: _controller.selectedVibration.label,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SettingsVibrationPickerSheet(
                      selectedPattern: _controller.selectedVibration,
                      onSelected: _controller.setVibrationPattern,
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFF43F5E),
                title: 'Vibrate on Ring',
                trailing: Switch.adaptive(
                  value: _controller.vibrate,
                  onChanged: _controller.setVibrate,
                ),
              ),
              SettingsTile(
                icon: Icons.flash_on_rounded,
                iconColor: const Color(0xFFEAB308),
                title: 'Screen Flash on Ring',
                subtitle: 'Subtle white screen strobe when call rings',
                trailing: Switch.adaptive(
                  value: _controller.screenFlash,
                  onChanged: _controller.setScreenFlash,
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section 3: HARDWARE & SENSORS
          PulseInsetGroup(
            title: 'Hardware & Sensors',
            children: [
              SettingsTile(
                icon: Icons.sensors_rounded,
                iconColor: const Color(0xFFA855F7),
                title: 'Ear Proximity Sensor',
                subtitle: 'Dims display when phone is held close to ear',
                trailing: Switch.adaptive(
                  value: _controller.proximityBlackout,
                  onChanged: _controller.setProximityBlackout,
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section 4: DATA & STORAGE
          PulseInsetGroup(
            title: 'Data & Storage',
            children: [
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'Clear Call History',
                subtitle: 'Delete all simulated call activity logs',
                onTap: () {
                  if (_controller.history.isEmpty) {
                    _showSnack('Call history is already empty');
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: pulse.surfaceStrong,
                      title: const Text('Clear Call History?'),
                      content: const Text(
                        'All previous simulated call logs will be removed.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: pulse.danger,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _controller.clearHistory();
                            _showSnack('Call history cleared', isSuccess: true);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.hourglass_disabled_rounded,
                iconColor: const Color(0xFFF97316),
                title: 'Clear Scheduled Queue',
                subtitle: 'Cancel any pending scheduled calls',
                onTap: () {
                  if (_controller.scheduled.isEmpty) {
                    _showSnack('No calls currently scheduled');
                    return;
                  }
                  _controller.clearQueue(pulse.danger);
                  _showSnack('Scheduled queue cleared', isSuccess: true);
                },
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section 5: ABOUT & SYSTEM
          PulseInsetGroup(
            title: 'About',
            children: const [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: Color(0xFF64748B),
                title: 'App Version',
                value: '1.0.4+4 (Build 4)',
              ),
              SettingsTile(
                icon: Icons.security_rounded,
                iconColor: Color(0xFF10B981),
                title: 'Simulation Mode',
                value: '100% Offline',
                subtitle: 'All calls are generated locally on device',
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
