#!/usr/bin/env python3
"""Announce a release in the bakery's Drive folder.

Writes `app.json` at the root of the "Little Loaf Bakery" folder, so every
device learns about a new build on its next sync rather than waiting until
somebody installs it. Run by the release pipeline; see
docs/01-platform/versioning/lld.md §4.

Needs three secrets, all for the *same* Cloud project as the app:

    GOOGLE_CLIENT_ID       the Web OAuth client
    GOOGLE_CLIENT_SECRET   its secret
    GOOGLE_REFRESH_TOKEN   a refresh token for the bakery account, with
                           the drive.file scope

`drive.file` grants access to files the *app* created, and the app is the Cloud
project rather than one client within it — which is the only reason a script
signing in as a Web client can touch a folder the Android client made.

Stdlib only, on purpose: a release must not depend on a package index being up.
"""

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

TOKEN_URL = "https://oauth2.googleapis.com/token"
DRIVE = "https://www.googleapis.com/drive/v3"
UPLOAD = "https://www.googleapis.com/upload/drive/v3"
FOLDER_MIME = "application/vnd.google-apps.folder"
ROOT_NAME = "Little Loaf Bakery"
APP_JSON = "app.json"


def fail(message):
    print(f"::error::{message}", file=sys.stderr)
    sys.exit(1)


def request(url, *, token=None, method="GET", body=None, content_type=None):
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if content_type:
        headers["Content-Type"] = content_type
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            raw = res.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", "replace")[:500]
        fail(f"{method} {url.split('?')[0]} returned {e.code}: {detail}")
    except urllib.error.URLError as e:
        fail(f"could not reach {url.split('?')[0]}: {e.reason}")


def access_token(client_id, client_secret, refresh_token):
    form = urllib.parse.urlencode(
        {
            "client_id": client_id,
            "client_secret": client_secret,
            "refresh_token": refresh_token,
            "grant_type": "refresh_token",
        }
    ).encode()
    got = request(
        TOKEN_URL,
        method="POST",
        body=form,
        content_type="application/x-www-form-urlencoded",
    )
    token = got.get("access_token")
    if not token:
        fail("the refresh token did not yield an access token — it may have "
             "been revoked, or the consent may have expired while the OAuth "
             "project is still in Testing")
    return token


def find(token, query):
    q = urllib.parse.urlencode({"q": query, "fields": "files(id,name)", "pageSize": "10"})
    found = request(f"{DRIVE}/files?{q}", token=token)
    return found.get("files") or []


def main():
    version = os.environ.get("VERSION", "").strip()
    min_supported = os.environ.get("MIN_SUPPORTED", "").strip()
    apk_url = os.environ.get("APK_URL", "").strip()

    if not version or not min_supported:
        fail("VERSION and MIN_SUPPORTED are both required")

    token = access_token(
        os.environ["GOOGLE_CLIENT_ID"],
        os.environ["GOOGLE_CLIENT_SECRET"],
        os.environ["GOOGLE_REFRESH_TOKEN"],
    )

    roots = find(
        token,
        f"name = '{ROOT_NAME}' and mimeType = '{FOLDER_MIME}' and trashed = false",
    )
    if not roots:
        # Not an error. No device has ever connected Drive, so there is no
        # folder to announce into — and the first one to launch will write
        # app.json itself. Creating the folder here would make a second one
        # the app cannot tell apart from its own.
        print("::notice::No 'Little Loaf Bakery' folder in Drive yet — "
              "nothing to announce into. The first device to sync will "
              "create it and write app.json itself.")
        return

    root = roots[0]["id"]

    payload = {
        "latest_version": version,
        "min_supported_version": min_supported,
        "apk_url": apk_url or None,
        "published_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }
    body = json.dumps(payload, indent=2).encode()

    existing = find(token, f"name = '{APP_JSON}' and '{root}' in parents and trashed = false")

    if existing:
        file_id = existing[0]["id"]
        request(
            f"{UPLOAD}/files/{file_id}?uploadType=media",
            token=token,
            method="PATCH",
            body=body,
            content_type="application/json",
        )
        print(f"Updated app.json → {version} (floor {min_supported})")
    else:
        # A multipart create, hand-rolled rather than pulling in a client
        # library for one request.
        boundary = "----little-loaf-app-json"
        metadata = json.dumps({"name": APP_JSON, "parents": [root]}).encode()
        multipart = b"".join(
            [
                f"--{boundary}\r\n".encode(),
                b"Content-Type: application/json; charset=UTF-8\r\n\r\n",
                metadata,
                f"\r\n--{boundary}\r\n".encode(),
                b"Content-Type: application/json\r\n\r\n",
                body,
                f"\r\n--{boundary}--\r\n".encode(),
            ]
        )
        request(
            f"{UPLOAD}/files?uploadType=multipart",
            token=token,
            method="POST",
            body=multipart,
            content_type=f"multipart/related; boundary={boundary}",
        )
        print(f"Created app.json → {version} (floor {min_supported})")


if __name__ == "__main__":
    main()
