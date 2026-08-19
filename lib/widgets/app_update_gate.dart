import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulsecall/services/app_update_service.dart';
import 'package:pulsecall/theme/app_theme.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  bool _softDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppUpdateService.instance.refresh(force: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppUpdateService.instance.refresh(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppControlState>(
      valueListenable: AppUpdateService.instance.state,
      builder: (context, state, _) {
        final config = state.config;
        final mode = state.mode;
        final showSoft =
            mode == AppControlMode.softUpdate &&
            config != null &&
            !_softDismissed;
        final blocked =
            (mode == AppControlMode.hardUpdate ||
                mode == AppControlMode.maintenance) &&
            config != null;

        return Stack(
          children: [
            widget.child,
            if (showSoft)
              Positioned(
                left: 12,
                right: 12,
                top: MediaQuery.of(context).padding.top + 10,
                child: _SoftUpdateBanner(
                  config: config,
                  onDismiss: () => setState(() => _softDismissed = true),
                ),
              ),
            if (blocked)
              Positioned.fill(
                child: _BlockingUpdatePanel(config: config, mode: mode),
              ),
          ],
        );
      },
    );
  }
}

class _SoftUpdateBanner extends StatelessWidget {
  const _SoftUpdateBanner({required this.config, required this.onDismiss});

  final AppUpdateConfig config;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: pulse.surfaceStrong,
          borderRadius: BorderRadius.circular(PulseRadius.md),
          border: Border.all(color: pulse.line),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: pulse.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PulseRadius.sm),
              ),
              child: Icon(
                Icons.system_update_alt_rounded,
                color: pulse.cyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockingUpdatePanel extends StatelessWidget {
  const _BlockingUpdatePanel({required this.config, required this.mode});

  final AppUpdateConfig config;
  final AppControlMode mode;

  bool get _isMaintenance => mode == AppControlMode.maintenance;

  @override
  Widget build(BuildContext context) {
    final pulse = context.pulse;
    final title = _isMaintenance ? config.maintenanceTitle : config.hardTitle;
    final message = _isMaintenance
        ? config.maintenanceMessage
        : config.hardMessage;
    final color = _isMaintenance ? pulse.amber : pulse.cyan;
    final icon = _isMaintenance
        ? Icons.construction_rounded
        : Icons.system_update_rounded;

    return Material(
      color: const Color(0xFF03070B).withValues(alpha: 0.98),
      child: PulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: pulse.surfaceStrong,
                    borderRadius: BorderRadius.circular(PulseRadius.lg),
                    border: Border.all(color: pulse.line),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.13),
                          border: Border.all(
                            color: color.withValues(alpha: 0.36),
                          ),
                        ),
                        child: Icon(icon, color: color, size: 32),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (!_isMaintenance && config.storeUrl.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: config.storeUrl),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Update link copied.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy update link'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () =>
                            AppUpdateService.instance.refresh(force: true),
                        icon: const Icon(Icons.refresh_rounded, size: 17),
                        label: const Text('Check again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
