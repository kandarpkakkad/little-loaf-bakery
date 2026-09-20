import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google sign-in, and the access token Drive calls need.
///
/// Only `drive.file` is requested: the app can touch files it created and
/// nothing else in the account. That is what keeps this scope non-sensitive,
/// so the OAuth client never needs Google's verification review — and it is
/// also the honest permission, since sync only ever reads its own journals.
class DriveAuth {
  DriveAuth({
    this.serverClientId = kServerClientId,
    this.storage = const FlutterSecureStorage(),
  });

  /// Where the fact that a Google account is connected is remembered.
  ///
  /// The plugin's silent paths return null whenever they would need
  /// interaction, which happens routinely — so asking Google "is anyone signed
  /// in?" is not a reliable way to know, and doing it on every launch and every
  /// screen open is what produced a stream of account prompts. This is the
  /// app's own record instead: written when the user connects, cleared only
  /// when they disconnect.
  final FlutterSecureStorage storage;
  static const _offeredKey = 'little_loaf_drive_offered';
  static const _emailKey = 'llb_drive_email';

  /// The **web** OAuth client id, not an Android one. Android's Credential
  /// Manager flow uses it as the audience of the identity token; the Android
  /// clients are matched by package name and signing certificate instead, which
  /// is why neither of those ids appears anywhere in this code.
  ///
  /// Not a secret — it ships inside the APK either way.
  static const kServerClientId =
      '378885183225-o771n1qe4jup99inht13af8qbsv24g64.apps.googleusercontent.com';

  static const scopes = <String>['https://www.googleapis.com/auth/drive.file'];

  final String serverClientId;

  bool _initialized = false;

  /// The last token this device was given, and when it stops being any use.
  ///
  /// Held because asking for one is not free: on Android the lightweight path
  /// goes through Credential Manager, which puts a "Signing you in" sheet over
  /// whatever the person is doing. Sync runs on open, on every resume and on a
  /// five-minute timer, so asking each time meant that sheet appearing over an
  /// order being typed.
  String? _cached;
  DateTime? _expiresAt;

  /// One authorisation attempt at a time. Two callers arriving together — a
  /// resume and the timer, say — used to raise two sheets.
  Future<String?>? _inFlight;

  /// A minute of slack, so a token is never handed out moments before it dies.
  static const _slack = Duration(minutes: 1);

  /// Google does not tell us the expiry, so assume the documented hour and
  /// take the conservative end of it.
  static const _assumedLife = Duration(minutes: 55);

  bool get _cacheIsGood =>
      _cached != null &&
      _expiresAt != null &&
      DateTime.now().isBefore(_expiresAt!.subtract(_slack));

  /// Drops the cached token. Called when Drive rejects it, so the next run
  /// asks for a fresh one rather than retrying a dead one forever.
  void forgetToken() {
    _cached = null;
    _expiresAt = null;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    _initialized = true;
  }

  /// A token without showing any UI. Returns null when the grant has gone —
  /// revoked, expired, or simply needing interaction again — which means "ask
  /// the user", not "fail", and never means "prompt them right now".
  ///
  /// Returns null immediately when nobody has connected, so a device that has
  /// never used Drive makes no Google calls at all.
  Future<String?> silentToken() async {
    if (_cacheIsGood) return _cached;
    if (await rememberedEmail() == null) return null;

    // Share one attempt rather than each caller starting its own.
    return _inFlight ??= _authorise().whenComplete(() => _inFlight = null);
  }

  Future<String?> _authorise() async {
    await _ensureInitialized();
    final user = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (user == null) return null;
    final auth = await user.authorizationClient.authorizationForScopes(scopes);
    if (auth == null) return null;

    _cached = auth.accessToken;
    _expiresAt = DateTime.now().add(_assumedLife);
    return _cached;
  }

  /// The connect button. Must come from a real tap: on Android the
  /// authorization sheet cannot be raised without user interaction.
  Future<String> connect() async {
    await _ensureInitialized();

    // scopeHint asks for a combined sign-in *and* consent in one flow, which
    // Android supports. Without it the authorization request arrives after the
    // sign-in sheet has already closed, and Android will often decline to raise
    // a second one — so the first Connect signed the user in and never asked
    // for Drive at all, leaving them to discover it via "Reconnect".
    final user = await GoogleSignIn.instance.authenticate(scopeHint: scopes);

    // The hint is a preference, not a promise: the docs are explicit that this
    // can still come back null, so the explicit request stays as the fallback.
    final client = user.authorizationClient;
    final granted = await client.authorizationForScopes(scopes) ??
        await client.authorizeScopes(scopes);

    // Written only once Drive access actually exists. Remembering the account
    // before this point would leave a device that looks connected but cannot
    // sync.
    await storage.write(key: _emailKey, value: user.email);
    _cached = granted.accessToken;
    _expiresAt = DateTime.now().add(_assumedLife);
    return granted.accessToken;
  }

  /// Who is connected, from our own record. Never talks to Google, so it is
  /// safe to call on every launch.
  Future<String?> rememberedEmail() => storage.read(key: _emailKey);

  /// Whether this install has already been offered Drive once.
  ///
  /// Kept so the first-run offer is exactly that. Someone who declines gets a
  /// banner they can act on later, not the same sheet every time they open the
  /// app.
  Future<bool> hasBeenOffered() async =>
      await storage.read(key: _offeredKey) != null;

  Future<void> markOffered() =>
      storage.write(key: _offeredKey, value: 'yes');

  /// Forgets the account on this device. Drive keeps every file — the folder is
  /// the user's, and deleting their data because they tapped "disconnect" would
  /// be the wrong reading of that word.
  Future<void> disconnect() async {
    await _ensureInitialized();
    forgetToken();
    await storage.delete(key: _emailKey);
    await GoogleSignIn.instance.disconnect();
  }
}
