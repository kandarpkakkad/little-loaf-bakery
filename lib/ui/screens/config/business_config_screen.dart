import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../platform/storage/database.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';

/// The handful of facts that end up on every invoice and message.
class BusinessConfigScreen extends StatefulWidget {
  const BusinessConfigScreen({super.key});

  @override
  State<BusinessConfigScreen> createState() => _BusinessConfigScreenState();
}

class _BusinessConfigScreenState extends State<BusinessConfigScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _upi = TextEditingController();
  final _terms = TextEditingController();
  final _local = TextEditingController();
  final _outstation = TextEditingController();
  final _deviceName = TextEditingController();
  bool _loaded = false;

  // See the note in new_order_screen.dart: AppScope is a dependency, so the
  // earliest legal point to read it is didChangeDependencies.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _load();
  }

  Future<void> _load() async {
    final s = await context.app.settings();
    if (!mounted) return;
    setState(() {
      _name.text = s.businessName;
      _phone.text = s.phone ?? '';
      _address.text = s.address ?? '';
      _upi.text = s.upiId ?? '';
      _terms.text = s.termsLine ?? '';
      _local.text = moneyToField(Money(s.deliveryChargeLocal));
      _outstation.text = moneyToField(Money(s.deliveryChargeOutstation));
      _deviceName.text = s.deviceName ?? '';
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final db = context.db;
    await db.update(db.settings).write(SettingsCompanion(
          businessName: Value(_name.text.trim()),
          phone: Value(_phone.text.trim().isEmpty ? null : _phone.text.trim()),
          address: Value(_address.text.trim().isEmpty ? null : _address.text.trim()),
          upiId: Value(_upi.text.trim().isEmpty ? null : _upi.text.trim()),
          termsLine: Value(_terms.text.trim().isEmpty ? null : _terms.text.trim()),
          deliveryChargeLocal: Value(moneyFromField(_local.text).paise),
          deliveryChargeOutstation: Value(moneyFromField(_outstation.text).paise),
          deviceName:
              Value(_deviceName.text.trim().isEmpty ? null : _deviceName.text.trim()),
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  void dispose() {
    for (final c in [
      _name, _phone, _address, _upi, _terms, _local, _outstation, _deviceName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.paper,
        appBar: AppBar(
          title: const Text('Business'),
          actions: [TextButton(onPressed: _save, child: const Text('Save'))],
        ),
        body: ContentWidth(
          max: 720,
          child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.sm, Space.lg, Space.xxl),
                children: [
                  const SectionLabel('Identity'),
                  LoafCard(
                    child: Column(
                      children: [
                        LoafField(label: 'Business name', controller: _name, required: true),
                        LoafField(
                            label: 'Phone',
                            controller: _phone,
                            keyboardType: TextInputType.phone),
                        LoafField(label: 'Address', controller: _address, maxLines: 3),
                      ],
                    ),
                  ),
                  const SectionLabel('Payments'),
                  LoafCard(
                    child: Column(
                      children: [
                        LoafField(
                            label: 'UPI ID',
                            controller: _upi,
                            hint: 'name@bank — used for the QR on the invoice'),
                        LoafField(
                            label: 'Invoice footer line',
                            controller: _terms,
                            maxLines: 2),
                      ],
                    ),
                  ),
                  const SectionLabel('Default delivery charge'),
                  LoafCard(
                    child: Column(
                      children: [
                        LoafField(
                            label: 'Inside city',
                            controller: _local,
                            prefix: '₹ ',
                            keyboardType: TextInputType.number,
                            inputFormatters: rupeeInput),
                        LoafField(
                            label: 'Out of city',
                            controller: _outstation,
                            prefix: '₹ ',
                            keyboardType: TextInputType.number,
                            inputFormatters: rupeeInput),
                        Text(
                          'A default, not a rule — the charge can be changed on any '
                          'order right up to delivery.',
                          style: context.text.bodySmall!
                              .copyWith(color: context.colors.ink3),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('This device'),
                  LoafCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoafField(
                            label: 'Device name',
                            controller: _deviceName,
                            hint: 'Kitchen phone, Counter tablet…'),
                        Text('ID  ${context.app.deviceId}',
                            style: context.text.bodySmall!
                                .copyWith(color: context.colors.ink3)),
                      ],
                    ),
                  ),
                ],
              ),
        ),
      );
}
