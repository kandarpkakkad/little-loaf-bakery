import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';

import '../support/harness.dart';

/// A device that syncs nothing must not look like a device that is up to date.
///
/// Both used to report "Synced — 0 sent, 0 received": every per-peer failure
/// was caught and dropped, and the report had nowhere to put it.
void main() {
  late InMemoryRemoteStore store;
  late SyncDevice alice;

  setUp(() async {
    store = InMemoryRemoteStore();
    alice = await SyncDevice.make('alice', store);
  });

  tearDown(() => alice.close());

  test('a device that can see nobody says so', () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    final r = await alice.engine.sync();

    expect(r.ok, isTrue);
    expect(r.peersSeen, 0);
    expect(r.isolated, isTrue,
        reason: 'no peer folders at all — the signature of the wrong Google '
            'account or a different OAuth client, not of being up to date');
  });

  test('an unreadable peer is reported, not swallowed', () async {
    store.journals['bob'] = 'this is not a journal';
    final r = await alice.engine.sync();

    expect(r.peersSeen, 1, reason: 'bob was found');
    expect(r.hadPeerTrouble || r.peersRead == 0, isTrue,
        reason: 'and his unreadability reached the report');
  });

  test('one broken peer does not stop a good one', () async {
    final bob = await SyncDevice.make('bob', store);
    await bob.services.customers
        .findOrCreate(name: 'Bina', phoneE164: '+912222222222');
    await bob.engine.sync();

    store.journals['carol'] = 'broken';

    final r = await alice.engine.sync();
    expect(r.applied, greaterThan(0), reason: "bob's ops still came through");
    expect(r.peersSeen, 2);
    await bob.close();
  });

  test('seeing a peer and reading it are counted separately', () async {
    final bob = await SyncDevice.make('bob', store);
    await bob.services.customers
        .findOrCreate(name: 'Bina', phoneE164: '+912222222222');
    await bob.engine.sync();

    final r = await alice.engine.sync();
    expect(r.peersSeen, 1);
    expect(r.peersRead, 1);
    expect(r.isolated, isFalse);
    await bob.close();
  });
}
