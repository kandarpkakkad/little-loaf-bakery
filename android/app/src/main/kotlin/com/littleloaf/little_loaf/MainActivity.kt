package com.littleloaf.little_loaf

import io.flutter.embedding.android.FlutterFragmentActivity

// FragmentActivity, not FlutterActivity: the biometric prompt behind the app
// lock is a fragment, and on a plain FlutterActivity it throws at the moment it
// is asked for rather than at build time.
class MainActivity : FlutterFragmentActivity()
