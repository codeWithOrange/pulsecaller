import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pulsecall/models/call_models.dart';

class CallStudioController extends ChangeNotifier {
  CallStudioController() {
    applyPreset(0, notify: false);
    nameController.addListener(_onTextChanged);
    numberController.addListener(_onTextChanged);
    noteController.addListener(_onTextChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_scheduled.isNotEmpty) notifyListeners();
    });
  }

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final noteController = TextEditingController();

  final List<ScheduledCall> _scheduled = [];
  final List<CallHistoryItem> _history = [];
  final quickDelays = const [5, 15, 30, 60, 180, 300];

  Timer? _ticker;
  bool _mutingTextListeners = false;

  int selectedPage = 0;
  int selectedPreset = 0;
  int selectedProfile = 0;
  int delaySeconds = 15;
  int repeatCount = 1;
  int autoEndSeconds = 45;
  bool vibrate = true;
  bool screenFlash = false;
  bool showCallerNumber = true;
  bool autoEndCall = false;

  List<ScheduledCall> get scheduled => List.unmodifiable(_scheduled);
  List<CallHistoryItem> get history => List.unmodifiable(_history);
  CallProfile get currentProfile => callProfiles[selectedProfile];

  String get callerName {
    final value = nameController.text.trim();
    return value.isEmpty ? callerPresets[selectedPreset].name : value;
  }

  String get callerNumber {
    final value = numberController.text.trim();
    return value.isEmpty ? callerPresets[selectedPreset].number : value;
  }

  String get callNote => noteController.text.trim();
  int? get resolvedAutoEndSeconds => autoEndCall ? autoEndSeconds : null;

  void _onTextChanged() {
    if (!_mutingTextListeners) notifyListeners();
  }

  void selectPage(int value) {
    selectedPage = value;
    notifyListeners();
  }

  void applyPreset(int index, {bool notify = true}) {
    selectedPreset = index;
    final preset = callerPresets[index];
    _setText(() {
      nameController.text = preset.name;
      numberController.text = preset.number;
    });
    if (notify) notifyListeners();
  }

  void applyTemplate(CallTemplate template) {
    _setText(() {
      nameController.text = template.name;
      numberController.text = template.number;
      noteController.text = template.note;
    });
    delaySeconds = template.delaySeconds;
    repeatCount = template.repeatCount;
    selectedProfile = template.profileIndex;
    vibrate = template.vibrate;
    screenFlash = template.screenFlash;
    showCallerNumber = template.showCallerNumber;
    autoEndCall = template.autoEndSeconds != null;
    autoEndSeconds = template.autoEndSeconds ?? autoEndSeconds;
    selectedPage = 0;
    recordHistory(
      title: 'Template loaded',
      subtitle: template.title,
      icon: Icons.layers_outlined,
      accent: template.accent,
    );
    notifyListeners();
  }

  void _setText(VoidCallback update) {
    _mutingTextListeners = true;
    update();
    _mutingTextListeners = false;
  }

  void setDelay(int value) {
    delaySeconds = value;
    notifyListeners();
  }

  void setRepeat(int value) {
    repeatCount = value;
    notifyListeners();
  }

  void setProfile(int value) {
    selectedProfile = value;
    notifyListeners();
  }

  void setVibrate(bool value) {
    vibrate = value;
    notifyListeners();
  }

  void setScreenFlash(bool value) {
    screenFlash = value;
    notifyListeners();
  }

  void setShowCallerNumber(bool value) {
    showCallerNumber = value;
    notifyListeners();
  }

  void setAutoEndCall(bool value) {
    autoEndCall = value;
    notifyListeners();
  }

  void setAutoEndSeconds(int value) {
    autoEndSeconds = value;
    notifyListeners();
  }

  bool scheduleCalls(ValueChanged<String> onLaunch) {
    final name = nameController.text.trim();
    final number = numberController.text.trim();
    if (name.isEmpty) return false;

    for (var index = 0; index < repeatCount; index++) {
      final totalDelay = delaySeconds * (index + 1);
      final fireAt = DateTime.now().add(Duration(seconds: totalDelay));
      final id = '${fireAt.microsecondsSinceEpoch}-$index';
      final call = ScheduledCall(
        id: id,
        name: name,
        number: number.isEmpty ? 'Private Number' : number,
        delaySeconds: totalDelay,
        vibrate: vibrate,
        screenFlash: screenFlash,
        showCallerNumber: showCallerNumber,
        callNote: callNote,
        callProfile: currentProfile.label,
        profileAccent: currentProfile.accent,
        autoEndSeconds: resolvedAutoEndSeconds,
        scheduledAt: fireAt,
        timer: Timer(fireAt.difference(DateTime.now()), () => onLaunch(id)),
      );
      _scheduled.insert(0, call);
    }

    _scheduled.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    recordHistory(
      title: repeatCount == 1 ? 'Call scheduled' : 'Batch scheduled',
      subtitle: '$name in ${formatDurationShort(Duration(seconds: delaySeconds))}',
      icon: Icons.add_call,
      accent: currentProfile.accent,
    );
    notifyListeners();
    return true;
  }

  ScheduledCall? popCall(String id) {
    final call = _scheduled.where((item) => item.id == id).firstOrNull;
    if (call == null) return null;
    _scheduled.removeWhere((item) => item.id == id);
    recordHistory(
      title: 'Call launched',
      subtitle: call.name,
      icon: Icons.phone_callback_outlined,
      accent: call.profileAccent,
    );
    notifyListeners();
    return call;
  }

  void cancelCall(String id, Color accent) {
    final call = _scheduled.where((item) => item.id == id).firstOrNull;
    call?.timer.cancel();
    _scheduled.removeWhere((item) => item.id == id);
    if (call != null) {
      recordHistory(
        title: 'Schedule cancelled',
        subtitle: call.name,
        icon: Icons.cancel_outlined,
        accent: accent,
      );
    }
    notifyListeners();
  }

  void clearQueue(Color accent) {
    if (_scheduled.isEmpty) return;
    final count = _scheduled.length;
    for (final call in _scheduled) {
      call.timer.cancel();
    }
    _scheduled.clear();
    recordHistory(
      title: 'Queue cleared',
      subtitle: '$count calls removed',
      icon: Icons.delete_sweep_outlined,
      accent: accent,
    );
    notifyListeners();
  }

  void recordPreview() {
    recordHistory(
      title: 'Preview opened',
      subtitle: callerName,
      icon: Icons.play_circle_outline,
      accent: currentProfile.accent,
    );
    notifyListeners();
  }

  void recordHistory({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    _history.insert(
      0,
      CallHistoryItem(
        title: title,
        subtitle: subtitle,
        icon: icon,
        accent: accent,
        createdAt: DateTime.now(),
      ),
    );
    if (_history.length > 30) _history.removeLast();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final call in _scheduled) {
      call.timer.cancel();
    }
    nameController.dispose();
    numberController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
