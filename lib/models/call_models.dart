import 'dart:async';
import 'package:flutter/material.dart';

enum CallScreenSkin {
  ios('iPhone (iOS)', 'iOS style call screen with slide to answer', Icons.phone_iphone),
  pixel('Google Pixel', 'Clean Android call layout with swipe controls', Icons.android),
  oneUi('Samsung Galaxy', 'One UI style call layout with circular buttons', Icons.smartphone),
  pulseDark('Dark Minimal', 'Dark theme call layout with audio wave indicator', Icons.graphic_eq);

  const CallScreenSkin(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;
}

enum CallStatus {
  answered('Answered', Icons.call_received, Color(0xFF10B981)),
  declined('Declined', Icons.call_end, Color(0xFFEF4444)),
  missed('Missed', Icons.call_missed, Color(0xFFF59E0B)),
  scheduled('Scheduled', Icons.alarm, Color(0xFF38BDF8)),
  previewed('Preview', Icons.play_circle_fill, Color(0xFFA855F7));

  const CallStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum VibrationPatternType {
  standard('Normal', [500, 1000]),
  heartbeat('Heartbeat', [150, 200, 150, 800]),
  urgent('Fast Pulse', [200, 200, 200, 200, 200, 600]),
  sos('SOS', [100, 100, 100, 100, 300, 300, 100, 100]),
  silent('Silent (Off)', []);

  const VibrationPatternType(this.label, this.pattern);
  final String label;
  final List<int> pattern;
}

class CallerPreset {
  const CallerPreset({
    required this.name,
    required this.number,
    required this.tag,
    required this.carrier,
    required this.accent,
    required this.icon,
    this.defaultNote = '',
  });

  final String name;
  final String number;
  final String tag;
  final String carrier;
  final Color accent;
  final IconData icon;
  final String defaultNote;
}

class CallProfile {
  const CallProfile({
    required this.label,
    required this.description,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String description;
  final Color accent;
  final IconData icon;
}

class CallTemplate {
  const CallTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.name,
    required this.number,
    required this.carrier,
    required this.note,
    required this.delaySeconds,
    required this.repeatCount,
    required this.profileIndex,
    required this.vibrate,
    required this.screenFlash,
    required this.showCallerNumber,
    required this.autoEndSeconds,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String name;
  final String number;
  final String carrier;
  final String note;
  final int delaySeconds;
  final int repeatCount;
  final int profileIndex;
  final bool vibrate;
  final bool screenFlash;
  final bool showCallerNumber;
  final int? autoEndSeconds;
  final Color accent;
  final IconData icon;
}

class CallHistoryItem {
  const CallHistoryItem({
    required this.id,
    required this.name,
    required this.number,
    required this.note,
    required this.status,
    required this.duration,
    required this.skin,
    required this.accent,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String number;
  final String note;
  final CallStatus status;
  final Duration duration;
  final CallScreenSkin skin;
  final Color accent;
  final DateTime createdAt;
}

class ScheduledCall {
  ScheduledCall({
    required this.id,
    required this.name,
    required this.number,
    required this.carrier,
    required this.delaySeconds,
    required this.vibrate,
    required this.vibrationPattern,
    required this.screenFlash,
    required this.showCallerNumber,
    required this.callNote,
    required this.callProfile,
    required this.skin,
    required this.profileAccent,
    required this.autoEndSeconds,
    required this.scheduledAt,
    required this.timer,
  });

  final String id;
  final String name;
  final String number;
  final String carrier;
  final int delaySeconds;
  final bool vibrate;
  final VibrationPatternType vibrationPattern;
  final bool screenFlash;
  final bool showCallerNumber;
  final String callNote;
  final String callProfile;
  final CallScreenSkin skin;
  final Color profileAccent;
  final int? autoEndSeconds;
  DateTime scheduledAt;
  Timer timer;

  Duration get remaining {
    final value = scheduledAt.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }
}

const callerPresets = [
  CallerPreset(
    name: 'Rohit Sharma',
    number: '+91 98201 44521',
    tag: 'Office',
    carrier: 'SIM 1 - Jio 5G',
    accent: Color(0xFF38BDF8),
    icon: Icons.business_center_rounded,
    defaultNote: 'Need you on the project discussion call.',
  ),
  CallerPreset(
    name: 'Mom',
    number: '+91 98765 43210',
    tag: 'Family',
    carrier: 'SIM 2 - Airtel',
    accent: Color(0xFFF43F5E),
    icon: Icons.favorite_rounded,
    defaultNote: 'Call back when you are free.',
  ),
  CallerPreset(
    name: 'Courier Delivery',
    number: '+91 91234 56789',
    tag: 'Delivery',
    carrier: 'Cellular',
    accent: Color(0xFF10B981),
    icon: Icons.local_shipping_rounded,
    defaultNote: 'Package delivery at your address.',
  ),
  CallerPreset(
    name: 'Private Number',
    number: 'Unknown',
    tag: 'Unknown',
    carrier: 'Private Line',
    accent: Color(0xFFF59E0B),
    icon: Icons.security_rounded,
    defaultNote: 'Incoming private call.',
  ),
  CallerPreset(
    name: 'Rahul Verma',
    number: '+91 90000 12345',
    tag: 'Friend',
    carrier: 'WhatsApp Audio',
    accent: Color(0xFFA855F7),
    icon: Icons.people_alt_rounded,
    defaultNote: 'Call me back as soon as you see this.',
  ),
  CallerPreset(
    name: 'Dr. Mehta',
    number: '+91 98222 33445',
    tag: 'Clinic',
    carrier: 'SIM 1 - Jio 5G',
    accent: Color(0xFF06B6D4),
    icon: Icons.medical_services_rounded,
    defaultNote: 'Regarding your scheduled appointment.',
  ),
];

const callProfiles = [
  CallProfile(
    label: 'Standard',
    description: 'Normal incoming call display',
    accent: Color(0xFF38BDF8),
    icon: Icons.phone_in_talk_rounded,
  ),
  CallProfile(
    label: 'Priority',
    description: 'High priority call alert',
    accent: Color(0xFFF59E0B),
    icon: Icons.priority_high_rounded,
  ),
  CallProfile(
    label: 'Discreet',
    description: 'Silent vibration and hidden number',
    accent: Color(0xFF94A3B8),
    icon: Icons.shield_rounded,
  ),
  CallProfile(
    label: 'Emergency',
    description: 'Continuous vibration alert with flash',
    accent: Color(0xFFEF4444),
    icon: Icons.warning_amber_rounded,
  ),
];

const callTemplates = [
  CallTemplate(
    id: 'work_urgent',
    title: 'Work Meeting Call',
    description: 'Urgent office call scenario for meetings and work tasks.',
    category: 'Work',
    name: 'Rohit Sharma',
    number: '+91 98201 44521',
    carrier: 'SIM 1 - Jio 5G',
    note: 'Please join the bridge call for client update.',
    delaySeconds: 15,
    repeatCount: 1,
    profileIndex: 1,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: 45,
    accent: Color(0xFF38BDF8),
    icon: Icons.business_center_rounded,
  ),
  CallTemplate(
    id: 'friend_checkin',
    title: 'Friend Callback',
    description: 'Casual check-in call from a friend.',
    category: 'Personal',
    name: 'Rahul Verma',
    number: '+91 90000 12345',
    carrier: 'WhatsApp Audio',
    note: 'Hey, please call me back as soon as you can.',
    delaySeconds: 10,
    repeatCount: 1,
    profileIndex: 0,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: 30,
    accent: Color(0xFFA855F7),
    icon: Icons.people_alt_rounded,
  ),
  CallTemplate(
    id: 'delivery_pickup',
    title: 'Delivery Partner',
    description: 'Courier or delivery arrival call.',
    category: 'Delivery',
    name: 'Courier Delivery',
    number: '+91 91234 56789',
    carrier: 'Cellular',
    note: 'Package arrival at your address.',
    delaySeconds: 20,
    repeatCount: 1,
    profileIndex: 0,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: 30,
    accent: Color(0xFF10B981),
    icon: Icons.local_shipping_rounded,
  ),
  CallTemplate(
    id: 'family_reminder',
    title: 'Family Call',
    description: 'Home reminder call from family.',
    category: 'Family',
    name: 'Mom',
    number: '+91 98765 43210',
    carrier: 'SIM 2 - Airtel',
    note: 'Call back when you are free.',
    delaySeconds: 30,
    repeatCount: 2,
    profileIndex: 0,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: null,
    accent: Color(0xFFF43F5E),
    icon: Icons.favorite_rounded,
  ),
  CallTemplate(
    id: 'private_check',
    title: 'Private Number',
    description: 'Discreet call with hidden caller ID.',
    category: 'Discreet',
    name: 'Private Number',
    number: 'Unknown',
    carrier: 'Private Line',
    note: 'Incoming private call.',
    delaySeconds: 5,
    repeatCount: 1,
    profileIndex: 2,
    vibrate: true,
    screenFlash: true,
    showCallerNumber: false,
    autoEndSeconds: 30,
    accent: Color(0xFFF59E0B),
    icon: Icons.shield_rounded,
  ),
];

const availableCarriers = [
  'SIM 1 - Jio 5G',
  'SIM 2 - Airtel 5G',
  'WhatsApp Audio',
  'Telegram Audio',
  'Cellular',
  'Private Line',
];

String formatDurationShort(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds < 60) return '${totalSeconds}s';
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
}

String formatClock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
