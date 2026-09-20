import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/orders/repository.dart';
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
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'journeys';
  static const _channelName = 'Deliveries and pickups';
  static const _channelDescription =
      'Reminders before a handover, and a nudge when one is overdue.';

  bool _ready = false;
  StreamSubscription<List<OrderView>>? _watching;
  Timer? _debounce;

  /// Sets up the plugin and asks for permission. Safe to call more than once.
  ///
  /// Failure is quiet on purpose: a phone that refuses notifications is still
  /// a working till, and an exception here would take the app down at launch.
  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ));
      // Android 13+. Declining is a normal answer and changes nothing else.
      await android?.requestNotificationsPermission();
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
  void follow(OrderRepository orders) {
    _watching?.cancel();
    _watching = orders.watchOrders().listen((views) {
      // A burst of writes — confirming an order touches every item — should
      // rebuild the schedule once, not once per row.
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), () => refresh(views));
    });
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _watching?.cancel();
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
      for (final v in views) {
        if (v.isCancelled) continue;
        final who = v.customer.name.split(' ').first;
        for (final j in v.subOrders) {
          for (final r in remindersFor(j,
              customerFirstName: who, orderNo: v.order.orderNo)) {
            await _schedule(id++, r);
          }
        }
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
