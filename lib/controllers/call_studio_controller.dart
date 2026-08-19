import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pulsecall/models/call_models.dart';

class CallStudioController extends ChangeNotifier {
  CallStudioController() {
    applyPreset(0, notify: false);
    nameController.addListener(_onTextChanged);
    numberController.addListener(_onTextChanged);
    noteController.addListener(_onTextChanged);
    dialpadController.addListener(_onTextChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_scheduled.isNotEmpty) notifyListeners();
    });
  }

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final noteController = TextEditingController();
  final dialpadController = TextEditingController();

  final List<ScheduledCall> _scheduled = [];
  final List<CallHistoryItem> _history = [];
  final quickDelays = const [5, 10, 15, 30, 60, 180, 300];

  Timer? _ticker;
  bool _mutingTextListeners = false;

  int selectedPage = 0;
  int selectedPreset = 0;
  int selectedProfile = 0;
  CallScreenSkin selectedSkin = CallScreenSkin.ios;
  String selectedCarrier = 'SIM 1 - Jio 5G';
  VibrationPatternType selectedVibration = VibrationPatternType.standard;

  int delaySeconds = 15;
  int repeatCount = 1;
  int autoEndSeconds = 45;
  bool vibrate = true;
  bool screenFlash = false;
  bool showCallerNumber = true;
  bool autoEndCall = false;
  bool proximityBlackout = true;

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

  void setSkin(CallScreenSkin skin) {
    selectedSkin = skin;
    notifyListeners();
  }

  void setCarrier(String carrier) {
    selectedCarrier = carrier;
    notifyListeners();
  }

  void setVibrationPattern(VibrationPatternType pattern) {
    selectedVibration = pattern;
    vibrate = pattern != VibrationPatternType.silent;
    notifyListeners();
  }

  void setProximityBlackout(bool value) {
    proximityBlackout = value;
    notifyListeners();
  }

  void applyPreset(int index, {bool notify = true}) {
    if (index < 0 || index >= callerPresets.length) return;
    selectedPreset = index;
    final preset = callerPresets[index];
    _setText(() {
      nameController.text = preset.name;
      numberController.text = preset.number;
      dialpadController.text = preset.number;
      noteController.text = preset.defaultNote;
    });
    selectedCarrier = preset.carrier;
    if (notify) notifyListeners();
  }

  void setCustomCaller({
    required String name,
    required String number,
    required String carrier,
    String note = '',
  }) {
    selectedPreset = -1;
    _setText(() {
      nameController.text = name;
      numberController.text = number;
      dialpadController.text = number;
      noteController.text = note;
    });
    selectedCarrier = carrier;
    notifyListeners();
  }

  void applyTemplate(CallTemplate template) {
    selectedPreset = -1;
    _setText(() {
      nameController.text = template.name;
      numberController.text = template.number;
      dialpadController.text = template.number;
      noteController.text = template.note;
    });
    selectedCarrier = template.carrier;
    delaySeconds = template.delaySeconds;
    repeatCount = template.repeatCount;
    selectedProfile = template.profileIndex.clamp(0, callProfiles.length - 1);
    vibrate = template.vibrate;
    screenFlash = template.screenFlash;
    showCallerNumber = template.showCallerNumber;
    autoEndCall = template.autoEndSeconds != null;
    autoEndSeconds = template.autoEndSeconds ?? autoEndSeconds;
    selectedPage = 0; // jump to keypad
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
    if (!value) {
      selectedVibration = VibrationPatternType.silent;
    } else if (selectedVibration == VibrationPatternType.silent) {
      selectedVibration = VibrationPatternType.standard;
    }
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

  // Dialpad functionality
  void dialDigit(String digit) {
    dialpadController.text += digit;
    notifyListeners();
  }

  void dialBackspace() {
    final text = dialpadController.text;
    if (text.isNotEmpty) {
      dialpadController.text = text.substring(0, text.length - 1);
      notifyListeners();
    }
  }

  void clearDialpad() {
    dialpadController.clear();
    notifyListeners();
  }

  void scheduleFromDialpad(ValueChanged<String> onLaunch) {
    final dialed = dialpadController.text.trim();
    if (dialed.isEmpty) return;
    _setText(() {
      nameController.text = 'Custom Dial';
      numberController.text = dialed;
    });
    scheduleCalls(onLaunch);
    selectedPage = 0;
  }

  bool quickEscapeTrigger(int delaySec, ValueChanged<String> onLaunch) {
    delaySeconds = delaySec;
    repeatCount = 1;
    return scheduleCalls(onLaunch);
  }

  bool scheduleCalls(ValueChanged<String> onLaunch) {
    final name = callerName;
    final number = callerNumber;
    if (name.isEmpty) return false;

    for (var index = 0; index < repeatCount; index++) {
      final totalDelay = delaySeconds * (index + 1);
      final fireAt = DateTime.now().add(Duration(seconds: totalDelay));
      final id = '${fireAt.microsecondsSinceEpoch}-$index';
      final call = ScheduledCall(
        id: id,
        name: name,
        number: number.isEmpty ? 'Private Number' : number,
        carrier: selectedCarrier,
        delaySeconds: totalDelay,
        vibrate: vibrate,
        vibrationPattern: selectedVibration,
        screenFlash: screenFlash,
        showCallerNumber: showCallerNumber,
        callNote: callNote,
        callProfile: currentProfile.label,
        skin: selectedSkin,
        profileAccent: currentProfile.accent,
        autoEndSeconds: resolvedAutoEndSeconds,
        scheduledAt: fireAt,
        timer: Timer(fireAt.difference(DateTime.now()), () => onLaunch(id)),
      );
      _scheduled.insert(0, call);
    }

    _scheduled.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    notifyListeners();
    return true;
  }

  ScheduledCall? popCall(String id) {
    final call = _scheduled.where((item) => item.id == id).firstOrNull;
    if (call == null) return null;
    _scheduled.removeWhere((item) => item.id == id);
    notifyListeners();
    return call;
  }

  void snoozeCall(String id, int extraSeconds, ValueChanged<String> onLaunch) {
    final call = _scheduled.where((item) => item.id == id).firstOrNull;
    if (call == null) return;
    call.timer.cancel();
    final newScheduledAt = DateTime.now().add(Duration(seconds: extraSeconds));
    call.scheduledAt = newScheduledAt;
    call.timer = Timer(
      newScheduledAt.difference(DateTime.now()),
      () => onLaunch(id),
    );
    _scheduled.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    notifyListeners();
  }

  void cancelCall(String id, Color accent) {
    final call = _scheduled.where((item) => item.id == id).firstOrNull;
    call?.timer.cancel();
    _scheduled.removeWhere((item) => item.id == id);
    if (call != null) {
      recordCallResult(
        name: call.name,
        number: call.number,
        note: 'Cancelled pending call',
        status: CallStatus.declined,
        duration: Duration.zero,
        skin: call.skin,
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
    recordCallResult(
      name: 'Queue Cleared',
      number: '$count removed',
      note: 'Cleared all pending scheduled triggers',
      status: CallStatus.declined,
      duration: Duration.zero,
      skin: selectedSkin,
      accent: accent,
    );
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void recordCallResult({
    required String name,
    required String number,
    required String note,
    required CallStatus status,
    required Duration duration,
    required CallScreenSkin skin,
    required Color accent,
  }) {
    _history.insert(
      0,
      CallHistoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        number: number,
        note: note,
        status: status,
        duration: duration,
        skin: skin,
        accent: accent,
        createdAt: DateTime.now(),
      ),
    );
    if (_history.length > 40) _history.removeLast();
    notifyListeners();
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
    dialpadController.dispose();
    super.dispose();
  }
}
