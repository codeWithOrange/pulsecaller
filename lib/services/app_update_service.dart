import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppUpdateConfig {
  const AppUpdateConfig({
    required this.appId,
    required this.platform,
    required this.minBuild,
    required this.latestBuild,
    required this.softUpdate,
    required this.hardUpdate,
    required this.maintenanceEnabled,
    required this.title,
    required this.message,
    required this.hardTitle,
    required this.hardMessage,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
    required this.storeUrl,
    required this.startsAt,
    required this.endsAt,
  });

  final String appId;
  final String platform;
  final int minBuild;
  final int latestBuild;
  final bool softUpdate;
  final bool hardUpdate;
  final bool maintenanceEnabled;
  final String title;
  final String message;
  final String hardTitle;
  final String hardMessage;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final String storeUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory AppUpdateConfig.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfig(
      appId: json['app_id']?.toString() ?? '',
      platform: json['platform']?.toString() ?? 'android',
      minBuild: _readInt(json['min_build']),
      latestBuild: _readInt(json['latest_build']),
      softUpdate: _readBool(json['soft_update']),
      hardUpdate: _readBool(json['hard_update']),
      maintenanceEnabled: _readBool(json['maintenance_enabled']),
      title: _readText(json['soft_title'], 'Update available'),
      message: _readText(
        json['soft_message'],
        'A newer version of PulseCall is available with improvements and fixes.',
      ),
      hardTitle: _readText(json['hard_title'], 'Update required'),
      hardMessage: _readText(
        json['hard_message'],
        'Please update PulseCall to continue using the app.',
      ),
      maintenanceTitle: _readText(
        json['maintenance_title'],
        'Service unavailable',
      ),
      maintenanceMessage: _readText(
        json['maintenance_message'],
        'PulseCall is temporarily unavailable. Please try again later.',
      ),
      storeUrl: json['store_url']?.toString() ?? '',
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '')?.toUtc(),
      endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? '')?.toUtc(),
    );
  }

  static String _readText(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}

enum AppControlMode { normal, softUpdate, hardUpdate, maintenance }

class AppControlState {
  const AppControlState({
    required this.mode,
    this.config,
    this.isLoading = false,
    this.error,
  });

  const AppControlState.normal()
    : mode = AppControlMode.normal,
      config = null,
      isLoading = false,
      error = null;

  final AppControlMode mode;
  final AppUpdateConfig? config;
  final bool isLoading;
  final String? error;

  AppControlState copyWith({
    AppControlMode? mode,
    AppUpdateConfig? config,
    bool? isLoading,
    String? error,
  }) {
    return AppControlState(
      mode: mode ?? this.mode,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  static const appId = 'pulsecall';
  static const platform = 'android';
  static const currentBuild = int.fromEnvironment(
    'PULSECALL_BUILD_NUMBER',
    defaultValue: 3,
  );
  static const currentVersion = String.fromEnvironment(
    'PULSECALL_VERSION_NAME',
    defaultValue: '1.0.3',
  );
  static const _definedUrl = String.fromEnvironment(
    'SPICARR_UPDATE_SYSTEM_URL',
  );
  static const _definedAnonKey = String.fromEnvironment(
    'SPICARR_UPDATE_SYSTEM_ANON_KEY',
  );

  final ValueNotifier<AppControlState> state = ValueNotifier<AppControlState>(
    const AppControlState.normal(),
  );

  DateTime? _lastFetchAt;
  Future<void>? _inFlight;

  Future<void> refresh({bool force = false}) {
    if (!force && _lastFetchAt != null) {
      final age = DateTime.now().difference(_lastFetchAt!);
      if (age.inSeconds < 20) return Future.value();
    }
    final running = _inFlight;
    if (running != null) return running;
    final future = _refreshInternal();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<void> _refreshInternal() async {
    final credentials = await _credentials();
    if (credentials == null) {
      state.value = const AppControlState.normal();
      debugPrint('PulseCall update system credentials are not configured.');
      return;
    }

    state.value = state.value.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse('${credentials.url}/rest/v1/app_update_configs')
          .replace(
            queryParameters: {
              'app_id': 'eq.$appId',
              'is_active': 'eq.true',
              'platform': 'in.($platform,all)',
              'order': 'priority.desc,updated_at.desc',
              'limit': '1',
            },
          );
      final request = await HttpClient()
          .getUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.headers.set('apikey', credentials.anonKey);
      request.headers.set('Authorization', 'Bearer ${credentials.anonKey}');
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      final body = await response.transform(utf8.decoder).join();

      _lastFetchAt = DateTime.now();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('PulseCall update fetch failed: ${response.statusCode}');
        state.value = const AppControlState.normal();
        return;
      }

      final decoded = jsonDecode(body);
      if (decoded is! List || decoded.isEmpty) {
        state.value = const AppControlState.normal();
        return;
      }

      final row = Map<String, dynamic>.from(decoded.first as Map);
      final config = AppUpdateConfig.fromJson(row);
      state.value = AppControlState(mode: _modeFor(config), config: config);
    } catch (error) {
      debugPrint('PulseCall update system unavailable: $error');
      state.value = const AppControlState.normal().copyWith(
        error: 'update_check_failed',
      );
    }
  }

  Future<_UpdateCredentials?> _credentials() async {
    final url = await _credentialValue(
      'spicarr_update_system_url',
      dartDefineValue: _definedUrl,
    );
    final anonKey = await _credentialValue(
      'spicarr_update_system_anonKey',
      dartDefineValue: _definedAnonKey,
      aliases: const ['spicarr_update_system_anon_key'],
    );
    if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
      return null;
    }
    return _UpdateCredentials(
      url: url.replaceAll(RegExp(r'/+$'), ''),
      anonKey: anonKey,
    );
  }

  Future<String?> _credentialValue(
    String key, {
    required String dartDefineValue,
    List<String> aliases = const [],
  }) async {
    final cleanedDefine = _cleanEnvValue(dartDefineValue);
    if (cleanedDefine != null && cleanedDefine.isNotEmpty) return cleanedDefine;

    final keys = {
      key,
      key.toLowerCase(),
      ...aliases,
      ...aliases.map((item) => item.toLowerCase()),
    };
    for (final asset in const [
      'assets/config/update_system.env',
      'assets/.env',
      '.env',
    ]) {
      try {
        final raw = await rootBundle.loadString(asset);
        for (final line in const LineSplitter().convert(raw)) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          final separatorIndex = trimmed.contains('=')
              ? trimmed.indexOf('=')
              : trimmed.indexOf(':');
          if (separatorIndex <= 0) continue;
          final lineKey = trimmed.substring(0, separatorIndex).trim();
          if (!keys.contains(lineKey) &&
              !keys.contains(lineKey.toLowerCase())) {
            continue;
          }
          return _cleanEnvValue(trimmed.substring(separatorIndex + 1));
        }
      } catch (_) {
        // Asset not bundled. Dart defines still work for release builds.
      }
    }
    return null;
  }

  String? _cleanEnvValue(String? value) {
    if (value == null) return null;
    var cleaned = value.trim();
    while (cleaned.endsWith(',')) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }
    if ((cleaned.startsWith("'") && cleaned.endsWith("'")) ||
        (cleaned.startsWith('"') && cleaned.endsWith('"'))) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned.trim();
  }

  AppControlMode _modeFor(AppUpdateConfig config) {
    final now = DateTime.now().toUtc();
    final started = config.startsAt == null || !now.isBefore(config.startsAt!);
    final notEnded = config.endsAt == null || now.isBefore(config.endsAt!);
    final inWindow = started && notEnded;

    if (config.maintenanceEnabled && inWindow) {
      return AppControlMode.maintenance;
    }
    if (config.hardUpdate ||
        (config.minBuild > 0 && currentBuild < config.minBuild)) {
      return AppControlMode.hardUpdate;
    }
    if (config.softUpdate &&
        (config.latestBuild <= 0 || currentBuild < config.latestBuild)) {
      return AppControlMode.softUpdate;
    }
    return AppControlMode.normal;
  }
}

class _UpdateCredentials {
  const _UpdateCredentials({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}
