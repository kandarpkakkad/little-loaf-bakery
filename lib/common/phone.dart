/// Phone numbers, with room for more than one country but only one turned on.
///
/// The bakery sells in India, so [kIndia] is the whole of [kSupportedCountries]
/// today. The shape is here so adding a second country is a matter of adding a
/// [PhoneCountry] and letting the form offer a choice — not of unpicking an
/// assumption baked through the codebase.
///
/// Numbers are **stored** canonically as `+919876543210`: one form, no spaces.
/// That is what wa.me needs and what the unique index compares, so the same
/// person cannot be saved twice by typing the spaces differently. They are
/// **shown** grouped the way the country writes them.
class PhoneCountry {
  const PhoneCountry({
    required this.name,
    required this.code,
    required this.nationalLength,
    required this.startsWith,
    required this.groups,
  });

  final String name;

  /// Dialling code including the plus, e.g. `+91`.
  final String code;

  final int nationalLength;

  /// Leading digits a mobile may start with. Landlines are excluded on purpose:
  /// these numbers are used for WhatsApp, which landlines cannot receive.
  final String startsWith;

  /// How the national part is broken up for display, e.g. `[5, 5]` → 98765 43210.
  final List<int> groups;
}

const kIndia = PhoneCountry(
  name: 'India',
  code: '+91',
  nationalLength: 10,
  startsWith: '6789',
  groups: [5, 5],
);

/// Every country the app will accept a number from. One, for now.
const kSupportedCountries = <PhoneCountry>[kIndia];

/// The one used when nothing else is known.
const kDefaultCountry = kIndia;

class Phone {
  const Phone(this.national, {this.country = kDefaultCountry});

  /// The national part only — digits, no code, no spaces.
  final String national;
  final PhoneCountry country;

  /// Reads a stored value back, whatever shape it is in.
  ///
  /// Tolerant by design: older rows may hold spaces, a missing code or a
  /// leading zero, and being strict here would hide an existing customer rather
  /// than fix their number.
  factory Phone.parse(String stored) {
    var d = digitsOf(stored);
    for (final c in kSupportedCountries) {
      final dial = c.code.substring(1);
      if (d.startsWith(dial) && d.length > c.nationalLength) {
        return Phone(d.substring(dial.length), country: c);
      }
    }
    if (d.startsWith('0') && d.length > kDefaultCountry.nationalLength) {
      d = d.substring(1);
    }
    if (d.length > kDefaultCountry.nationalLength) {
      d = d.substring(d.length - kDefaultCountry.nationalLength);
    }
    return Phone(d);
  }

  String get code => country.code;

  /// What goes in `phone_e164` and in a wa.me link.
  String get e164 => '$code$national';

  /// Grouped the way the country writes it — `+91 98765 43210`.
  String get pretty {
    if (national.length != country.nationalLength) return '$code $national';
    final parts = <String>[];
    var i = 0;
    for (final g in country.groups) {
      parts.add(national.substring(i, i + g));
      i += g;
    }
    return '$code ${parts.join(' ')}';
  }

  bool get isValid => problem == null;

  /// Why it is not valid, in words the person typing it can act on.
  String? get problem {
    if (national.isEmpty) return 'Required';
    if (national.length < country.nationalLength) {
      return 'Needs ${country.nationalLength} digits';
    }
    if (national.length > country.nationalLength) {
      return 'Too long — ${country.nationalLength} digits';
    }
    if (!country.startsWith.contains(national[0])) {
      final d = country.startsWith.split('');
      return 'Mobile numbers start with ${d.sublist(0, d.length - 1).join(', ')} '
          'or ${d.last}';
    }
    return null;
  }

  static String digitsOf(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  bool operator ==(Object other) => other is Phone && other.e164 == e164;

  @override
  int get hashCode => e164.hashCode;

  @override
  String toString() => e164;
}
