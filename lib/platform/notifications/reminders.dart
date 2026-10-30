import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/orders/model.dart';
import '../../domain/menu/repository.dart';
import '../storage/database.dart';
import '../../domain/orders/repository.dart';
import '../../domain/stock/model.dart';
import '../../domain/stock/repository.dart';
import '../../domain/reminders/model.dart';

/// Raises the journey reminders the domain decides on.
///
/// **No push server, and none needed.** Every reminder is a moment the device
/// can already work out from the order in its own database, so it is scheduled
/// locally and survives the app being closed.
///
/// Both phones will raise the same reminder, because both hold the same
/// orders. That is the same trade the stock alerts were designed around: with
/// no server there is nobody to decide whose phone should ring, and for a
/// delivery both owners want to know anyway.
class ReminderService {
  ReminderService({FlutterLocalNotificationsPlugin? plugin, this.onOpen})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Where a tapped notification should take somebody, called with the
  /// reminder's payload. A callback rather than a direct jump, so this layer
  /// never reaches into the UI.
  final void Function(String payload)? onOpen;

  static const _channelId = 'journeys';
  static const _channelName = 'Deliveries and pickups';
  static const _channelDescription =
      'Reminders before a handover, and a nudge when one is overdue.';

  bool _ready = false;
  StreamSubscription<List<OrderView>>? _watchingOrders;
  StreamSubscription<List<StockLevel>>? _watchingStock;
  StreamSubscription<List<MenuItem>>? _watchingMenu;
  Timer? _debounce;

  // The last seen value of each side, so a change to either can rebuild the
  // whole schedule without re-reading the other.
  List<OrderView> _orders = const [];
  List<String> _low = const [];
  Map<String, int> _leads = const {};

  /// Sets up the plugin and asks for permission. Safe to call more than once.
  ///
  /// Failure is quiet on purpose: a phone that refuses notifications is still
  /// a working till, and an exception here would take the app down at launch.
  ///
  /// [interactive] is false from the background sync, which has no activity:
  /// asking for permission there throws, which would leave the service
  /// unready and the schedule unwritten, and there is no launch tap to read.
  Future<void> init({bool interactive = true}) async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p != null) onOpen?.call(p);
        },
      );

      // The app may have been *launched* by the tap, in which case the
      // callback above has already been and gone before anything was
      // listening.
      if (interactive) {
        final launch = await _plugin.getNotificationAppLaunchDetails();
        final p = launch?.notificationResponse?.payload;
        if (launch?.didNotificationLaunchApp == true && p != null) {
          onOpen?.call(p);
        }
      }

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ));
      // Android 13+. Declining is a normal answer and changes nothing else.
      if (interactive) await android?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Keeps the reminders in step with the orders, for as long as the app runs.
  ///
  /// Watching the order stream covers **every** way a journey can change:
  /// somebody edits it here, or a peer's edit arrives over sync and lands in
  /// the same database. One hook, no chance of missing a path.
  void follow(
      OrderRepository orders, StockRepository stock, MenuRepository menu) {
    _watchingOrders?.cancel();
    _watchingStock?.cancel();
    _watchingMenu?.cancel();

    _watchingOrders = orders.watchOrders().listen((views) {
      _orders = views;
      _rebuildSoon();
    });

    // Notice needed decides which morning a thing has to be started on, so
    // editing a menu item's lead time moves a reminder.
    _watchingMenu = menu.watchAll().listen((items) {
      _leads = _leadsOf(items);
      _rebuildSoon();
    });

    // Stock moves the morning line, so it has to rebuild the schedule too —
    // butter that ran out at four o'clock should be on tomorrow's list.
    _watchingStock = stock.watchLevels().listen((levels) {
      _low = _lowOf(levels);
      _rebuildSoon();
    });
  }

  /// One rebuild from the database as it stands, for a caller with no app
  /// running to [follow] — the background sync, after it has applied a
  /// peer's ops. Drift's streams do not cross isolates, so without this an
  /// order the other phone took at seven is missing from tonight's prep
  /// reminder until somebody opens the app here.
  Future<void> rebuildFrom(
      OrderRepository orders, StockRepository stock, MenuRepository menu) async {
    _leads = _leadsOf(await menu.watchAll().first);
    _low = _lowOf(await stock.watchLevels().first);
    await refresh(await orders.watchOrders().first);
  }

  // Shared by [follow] and [rebuildFrom], so the two cannot read the menu or
  // the stock differently.
  static Map<String, int> _leadsOf(List<MenuItem> items) =>
      {for (final m in items) m.id: m.leadDays};

  static List<String> _lowOf(List<StockLevel> levels) => [
        for (final l in levels)
          if (l.material.active && l.state == StockState.below) l.material.name,
      ];

  /// A burst of writes — confirming an order touches every item — should
  /// rebuild the schedule once, not once per row. Both streams share the
  /// timer, so an order edit and a stock movement together still cost one.
  void _rebuildSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => refresh(_orders));
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _watchingOrders?.cancel();
    await _watchingStock?.cancel();
    await _watchingMenu?.cancel();
  }

  /// Rebuilds the whole schedule: cancel everything, then lay it out again.
  ///
  /// Wholesale rather than incremental because the alternative is tracking
  /// which notification id belongs to which journey across edits, reschedules
  /// and syncs — and a stale reminder for a cake already delivered is exactly
  /// the thing that makes people turn notifications off.
  Future<void> refresh(List<OrderView> views) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();

      var id = 0;
      final journeys = <SubOrder>[];
      final perJourney = <Reminder>[];
      for (final v in views) {
        if (v.isCancelled) continue;
        final who = v.customer.name.split(' ').first;
        for (final j in v.subOrders) {
          journeys.add(j);
          perJourney.addAll(remindersFor(j,
              customerFirstName: who, orderNo: v.order.orderNo));
          // A day out, so tomorrow's bake can start today — or half an hour
          // after confirming, when there was never a day to give.
          perJourney.addAll(prepRemindersFor(j,
              customerFirstName: who,
              orderNo: v.order.orderNo,
              confirmedAt: v.order.confirmedAt));
        }
      }

      // Collected first, then merged: two cakes leaving at four produced two
      // identical buzzes at half past three. Merging is per slot, so a prep
      // reminder never swallows a half-hour warning on the same minute.
      for (final r in batched(perJourney)) {
        await _schedule(id++, r);
      }

      // Handed over and still unpaid, every twelve hours until it is
      // settled. Anchored to the handover rather than to now, so it keeps
      // landing at the same two times of day instead of drifting forward
      // each time this runs.
      for (final r in batched(paymentReminders(
        [
          for (final v in views)
            if (v.status == OrderStatus.paymentPending)
              (
                orderId: v.order.id,
                orderNo: v.order.orderNo,
                who: v.customer.name.split(' ').first,
                handedOverAt: v.handedOverAt,
                owes: true,
                amount: '₹${v.totals.balanceDue.paise ~/ 100}',
              ),
        ],
        now: DateTime.now(),
      ))) {
        await _schedule(id++, r);
      }

      // One per morning that has work on it, across every order — plus what
      // needs buying, on the next morning only.
      for (final r in morningDigests(journeys,
          leadDays: _leads, lowStock: _low)) {
        await _schedule(id++, r);
      }
    } catch (_) {
      // A schedule that could not be written is not worth crashing over.
    }
  }

  Future<void> _schedule(int id, Reminder r) => _plugin.zonedSchedule(
        id: id,
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: r.subOrderId,
      );
}
