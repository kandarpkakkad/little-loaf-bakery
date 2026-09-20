#!/usr/bin/env python3
"""Mint the refresh token the release pipeline needs, locally.

    tool/mint_refresh_token.py

Opens a browser, asks you to consent as the bakery account, catches the code on
localhost, and exchanges it for a refresh token. Then it **proves the token
works** by looking for the app's Drive folder with it — because the whole thing
rests on an assumption worth checking before a release depends on it: that
`drive.file` treats the Cloud project as "the app", so a Web client can see
files the Android client created.

Locally rather than through Google's OAuth Playground, so the client secret
never leaves this machine.

One-time setup in the Cloud console, on the **Web** client:

    APIs & Services → Credentials → (the Web client) → Authorised redirect URIs
    add:  http://localhost:8765/

You can remove it again afterwards.

With `gh` signed in to the right account, this also sets the three repository
secrets for you, so the token is never pasted anywhere.
"""

import glob
import http.server
import json
import os
import subprocess
import sys
import threading
import urllib.error
import urllib.parse
import urllib.request
import webbrowser

PORT = 8765
REDIRECT = f"http://localhost:{PORT}/"
SCOPE = "https://www.googleapis.com/auth/drive.file"
AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
TOKEN_URL = "https://oauth2.googleapis.com/token"
DRIVE = "https://www.googleapis.com/drive/v3"
ROOT_NAME = "Little Loaf Bakery"

_code = {}


class Catch(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)
        _code.update({k: v[0] for k, v in params.items()})

        ok = "code" in params
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(
            (
                "<html><body style='font-family:system-ui;padding:3rem'>"
                + (
                    "<h2>Done.</h2><p>You can close this tab and go back to the terminal.</p>"
                    if ok
                    else f"<h2>Not authorised</h2><p>{params.get('error', ['unknown'])[0]}</p>"
                )
                + "</body></html>"
            ).encode()
        )

    def log_message(self, *args):
        pass  # the server is an implementation detail, not something to narrate


def die(message):
    print(f"\n✗ {message}\n", file=sys.stderr)
    sys.exit(1)


def post(url, form):
    body = urllib.parse.urlencode(form).encode()
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            return json.loads(res.read())
    except urllib.error.HTTPError as e:
        die(f"{url} returned {e.code}: {e.read().decode('utf-8', 'replace')[:400]}")


def app_client_id():
    """What the app actually ships with. The token has to be for this one."""
    import re

    source = open("lib/platform/sync/drive_auth.dart").read()
    found = re.search(r"kServerClientId\s*=\s*\n?\s*'([^']+)'", source)
    return found.group(1) if found else None


def web_client():
    candidates = []
    for path in sorted(glob.glob("secrets/client_secret_*.json")):
        with open(path) as f:
            data = json.load(f)
        if "web" in data:
            candidates.append(data["web"])

    if not candidates:
        die("no Web client found in secrets/. Files of type 'installed' are "
            "the Android clients: they carry no secret and cannot do this.")

    # A token minted against the wrong project would work perfectly and see
    # nothing, because drive.file scopes to the app that created the files.
    # That failure is silent, so it is worth refusing up front.
    wanted = app_client_id()
    if wanted:
        for c in candidates:
            if c["client_id"] == wanted:
                return c
        die(f"none of the Web clients in secrets/ is the one the app uses.\n"
            f"  app ships with : {wanted}\n"
            f"  found here     : {', '.join(c['client_id'] for c in candidates)}\n"
            f"A token for a different project would see none of the app's files.")

    return candidates[0]


def main():
    client = web_client()
    client_id = client["client_id"]
    client_secret = client["client_secret"]

    print(f"Web client : {client_id}")
    print(f"Project    : {client.get('project_id')}")
    print(f"Redirect   : {REDIRECT}")
    print(
        "\nIf this fails with redirect_uri_mismatch, add that exact redirect "
        "URI to the Web client in the Cloud console and run this again.\n"
    )

    server = http.server.HTTPServer(("localhost", PORT), Catch)
    threading.Thread(target=server.handle_request, daemon=True).start()

    url = f"{AUTH_URL}?" + urllib.parse.urlencode(
        {
            "client_id": client_id,
            "redirect_uri": REDIRECT,
            "response_type": "code",
            "scope": SCOPE,
            # offline + consent together are what actually produce a refresh
            # token. Without prompt=consent Google returns one only on the
            # very first authorisation ever, and silently omits it after that.
            "access_type": "offline",
            "prompt": "consent",
        }
    )

    print("Opening a browser. Sign in as the bakery account…")
    webbrowser.open(url)
    print(f"If nothing opened, paste this in yourself:\n\n{url}\n")

    for _ in range(600):   # ten minutes is plenty to find a password
        if _code:
            break
        threading.Event().wait(1)
    else:
        die("timed out waiting for the browser")

    if "error" in _code:
        die(f"authorisation refused: {_code['error']}")

    tokens = post(
        TOKEN_URL,
        {
            "code": _code["code"],
            "client_id": client_id,
            "client_secret": client_secret,
            "redirect_uri": REDIRECT,
            "grant_type": "authorization_code",
        },
    )

    refresh = tokens.get("refresh_token")
    access = tokens.get("access_token")
    if not refresh:
        die("Google returned no refresh token. That usually means this account "
            "has consented before — revoke the app at "
            "myaccount.google.com/permissions and run this again.")

    # The assumption, checked. If drive.file did not treat the project as the
    # app, this would come back empty and a release would quietly announce
    # nothing.
    print("\nChecking the token can see the app's folder…")
    q = urllib.parse.urlencode(
        {
            "q": f"name = '{ROOT_NAME}' and mimeType = "
                 f"'application/vnd.google-apps.folder' and trashed = false",
            "fields": "files(id,name)",
        }
    )
    req = urllib.request.Request(
        f"{DRIVE}/files?{q}", headers={"Authorization": f"Bearer {access}"}
    )
    with urllib.request.urlopen(req, timeout=30) as res:
        files = json.loads(res.read()).get("files") or []

    if files:
        print(f"  ✓ found '{ROOT_NAME}' — the Web client can see what the "
              f"Android app created.")
    else:
        print(f"  ! no '{ROOT_NAME}' folder visible yet.")
        print("    Either no device has connected Drive, or drive.file is not "
              "sharing the app identity across clients.")
        print("    Connect Drive on a device, then run this again to tell "
              "the two apart — before a release depends on it.")

    print("\nRefresh token minted.")

    if input("Set the three GitHub secrets now with gh? [Y/n] ").strip().lower() in ("", "y"):
        for name, value in [
            ("GOOGLE_CLIENT_ID", client_id),
            ("GOOGLE_CLIENT_SECRET", client_secret),
            ("GOOGLE_REFRESH_TOKEN", refresh),
        ]:
            r = subprocess.run(
                ["gh", "secret", "set", name],
                input=value,
                text=True,
                capture_output=True,
            )
            print(f"  {'✓' if r.returncode == 0 else '✗'} {name}"
                  f"{'' if r.returncode == 0 else ': ' + r.stderr.strip()}")
        print("\nDone. Nothing was written to disk.")
    else:
        print("\nSet them yourself — the refresh token is:\n")
        print(f"  {refresh}\n")
        print("GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET are in the web "
              "client file in secrets/.")

    print(
        "\nNote: while the OAuth consent screen is in Testing, Google expires "
        "refresh tokens after seven days. Publishing the consent screen stops "
        "that — and stops the same expiry biting sign-in on the devices."
    )


if __name__ == "__main__":
    if not os.path.isdir("secrets"):
        die("run this from the repository root")
    main()
