package com.littleloaf.whatsappstub;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

/**
 * Shows whatever Little Loaf handed over: the raw link, the number it resolved
 * to, and the decoded message text.
 *
 * The message is the part worth reading — a wa.me link that opens is only half
 * the check; the text has to be right too, and on a real phone WhatsApp would
 * swallow it into a chat box that is awkward to read back.
 */
public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        render(getIntent());
    }

    /** A second link arriving while this is already open replaces the contents. */
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        render(intent);
    }

    private void render(Intent intent) {
        LinearLayout column = new LinearLayout(this);
        column.setOrientation(LinearLayout.VERTICAL);
        column.setBackgroundColor(Color.parseColor("#FFFDF7"));
        int pad = dp(20);
        column.setPadding(pad, pad, pad, pad);

        column.addView(heading("WhatsApp (stub)"));
        column.addView(note("Not the real WhatsApp. It claims the same links so "
                + "the hand-off can be checked on this emulator."));

        Uri data = intent == null ? null : intent.getData();
        String shared = intent == null
                ? null
                : intent.getStringExtra(Intent.EXTRA_TEXT);

        if (data == null && shared == null) {
            column.addView(field("Nothing received",
                    "Opened from the launcher rather than from a link.\n\n"
                            + "Open an order in Little Loaf and tap a WhatsApp "
                            + "action to send something here."));
        } else if (data != null) {
            column.addView(field("Link", data.toString()));
            column.addView(field("To", phoneFrom(data)));
            column.addView(field("Message", messageFrom(data)));
        } else {
            column.addView(field("Shared text", shared));
        }

        ScrollView scroller = new ScrollView(this);
        scroller.addView(column, new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT));
        setContentView(scroller);
    }

    /**
     * wa.me carries the number as the path — "wa.me/919876543210". The
     * api.whatsapp.com form uses a ?phone= parameter instead.
     */
    private String phoneFrom(Uri uri) {
        String path = uri.getPath();
        if (path != null && path.length() > 1) {
            String digits = path.substring(1);
            if (digits.matches("\\d+")) {
                return "+" + digits;
            }
        }
        String param = uri.getQueryParameter("phone");
        return param != null ? param : "(none in link)";
    }

    /** getQueryParameter decodes the percent-encoding for us. */
    private String messageFrom(Uri uri) {
        String text = uri.getQueryParameter("text");
        return text != null ? text : "(no text in link)";
    }

    private TextView heading(String s) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22);
        t.setTypeface(Typeface.DEFAULT_BOLD);
        t.setTextColor(Color.parseColor("#1F3A44"));
        t.setGravity(Gravity.START);
        return t;
    }

    private TextView note(String s) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        t.setTextColor(Color.parseColor("#7A8B92"));
        t.setPadding(0, dp(4), 0, dp(20));
        return t;
    }

    private LinearLayout field(String label, String value) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(0, 0, 0, dp(20));

        TextView l = new TextView(this);
        l.setText(label.toUpperCase());
        l.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11);
        l.setTypeface(Typeface.DEFAULT_BOLD);
        l.setTextColor(Color.parseColor("#7A8B92"));

        TextView v = new TextView(this);
        v.setText(value);
        v.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15);
        v.setTextColor(Color.parseColor("#1F3A44"));
        v.setTextIsSelectable(true);
        v.setPadding(0, dp(4), 0, 0);

        box.addView(l);
        box.addView(v);
        return box;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
