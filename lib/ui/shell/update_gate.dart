import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/scope.dart';
import '../../platform/versioning/version.dart';
import '../../platform/versioning/version_gate.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Stops a build that is too old, and mentions one that is merely behind.
///
/// Two different things on purpose. A version too old to read what the other
/// device writes has to stop; a version that is one release behind is worth a
/// line someone can dismiss. Anything in between — Drive down, no signal, a
/// malformed file — is treated as no answer, and no answer never blocks.
/// docs/01-platform/versioning/hld.md
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  GateResult _result = const GateResult(GateVerdict.ok);
  bool _started = false;
  bool _bannerShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _check();
  }

  Future<void> _check() async {
    final result = await context.app.updates.check();
    if (!mounted) return;
    setState(() => _result = result);
    if (result.verdict == GateVerdict.updateAvailable && !_bannerShown) {
      _bannerShown = true;
      _showBanner(result.info!);
    }
  }

  /// Once per launch, and dismissible. An update that is not urgent should not
  /// be asked about twice.
  void _showBanner(ReleaseInfo info) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showMaterialBanner(MaterialBanner(
      content: Text('Version ${_plain(info.latest)} is out. '
          'This device is on $kAppVersion.'),
      leading: const Icon(Icons.system_update_outlined),
      actions: [
        TextButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            _open(info.apkUrl ?? kReleasesPage);
          },
          child: const Text('Get it'),
        ),
      ],
    ));
  }

  Future<void> _open(String url) => launchUrl(
        Uri.parse(url),
        // The browser, not a webview: the download has to land in Downloads
        // where the installer can find it, and the phone's browser is the one
        // signed in to the bakery account.
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          if (_result.blocks)
            Positioned.fill(
              child: _BlockScreen(info: _result.info!, onGet: _open),
            ),
        ],
      );
}

class _BlockScreen extends StatelessWidget {
  const _BlockScreen({required this.info, required this.onGet});

  final ReleaseInfo info;
  final Future<void> Function(String) onGet;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.paper,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.system_update, size: 40, color: c.warn),
                const SizedBox(height: Space.lg),
                Text('Update to carry on',
                    style: context.text.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: Space.sm),
                Text(
                  'This device is on $kAppVersion, and the bakery has moved to '
                  '${_plain(info.latest)}. An older build can no longer read '
                  'what the others write, so it stops here rather than showing '
                  'you a half-picture.\n\n'
                  'Everything on this device has already been sent to Drive.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium!.copyWith(color: c.ink2),
                ),
                const SizedBox(height: Space.xl),
                // Always present, whatever the config said. A build that sets
                // the floor too high would otherwise strand every device with
                // no way forward.
                FilledButton.icon(
                  onPressed: () => onGet(info.apkUrl ?? kReleasesPage),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Download the update'),
                ),
                const SizedBox(height: Space.sm),
                Text(
                  'Install it over this one — your orders stay where they are.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall!.copyWith(color: c.ink3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tags are written `v0.1.2`; people say 0.1.2.
String _plain(String version) => version.replaceFirst(RegExp('^[vV]'), '');
