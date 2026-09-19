import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../platform/security/app_lock.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Covers the app until the device says who is holding it.
///
/// A cover rather than a route: the shell underneath stays alive, so unlocking
/// returns to exactly the screen and the half-typed order that was there
/// before. It sits above the navigator, so a sheet or a dialog cannot be left
/// visible behind it.
/// docs/01-platform/security/lld.md §2
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  AppLock get _lock => context.app.lock;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _lock.start().then((_) {
      if (_lock.locked && mounted) _lock.unlock();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _lock.onPaused();
      case AppLifecycleState.resumed:
        _lock.onResumed();
        if (_lock.locked && !_lock.asking) _lock.unlock();
      case _:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _lock,
        builder: (context, child) => Stack(
          children: [
            child!,
            if (_lock.locked)
              // Opaque, and on top of everything: the task switcher preview
              // and anything mid-flow underneath are both covered.
              Positioned.fill(child: _LockScreen(onUnlock: _lock.unlock)),
          ],
        ),
        child: widget.child,
      );
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final Future<bool> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.paper,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: c.ink3),
              const SizedBox(height: Space.lg),
              Text('Little Loaf is locked', style: context.text.titleMedium),
              const SizedBox(height: Space.sm),
              Text(
                'Unlock with the same PIN or fingerprint as the phone.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall!.copyWith(color: c.ink3),
              ),
              const SizedBox(height: Space.xl),
              FilledButton.icon(
                onPressed: () => onUnlock(),
                icon: const Icon(Icons.lock_open_outlined, size: 18),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
