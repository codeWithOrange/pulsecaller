import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulsecall/models/call_models.dart';
import 'package:pulsecall/theme/app_theme.dart';

// --- NATIVE NAVIGATION BAR (5 Native Mobile Tabs) ---
class NativeAppNavigationBar extends StatelessWidget {
  const NativeAppNavigationBar({
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
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.dialpad_rounded),
          selectedIcon: Icon(Icons.dialpad_rounded),
          label: 'Keypad',
        ),
        const NavigationDestination(
          icon: Icon(Icons.contacts_rounded),
          selectedIcon: Icon(Icons.contacts_rounded),
          label: 'Contacts',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: queuedCount > 0,
            label: Text('$queuedCount'),
            backgroundColor: const Color(0xFF38BDF8),
            textColor: Colors.black,
            child: const Icon(Icons.bolt_rounded),
          ),
          selectedIcon: Badge(
            isLabelVisible: queuedCount > 0,
            label: Text('$queuedCount'),
            backgroundColor: const Color(0xFF38BDF8),
            textColor: Colors.black,
            child: const Icon(Icons.bolt_rounded),
          ),
          label: 'Triggers',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: historyCount > 0,
            label: Text('$historyCount'),
            backgroundColor: const Color(0xFFF43F5E),
            child: const Icon(Icons.history_rounded),
          ),
          selectedIcon: Badge(
            isLabelVisible: historyCount > 0,
            label: Text('$historyCount'),
            backgroundColor: const Color(0xFFF43F5E),
            child: const Icon(Icons.history_rounded),
          ),
          label: 'Recents',
        ),
        const NavigationDestination(
          icon: Icon(Icons.tune_rounded),
          selectedIcon: Icon(Icons.tune_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}

// --- NATIVE TOP BAR ---
class NativeTopBar extends StatelessWidget {
  const NativeTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// --- FAVORITES AVATARS STRIP (Top of Keypad) ---
class FavoritesAvatarStrip extends StatelessWidget {
  const FavoritesAvatarStrip({
    super.key,
    required this.presets,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddCustom,
  });

  final List<CallerPreset> presets;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAddCustom;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          // First item is "+ Custom"
          if (index == 0) {
            return PulsePressable(
              onTap: onAddCustom,
              borderRadius: PulseRadius.md,
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pulse.cyan.withValues(alpha: 0.15),
                      border: Border.all(
                        color: pulse.cyan.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.add_rounded, color: pulse.cyan, size: 24),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 58,
                    child: Text(
                      '+ Custom',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: pulse.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final presetIndex = index - 1;
          final preset = presets[presetIndex];
          final isSelected = presetIndex == selectedIndex;

          return PulsePressable(
            onTap: () => onSelected(presetIndex),
            borderRadius: PulseRadius.md,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? preset.accent.withValues(alpha: 0.22)
                        : pulse.surface,
                    border: Border.all(
                      color: isSelected ? preset.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    preset.icon,
                    color: isSelected ? preset.accent : pulse.inkSubtle,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 58,
                  child: Text(
                    preset.name.split(' ').first,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : pulse.inkSubtle,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- NATIVE PHONE KEYPAD WITH ACTION BUTTONS ---
class NativePhoneKeypad extends StatelessWidget {
  const NativePhoneKeypad({
    super.key,
    required this.controller,
    required this.onDigit,
    required this.onBackspace,
    required this.onSchedule,
    required this.onCallNow,
    required this.onQuickSOS,
  });

  final TextEditingController controller;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSchedule;
  final VoidCallback onCallNow;
  final VoidCallback onQuickSOS;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final text = controller.text;

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

    return Column(
      children: [
        // Number Display Bar
        Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text.isEmpty ? ' ' : text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (text.isNotEmpty)
                IconButton(
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_rounded, color: Colors.white70, size: 20),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Keypad Grid
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.18,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final digit = keys[index][0];
              final sub = keys[index][1];

              return PulsePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDigit(digit);
                },
                borderRadius: PulseRadius.pill,
                child: Container(
                  decoration: BoxDecoration(
                    color: pulse.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        digit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (sub.isNotEmpty)
                        Text(
                          sub,
                          style: TextStyle(
                            color: pulse.inkSubtle,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 3 Action Buttons (Schedule, Call, 5s SOS)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⏰ Schedule Button
            PulsePressable(
              onTap: onSchedule,
              borderRadius: PulseRadius.pill,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: pulse.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.alarm_rounded, color: pulse.cyan, size: 22),
              ),
            ),
            const SizedBox(width: 24),

            // 📞 Primary Call Button
            PulsePressable(
              onTap: onCallNow,
              borderRadius: PulseRadius.pill,
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.call_rounded, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 24),

            // ⚡ 5s SOS Quick Trigger Button
            PulsePressable(
              onTap: onQuickSOS,
              borderRadius: PulseRadius.pill,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: pulse.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: pulse.amber, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- CUSTOM CALLER MODAL BOTTOM SHEET ---
class CustomCallerModalSheet extends StatefulWidget {
  const CustomCallerModalSheet({
    super.key,
    required this.initialName,
    required this.initialNumber,
    required this.initialCarrier,
    required this.initialNote,
    this.initialDelay = 15,
    this.initialRepeat = 1,
    required this.onSaveAndCall,
    required this.onSchedule,
    required this.onSaveAsActive,
  });

  final String initialName;
  final String initialNumber;
  final String initialCarrier;
  final String initialNote;
  final int initialDelay;
  final int initialRepeat;
  final void Function(String name, String number, String carrier, String note) onSaveAndCall;
  final void Function(String name, String number, String carrier, String note, int delay, int repeat) onSchedule;
  final void Function(String name, String number, String carrier, String note) onSaveAsActive;

  @override
  State<CustomCallerModalSheet> createState() => _CustomCallerModalSheetState();
}

class _CustomCallerModalSheetState extends State<CustomCallerModalSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _noteController;
  late String _carrier;
  late int _delay;
  late int _repeat;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _numberController = TextEditingController(text: widget.initialNumber);
    _noteController = TextEditingController(text: widget.initialNote);
    _carrier = widget.initialCarrier;
    _delay = widget.initialDelay;
    _repeat = widget.initialRepeat;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    final delayOptions = [
      (0, 'Now'),
      (5, '5s'),
      (15, '15s'),
      (30, '30s'),
      (60, '1 min'),
      (180, '3 min'),
    ];

    final repeatOptions = [
      (1, '1x'),
      (2, '2x'),
      (3, '3x'),
      (5, '5x'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: pulse.line),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: pulse.inkSubtle.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom Caller Details',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure caller identity, network line & timer countdown',
              style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Caller Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Caller Name',
                hintText: 'e.g. Director Sharma, Papa, Boss',
                prefixIcon: Icon(Icons.person_rounded, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Phone Number
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91 98765 43210',
                prefixIcon: Icon(Icons.call_rounded, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Delay Picker
            Text(
              'COUNTDOWN DELAY TIMER',
              style: TextStyle(color: pulse.inkSubtle, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: delayOptions.map((item) {
                final isSelected = item.$1 == _delay;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: PulsePressable(
                      onTap: () => setState(() => _delay = item.$1),
                      borderRadius: PulseRadius.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? pulse.cyan : pulse.surfaceStrong,
                          borderRadius: BorderRadius.circular(PulseRadius.pill),
                        ),
                        child: Text(
                          item.$2,
                          style: TextStyle(
                            color: isSelected ? Colors.black : pulse.inkMuted,
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Repeat count
            Text(
              'REPEAT RINGS',
              style: TextStyle(color: pulse.inkSubtle, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: repeatOptions.map((item) {
                final isSelected = item.$1 == _repeat;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: PulsePressable(
                      onTap: () => setState(() => _repeat = item.$1),
                      borderRadius: PulseRadius.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? pulse.cyan : pulse.surfaceStrong,
                          borderRadius: BorderRadius.circular(PulseRadius.pill),
                        ),
                        child: Text(
                          item.$2,
                          style: TextStyle(
                            color: isSelected ? Colors.black : pulse.inkMuted,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Carrier Line Selector
            Text(
              'NETWORK LINE',
              style: TextStyle(color: pulse.inkSubtle, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: availableCarriers.map((carrier) {
                final isSelected = carrier == _carrier;
                return PulsePressable(
                  onTap: () => setState(() => _carrier = carrier),
                  borderRadius: PulseRadius.pill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? pulse.cyan.withValues(alpha: 0.2) : pulse.surfaceStrong,
                      borderRadius: BorderRadius.circular(PulseRadius.pill),
                      border: Border.all(
                        color: isSelected ? pulse.cyan : pulse.line,
                      ),
                    ),
                    child: Text(
                      carrier,
                      style: TextStyle(
                        color: isSelected ? Colors.white : pulse.inkSubtle,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Call Note
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Call Note / Message (Optional)',
                hintText: 'e.g. Need you at office for sign-off',
                prefixIcon: Icon(Icons.notes_rounded, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: pulse.cyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PulseRadius.pill),
                      ),
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final number = _numberController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(context);
                      widget.onSaveAsActive(name, number, _carrier, _noteController.text.trim());
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Set Active', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _delay == 0 ? const Color(0xFF10B981) : pulse.cyan,
                      foregroundColor: _delay == 0 ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final number = _numberController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(context);
                      if (_delay == 0) {
                        widget.onSaveAndCall(name, number, _carrier, _noteController.text.trim());
                      } else {
                        widget.onSchedule(
                          name,
                          number,
                          _carrier,
                          _noteController.text.trim(),
                          _delay,
                          _repeat,
                        );
                      }
                    },
                    icon: Icon(
                      _delay == 0 ? Icons.call_rounded : Icons.alarm_add_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _delay == 0
                          ? 'Call Now'
                          : 'Schedule in ${formatDurationShort(Duration(seconds: _delay))}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- NATIVE SCHEDULE BOTTOM SHEET ---
class NativeScheduleModalSheet extends StatefulWidget {
  const NativeScheduleModalSheet({
    super.key,
    required this.callerName,
    required this.callerNumber,
    required this.delaySeconds,
    required this.repeatCount,
    required this.carrier,
    required this.note,
    required this.onConfirm,
  });

  final String callerName;
  final String callerNumber;
  final int delaySeconds;
  final int repeatCount;
  final String carrier;
  final String note;
  final void Function(String name, String number, int delay, int repeat, String note, String carrier) onConfirm;

  @override
  State<NativeScheduleModalSheet> createState() => _NativeScheduleModalSheetState();
}

class _NativeScheduleModalSheetState extends State<NativeScheduleModalSheet> {
  late int _delay;
  late int _repeat;
  late String _carrier;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _delay = widget.delaySeconds;
    _repeat = widget.repeatCount;
    _carrier = widget.carrier;
    _nameController = TextEditingController(text: widget.callerName);
    _numberController = TextEditingController(text: widget.callerNumber);
    _noteController = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    final delayOptions = [
      (5, '5s'),
      (15, '15s'),
      (30, '30s'),
      (60, '1 min'),
      (180, '3 min'),
    ];

    final repeatOptions = [
      (1, '1x'),
      (2, '2x'),
      (3, '3x'),
      (5, '5x'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: pulse.inkSubtle.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Schedule Call',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          // Caller Name & Number (editable)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    labelText: 'Caller Name',
                    prefixIcon: Icon(Icons.person_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    labelText: 'Number',
                    prefixIcon: Icon(Icons.call_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delay Picker
          Text(
            'COUNTDOWN DELAY',
            style: TextStyle(color: pulse.inkSubtle, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: delayOptions.map((item) {
              final isSelected = item.$1 == _delay;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: PulsePressable(
                    onTap: () => setState(() => _delay = item.$1),
                    borderRadius: PulseRadius.pill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? pulse.cyan : pulse.surfaceStrong,
                        borderRadius: BorderRadius.circular(PulseRadius.pill),
                      ),
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          color: isSelected ? Colors.black : pulse.inkMuted,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Repeat count
          Text(
            'REPEAT RINGS',
            style: TextStyle(color: pulse.inkSubtle, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: repeatOptions.map((item) {
              final isSelected = item.$1 == _repeat;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: PulsePressable(
                    onTap: () => setState(() => _repeat = item.$1),
                    borderRadius: PulseRadius.pill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? pulse.cyan : pulse.surfaceStrong,
                        borderRadius: BorderRadius.circular(PulseRadius.pill),
                      ),
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          color: isSelected ? Colors.black : pulse.inkMuted,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Call Note
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Call Note / Message (Optional)',
              hintText: 'e.g. Urgent update regarding meeting',
              prefixIcon: Icon(Icons.notes_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                final name = _nameController.text.trim();
                final number = _numberController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context);
                widget.onConfirm(
                  name,
                  number,
                  _delay,
                  _repeat,
                  _noteController.text.trim(),
                  _carrier,
                );
              },
              icon: const Icon(Icons.alarm_add_rounded, size: 18),
              label: Text(
                'Schedule Call in ${formatDurationShort(Duration(seconds: _delay))}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ESCAPE TRIGGER CARD (Control Center / Widget look) ---
class TriggerControlCard extends StatelessWidget {
  const TriggerControlCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.callerName,
    required this.delaySeconds,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String callerName;
  final int delaySeconds;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return PulsePressable(
      onTap: onTap,
      borderRadius: PulseRadius.md,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pulse.surface,
          borderRadius: BorderRadius.circular(PulseRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$callerName  •  in ${formatDurationShort(Duration(seconds: delaySeconds))}',
                    style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(PulseRadius.pill),
              ),
              child: const Text(
                'Launch',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NATIVE CONTACT ROW (Address Book Look) ---
class NativeContactRow extends StatelessWidget {
  const NativeContactRow({
    super.key,
    required this.preset,
    required this.onCall,
    required this.onSchedule,
  });

  final CallerPreset preset;
  final VoidCallback onCall;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: preset.accent.withValues(alpha: 0.15),
            ),
            child: Icon(preset.icon, color: preset.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${preset.number}  •  ${preset.carrier}',
                  style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Schedule Call',
            onPressed: onSchedule,
            icon: Icon(Icons.alarm_add_rounded, color: pulse.cyan, size: 20),
          ),
          IconButton(
            tooltip: 'Call Now',
            onPressed: onCall,
            icon: const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 20),
          ),
        ],
      ),
    );
  }
}

// --- REAL-WORLD SETTINGS PROFILE HEADER ---
class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pulse.surface,
        borderRadius: BorderRadius.circular(PulseRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pulse.cyan.withValues(alpha: 0.15),
              border: Border.all(color: pulse.cyan.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(Icons.person_rounded, color: pulse.cyan, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PulseCall Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Offline Call Simulation Engine',
                  style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(PulseRadius.pill),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- REAL-WORLD SETTINGS TILE (iOS / Android squircle icon style) ---
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Squircle Icon Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(color: pulse.inkSubtle, fontSize: 11.5),
                        ),
                      ],
                    ],
                  ),
                ),

                // Value / Trailing
                if (value != null) ...[
                  Text(
                    value!,
                    style: TextStyle(
                      color: pulse.inkMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, color: pulse.inkSubtle, size: 18),
                ] else if (trailing != null) ...[
                  trailing!,
                ] else if (onTap != null) ...[
                  Icon(Icons.chevron_right_rounded, color: pulse.inkSubtle, size: 18),
                ],
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 62),
              child: Divider(height: 1, color: pulse.line),
            ),
        ],
      ),
    );
  }
}

// --- THEME PICKER MODAL BOTTOM SHEET ---
class SettingsThemePickerSheet extends StatelessWidget {
  const SettingsThemePickerSheet({
    super.key,
    required this.selectedSkin,
    required this.onSelected,
  });

  final CallScreenSkin selectedSkin;
  final ValueChanged<CallScreenSkin> onSelected;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: pulse.inkSubtle.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose Call Screen Theme',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the visual layout for incoming simulated calls',
            style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Column(
            children: CallScreenSkin.values.map((skin) {
              final isSelected = skin == selectedSkin;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PulsePressable(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(skin);
                  },
                  borderRadius: PulseRadius.md,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? pulse.cyan.withValues(alpha: 0.15)
                          : pulse.surface,
                      borderRadius: BorderRadius.circular(PulseRadius.md),
                      border: Border.all(
                        color: isSelected ? pulse.cyan : pulse.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? pulse.cyan.withValues(alpha: 0.2)
                                : pulse.surfaceStrong,
                          ),
                          child: Icon(skin.icon, color: isSelected ? pulse.cyan : pulse.inkSubtle, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skin.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                skin.description,
                                style: TextStyle(color: pulse.inkSubtle, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: pulse.cyan, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- VIBRATION PICKER MODAL BOTTOM SHEET ---
class SettingsVibrationPickerSheet extends StatelessWidget {
  const SettingsVibrationPickerSheet({
    super.key,
    required this.selectedPattern,
    required this.onSelected,
  });

  final VibrationPatternType selectedPattern;
  final ValueChanged<VibrationPatternType> onSelected;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: pulse.inkSubtle.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vibration Pattern',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to test haptic rhythm',
            style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Column(
            children: VibrationPatternType.values.map((pattern) {
              final isSelected = pattern == selectedPattern;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PulsePressable(
                  onTap: () {
                    if (pattern != VibrationPatternType.silent) {
                      HapticFeedback.heavyImpact();
                    }
                    Navigator.pop(context);
                    onSelected(pattern);
                  },
                  borderRadius: PulseRadius.md,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                          : pulse.surface,
                      borderRadius: BorderRadius.circular(PulseRadius.md),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF59E0B) : pulse.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.vibration_rounded, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            pattern.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFF59E0B), size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- CARRIER LINE PICKER MODAL BOTTOM SHEET ---
class SettingsCarrierPickerSheet extends StatelessWidget {
  const SettingsCarrierPickerSheet({
    super.key,
    required this.selectedCarrier,
    required this.onSelected,
  });

  final String selectedCarrier;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: pulse.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: pulse.inkSubtle.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Default Carrier Line',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Select carrier label shown on incoming calls',
            style: TextStyle(color: pulse.inkSubtle, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Column(
            children: availableCarriers.map((carrier) {
              final isSelected = carrier == selectedCarrier;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PulsePressable(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(carrier);
                  },
                  borderRadius: PulseRadius.md,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? pulse.cyan.withValues(alpha: 0.15)
                          : pulse.surface,
                      borderRadius: BorderRadius.circular(PulseRadius.md),
                      border: Border.all(
                        color: isSelected ? pulse.cyan : pulse.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sim_card_rounded, color: pulse.cyan, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            carrier,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: pulse.cyan, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

