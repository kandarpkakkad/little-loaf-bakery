import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../platform/sync/sync_service.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';

/// Connect Drive, see what is waiting, sync by hand.
///
/// Sync is otherwise invisible — that is the point of it — so this screen
/// exists for the two moments it is not: setting it up, and working out why it
/// has stopped.
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  SyncService get _sync => context.app.sync;

  Future<void> _connect() async {
    final ok = await _sync.connect();
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not connect to Google Drive')),
    );
  }

  Future<void> _syncNow() async {
    final report = await _sync.syncNow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(report.ok
          ? 'Synced — ${report.uploaded} sent, ${report.applied} received'
          : 'Sync failed. It will try again on its own.'),
    ));
  }

  Future<void> _disconnect() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Disconnect Drive?'),
        content: const Text(
          'Orders stay on this device and the files stay in your Drive. '
          'Nothing is deleted — this device just stops syncing.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Disconnect')),
        ],
      ),
    );
    if (sure == true) await _sync.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(title: const Text('Google Drive sync')),
      body: ContentWidth(
        max: 720,
        child: ListenableBuilder(
          listenable: _sync,
          builder: (context, _) {
            final s = _sync.status;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xxl),
              children: [
                _StatusCard(status: s),
                const SizedBox(height: Space.lg),

                if (!s.connected)
                  FilledButton.icon(
                    onPressed: s.busy ? null : _connect,
                    icon: const Icon(Icons.cloud_outlined, size: 18),
                    label: const Text('Connect Google Drive'),
                  )
                else ...[
                  if (s.blocker == SyncBlocker.needsReconnect)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.md),
                      child: FilledButton.icon(
                        onPressed: s.busy ? null : _connect,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reconnect'),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: s.busy ? null : _syncNow,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sync now'),
                  ),
                  const SizedBox(height: Space.sm),
                  TextButton(
                    onPressed: s.busy ? null : _disconnect,
                    child: const Text('Disconnect'),
                  ),
                ],

                const SizedBox(height: Space.xl),
                StreamBuilder<int>(
                  stream: context.app.mutations.watchPending(),
                  builder: (context, snap) => _Fact(
                    'Waiting to upload',
                    '${snap.data ?? 0} change${(snap.data ?? 0) == 1 ? '' : 's'}',
                  ),
                ),
                _Fact('This device', context.app.deviceId),

                const SizedBox(height: Space.xl),
                Text(
                  'Sync runs by itself in the background. Everything works '
                  'offline; changes queue up and go out when there is a '
                  'connection.\n\n'
                  'Files live in a "Little Loaf Bakery" folder the app creates '
                  'in your Drive. It cannot see anything else in your account.',
                  style: context.text.bodySmall!.copyWith(color: c.ink3),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (icon, title, detail, colour) = switch (status) {
      final s when s.busy => (Icons.sync, 'Syncing…', null, c.accent2),
      final s when s.blocker == SyncBlocker.needsReconnect => (
          Icons.error_outline,
          'Reconnect needed',
          'Google has ended this device\'s permission. Nothing is lost — '
              'reconnect and the queued changes go out.',
          c.warn,
        ),
      final s when !s.connected => (
          Icons.cloud_off_outlined,
          'Not connected',
          'This device keeps everything locally. Connect Drive to share with '
              'your other device and to have a backup.',
          c.ink3,
        ),
      final s when s.lastReport?.ok == false => (
          Icons.cloud_off_outlined,
          'Last sync failed',
          'It will try again on its own.',
          c.warn,
        ),
      _ => (Icons.cloud_done_outlined, 'Connected', null, c.accent2),
    };

    return LoafCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colour),
              const SizedBox(width: Space.sm),
              Text(title, style: context.text.titleMedium),
            ],
          ),
          if (status.email != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(status.email!,
                  style: context.text.bodySmall!.copyWith(color: c.ink2)),
            ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Text(detail,
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
            ),
          if (status.lastSyncAt != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Text('Last synced ${_ago(status.lastSyncAt!)}',
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
            ),
        ],
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.text.bodyMedium),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.ink3)),
            ),
          ],
        ),
      );
}
