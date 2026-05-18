import 'dart:async';

import 'package:flutter/material.dart';

class CallerPreset {
  const CallerPreset({
    required this.name,
    required this.number,
    required this.tag,
    required this.accent,
    required this.icon,
  });

  final String name;
  final String number;
  final String tag;
  final Color accent;
  final IconData icon;
}

class CallProfile {
  const CallProfile({
    required this.label,
    required this.accent,
    required this.icon,
  });

  final String label;
  final Color accent;
  final IconData icon;
}

class CallTemplate {
  const CallTemplate({
    required this.title,
    required this.description,
    required this.name,
    required this.number,
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

  final String title;
  final String description;
  final String name;
  final String number;
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
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.createdAt,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final DateTime createdAt;
}

class ScheduledCall {
  ScheduledCall({
    required this.id,
    required this.name,
    required this.number,
    required this.delaySeconds,
    required this.vibrate,
    required this.screenFlash,
    required this.showCallerNumber,
    required this.callNote,
    required this.callProfile,
    required this.profileAccent,
    required this.autoEndSeconds,
    required this.scheduledAt,
    required this.timer,
  });

  final String id;
  final String name;
  final String number;
  final int delaySeconds;
  final bool vibrate;
  final bool screenFlash;
  final bool showCallerNumber;
  final String callNote;
  final String callProfile;
  final Color profileAccent;
  final int? autoEndSeconds;
  final DateTime scheduledAt;
  final Timer timer;

  Duration get remaining {
    final value = scheduledAt.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }
}

const callerPresets = [
  CallerPreset(
    name: 'Aarav Sharma',
    number: '+91 98765 43210',
    tag: 'Manager',
    accent: Color(0xFF5EE7DF),
    icon: Icons.work_outline,
  ),
  CallerPreset(
    name: 'Mom',
    number: '+91 91234 56789',
    tag: 'Family',
    accent: Color(0xFFFF8A8A),
    icon: Icons.favorite_border,
  ),
  CallerPreset(
    name: 'Unknown',
    number: 'Private Number',
    tag: 'Urgent',
    accent: Color(0xFFFFC857),
    icon: Icons.privacy_tip_outlined,
  ),
  CallerPreset(
    name: 'Chandan Aditya',
    number: '+91 90000 00000',
    tag: 'Friend',
    accent: Color(0xFF7EF7A6),
    icon: Icons.person_pin_circle_outlined,
  ),
];

const callProfiles = [
  CallProfile(
    label: 'Standard',
    accent: Color(0xFF5EE7DF),
    icon: Icons.phone_in_talk_outlined,
  ),
  CallProfile(
    label: 'Priority',
    accent: Color(0xFFFFC857),
    icon: Icons.priority_high_rounded,
  ),
  CallProfile(
    label: 'Discreet',
    accent: Color(0xFFB8C9D5),
    icon: Icons.lock_outline,
  ),
];

const callTemplates = [
  CallTemplate(
    title: 'Meeting Escape',
    description: 'Professional urgent call for awkward meetings.',
    name: 'Aarav Sharma',
    number: '+91 98765 43210',
    note: 'Need to step out for a quick work escalation.',
    delaySeconds: 15,
    repeatCount: 1,
    profileIndex: 1,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: 45,
    accent: Color(0xFFFFC857),
    icon: Icons.work_outline,
  ),
  CallTemplate(
    title: 'Safety Check',
    description: 'Discreet private call with haptics and hidden number.',
    name: 'Unknown',
    number: 'Private Number',
    note: 'Private check-in. Stay calm and answer normally.',
    delaySeconds: 5,
    repeatCount: 1,
    profileIndex: 2,
    vibrate: true,
    screenFlash: true,
    showCallerNumber: false,
    autoEndSeconds: 30,
    accent: Color(0xFFB8C9D5),
    icon: Icons.shield_outlined,
  ),
  CallTemplate(
    title: 'Family Reminder',
    description: 'Warm family call for reminders or exit cues.',
    name: 'Mom',
    number: '+91 91234 56789',
    note: 'Family needs a quick callback.',
    delaySeconds: 60,
    repeatCount: 2,
    profileIndex: 0,
    vibrate: true,
    screenFlash: false,
    showCallerNumber: true,
    autoEndSeconds: null,
    accent: Color(0xFFFF8A8A),
    icon: Icons.favorite_border,
  ),
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
