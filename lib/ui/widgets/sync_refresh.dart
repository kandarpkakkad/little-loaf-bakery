import 'package:flutter/material.dart';

import '../../app/scope.dart';

/// Pull down to sync.
///
/// The lists underneath are already live — they are drift streams, so a row
/// that changes locally redraws itself without being asked. What the gesture
/// actually does is go and *fetch* what the other device wrote, which is the
/// thing no amount of local streaming can do.
///
/// It resolves when the sync run does, so the spinner is honest: it is still
/// turning while Drive is being read, and stops when there is nothing more
/// coming.
class SyncRefresh extends StatelessWidget {
  const SyncRefresh({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sync = context.app.sync;
    return RefreshIndicator(
      onRefresh: () async {
        final report = await sync.syncNow();
        if (!context.mounted || report.ok) return;
        // A failed pull is worth one line. A successful one says nothing: the
        // rows arriving *is* the feedback, and a snackbar after every pull
        // would be noise on the screen you pull most.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not reach Drive. It will try again on its own.',
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// A non-scrolling message that can still be pulled down.
///
/// `RefreshIndicator` only fires when its child actually scrolls, so an empty
/// list or a spinner kills the gesture — which is precisely the moment it is
/// wanted, because "no orders yet" is what you see while waiting for another
/// device's to arrive. This gives the message a viewport-height scrollable to
/// live in, so the pull works with nothing on screen.
class Pullable extends StatelessWidget {
  const Pullable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: child),
      ),
    ),
  );
}
