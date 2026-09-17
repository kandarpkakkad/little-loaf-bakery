import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import 'remote_store.dart';

/// A [RemoteStore] backed by one folder in the user's Google Drive.
///
///     Little Loaf Bakery/
///       journal/
///         <device-id>/
///           ops.jsonl
///           device.json
///
/// The folder is **created by the app**, which is what `drive.file` requires:
/// that scope grants access only to files this app made, so a folder the user
/// created by hand is invisible here and cannot be used. The upside is that the
/// app can never see anything else in their Drive.
class DriveStore implements RemoteStore {
  DriveStore(this._api);

  /// Builds one from a bare access token.
  factory DriveStore.withToken(String accessToken) =>
      DriveStore(drive.DriveApi(_BearerClient(accessToken)));

  final drive.DriveApi _api;

  static const rootFolderName = 'Little Loaf Bakery';
  static const _journalFolder = 'journal';
  static const _opsFile = 'ops.jsonl';
  static const _metaFile = 'device.json';
  static const _folderMime = 'application/vnd.google-apps.folder';

  /// Folder ids, cached for the life of one sync run. Drive ids are stable, and
  /// a lookup costs a round trip.
  final Map<String, String> _folderIds = {};

  Future<String> _rootId() => _folder(rootFolderName, parent: null);

  Future<String> _journalId() async =>
      _folder(_journalFolder, parent: await _rootId());

  Future<String> _deviceFolderId(String deviceId) async =>
      _folder(deviceId, parent: await _journalId());

  /// Finds a folder by name under [parent], creating it if absent.
  ///
  /// Two devices doing this at the same moment can both create one, because
  /// Drive has no unique-name constraint. The oldest wins on the next run — the
  /// listing is sorted by creation time — so the pair converges rather than
  /// splitting the journal permanently.
  Future<String> _folder(String name, {required String? parent}) async {
    final cacheKey = '${parent ?? 'root'}/$name';
    final cached = _folderIds[cacheKey];
    if (cached != null) return cached;

    final q = [
      "name = '${_escape(name)}'",
      "mimeType = '$_folderMime'",
      'trashed = false',
      if (parent != null) "'$parent' in parents",
    ].join(' and ');

    final found = await _api.files.list(
      q: q,
      $fields: 'files(id,createdTime)',
      orderBy: 'createdTime',
      pageSize: 10,
    );

    final id = found.files?.isNotEmpty == true
        ? found.files!.first.id!
        : (await _api.files.create(drive.File()
              ..name = name
              ..mimeType = _folderMime
              ..parents = parent == null ? null : [parent]))
            .id!;

    _folderIds[cacheKey] = id;
    return id;
  }

  @override
  Future<List<String>> listDevices() async {
    final journal = await _journalId();
    final result = await _api.files.list(
      q: "'$journal' in parents and mimeType = '$_folderMime' and trashed = false",
      $fields: 'files(id,name)',
      pageSize: 100,
    );
    return [for (final f in result.files ?? const <drive.File>[]) f.name!];
  }

  @override
  Future<String?> readJournal(String deviceId) =>
      _readText(deviceId, _opsFile);

  @override
  Future<void> writeJournal(String deviceId, String body) =>
      _writeText(deviceId, _opsFile, body);

  @override
  Future<String?> readDeviceMeta(String deviceId) =>
      _readText(deviceId, _metaFile);

  @override
  Future<void> writeDeviceMeta(String deviceId, String json) =>
      _writeText(deviceId, _metaFile, json);

  Future<String?> _fileId(String deviceId, String name) async {
    final folder = await _deviceFolderId(deviceId);
    final found = await _api.files.list(
      q: "name = '${_escape(name)}' and '$folder' in parents and trashed = false",
      $fields: 'files(id)',
      pageSize: 1,
    );
    return found.files?.isNotEmpty == true ? found.files!.first.id : null;
  }

  Future<String?> _readText(String deviceId, String name) async {
    final id = await _fileId(deviceId, name);
    if (id == null) return null;
    final media = await _api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    return utf8.decodeStream(media.stream);
  }

  /// Creates or replaces the file whole. Drive replaces atomically, so a reader
  /// gets the previous revision or the new one and never a half-written splice
  /// — which is the only reason re-uploading the entire journal is safe.
  Future<void> _writeText(String deviceId, String name, String body) async {
    final bytes = utf8.encode(body);
    final media = drive.Media(Stream.value(bytes), bytes.length,
        contentType: 'application/json');
    final existing = await _fileId(deviceId, name);

    if (existing == null) {
      final folder = await _deviceFolderId(deviceId);
      await _api.files.create(
        drive.File()
          ..name = name
          ..parents = [folder],
        uploadMedia: media,
      );
    } else {
      await _api.files.update(drive.File(), existing, uploadMedia: media);
    }
  }

  /// Drive's query language is string-quoted, so a name containing a quote
  /// would otherwise break the query rather than simply not matching.
  static String _escape(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}

/// Adds the bearer token to every request. Smaller than pulling in an extra
/// package for the same three lines.
class _BearerClient extends http.BaseClient {
  _BearerClient(this._token);

  final String _token;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
