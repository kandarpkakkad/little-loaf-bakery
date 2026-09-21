import 'package:flutter/foundation.dart';

/// Which tab the shell should be showing.
///
/// A notification tap happens outside the widget tree — there is no
/// `BuildContext` to navigate with, and the app may not even be running yet.
/// So the destination is left here and the shell picks it up, whether it is
/// already listening or mounts a moment later.
///
/// Deliberately not a router. `go_router` is in the dependency list and used
/// by nothing; adding a route table for one destination would be a large
/// change to the shell for a single arrow.
final ValueNotifier<int> requestedTab = ValueNotifier<int>(kOrdersTab);

const int kOrdersTab = 0;
const int kKitchenTab = 1;
const int kStockTab = 2;
const int kMoreTab = 3;
