import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../platform/backup/restore.dart';
import '../../../platform/backup/snapshot.dart';
import '../../../platform/sync/sync_engine.dart';
import '../../../platform/sync/sync_service.dart';
import '../../../platform/versioning/version.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';

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
      content: Text(switch (report) {
        final r when !r.ok => 'Sync failed. It will try again on its own.',
        // The state that used to read as success while nothing arrived.
        final r when r.isolated =>
          'Synced, but no other device was found in this Drive folder.',
        final r when r.hadPeerTrouble =>
          'Synced — ${r.uploaded} sent, ${r.applied} received. '
              '${r.peerErrors.length} device(s) could not be read.',
        final r => 'Synced — ${r.uploaded} sent, ${r.applied} received',
      }),
    ));
  }

  Future<void> _backUpNow() async {
    final result = await _sync.backUpNow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result.outcome) {
        SnapshotOutcome.uploaded => 'Backed up to Drive.',
        SnapshotOutcome.notOwner =>
          'Another device takes the backups, so this one did not.',
        SnapshotOutcome.failed => 'Backup failed: ${result.error}',
      }),
    ));
  }

  Future<void> _restore() async {
    final choices = await _sync.restoreChoices();
    if (!mounted) return;

    if (choices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no backups in Drive yet.')),
      );
      return;
    }

    final picked = await showModalBottomSheet<SnapshotChoice>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.lg, Space.lg, Space.sm),
              child: Text('Restore from a backup',
                  style: context.text.titleMedium),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in choices)
                    ListTile(
                      title: Text(_when(c.takenOn.millisecondsSinceEpoch)),
                      subtitle: c == choices.first
                          ? const Micro('Most recent')
                          : null,
                      onTap: () => Navigator.pop(sheet, c),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;

    final sure = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: Text(
          'Everything on this device is replaced with the backup from '
          '${_when(picked.takenOn.millisecondsSinceEpoch)}, and anything '
          'since then that has not reached Drive is lost.\n\n'
          'The backup is downloaded now and put in place the next time the '
          'app starts.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Restore')),
        ],
      ),
    );
    if (sure != true || !mounted) return;

    try {
      await _sync.stageRestore(picked.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Downloaded. Close and reopen the app to finish.'),
        duration: Duration(seconds: 6),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
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

                if (s.connected) ...[
                  const SizedBox(height: Space.xl),
                  _BackupSection(
                    status: s,
                    deviceId: context.app.deviceId,
                    onBackUp: _backUpNow,
                    onRestore: _restore,
                  ),
                ],

                const SizedBox(height: Space.xl),
                if (s.lastReport != null) _PeerFacts(report: s.lastReport!),
                StreamBuilder<int>(
                  stream: context.app.mutations.watchPending(),
                  builder: (context, snap) => _Fact(
                    'Waiting to upload',
                    '${snap.data ?? 0} change${(snap.data ?? 0) == 1 ? '' : 's'}',
                  ),
                ),
                _Fact('This device', context.app.deviceId),
                _Fact('Version', '$kAppVersion ($kAppBuild)'),

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

/// The other half of the backup: journals hold the recent tail, a snapshot
/// holds everything before it.
///
/// One device takes them and the rest skip, which is why this says *which*
/// device — if that phone is gone, the fix is to delete `snapshot/owner.json`
/// in Drive, and nothing on this screen can do it for you.
class _BackupSection extends StatelessWidget {
  const _BackupSection({
    required this.status,
    required this.deviceId,
    required this.onBackUp,
    required this.onRestore,
  });

  final SyncStatus status;
  final String deviceId;
  final VoidCallback onBackUp;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final owner = status.owner;
    final ours = owner?.deviceId == deviceId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Backup'),
        LoafCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Fact(
                'Last backup',
                owner?.lastSnapshotAt == null
                    ? 'never'
                    : _when(owner!.lastSnapshotAt!),
              ),
              _Fact(
                'Taken by',
                owner == null
                    ? 'nobody yet'
                    : ours
                        ? 'this device'
                        : '${owner.deviceId.substring(0, 8)}…',
              ),
              if (status.backupStale)
                Padding(
                  padding: const EdgeInsets.only(top: Space.sm),
                  child: Text(
                    owner == null
                        ? 'No device has taken a backup yet. Tap "Back up now" '
                            'and this one will take them from then on.'
                        : 'No backup since '
                            '${_when(owner.lastSnapshotAt ?? owner.claimedAt)}. '
                            '${ours ? 'This device' : '${owner.deviceId.substring(0, 8)}…'} '
                            'is the backup device. If that phone is gone, '
                            'delete snapshot/owner.json in the Little Loaf '
                            'Bakery folder in Drive, and the next device to '
                            'try will take over.',
                    style: context.text.bodySmall!.copyWith(color: c.warn),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: status.busy ? null : onBackUp,
                icon: const Icon(Icons.backup_outlined, size: 18),
                label: const Text('Back up now'),
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: status.busy ? null : onRestore,
                icon: const Icon(Icons.settings_backup_restore, size: 18),
                label: const Text('Restore'),
              ),
            ),
          ],
        ),
      ],
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

/// What the last run actually saw. Exists because "0 received" answers none of
/// the questions you have when another device's orders are not arriving.
class _PeerFacts extends StatelessWidget {
  const _PeerFacts({required this.report});

  final SyncReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Fact('Other devices found', '${report.peersSeen}'),
        if (report.peersSeen > 0)
          _Fact('Read successfully', '${report.peersRead}'),
        if (report.isolated)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              'This device sees its own folder and nobody else\'s. If another '
              'device is syncing, the two are not looking at the same place. '
              'Check both are signed in to the same Google account — and that '
              'both run the same build: a debug build and a release build are '
              "different apps to Google Drive and cannot see each other's files.",
              style: context.text.bodySmall!.copyWith(color: c.warn),
            ),
          ),
        for (final e in report.peerErrors.entries)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              'Could not read ${e.key.substring(0, 8)}…: ${e.value}',
              style: context.text.bodySmall!.copyWith(color: c.warn),
            ),
          ),
      ],
    );
  }
}

/// A backup date carries a year, unlike every other date in the app: these go
/// back two weeks and the list is read months after it was written.
String _when(int ms) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
