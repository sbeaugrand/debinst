// -------------------------------------------------------------------------- //
/// \file MainActivity.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// -------------------------------------------------------------------------- //
package fr.sbeaugrand.soleil;

import android.app.Activity;
import android.content.SharedPreferences;
import android.graphics.Insets;
import android.os.Build;
import android.os.Bundle;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowInsets;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;

public class MainActivity extends Activity
{
    // Index des courbes : 0 meridien, 1 lever, 2 coucher (cf. make coeffs)
    private static final int[] ORDER = { 1, 0, 2 };
    private static final String[] LABELS = { "Méridien", "Lever", "Coucher" };
    private static final String PREFS = "soleil";
    private static final String KEY = "coeffs";

    private double[][] coeffs;
    private LocalDate date;
    private TextView dateView;
    private final TextView[] timeViews = new TextView[3];
    private EditText edit;
    private LinearLayout config;

    @Override
    protected void onCreate(Bundle state)
    {
        super.onCreate(state);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        date = LocalDate.now();

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        int pad = dp(16);
        root.setPadding(pad, pad, pad, pad);

        LinearLayout nav = new LinearLayout(this);
        nav.setGravity(Gravity.CENTER_VERTICAL);
        Button prev = new Button(this);
        prev.setText("<");
        prev.setOnClickListener(v -> { date = date.minusDays(1); update(); });
        Button next = new Button(this);
        next.setText(">");
        next.setOnClickListener(v -> { date = date.plusDays(1); update(); });
        dateView = new TextView(this);
        dateView.setGravity(Gravity.CENTER);
        dateView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
        dateView.setOnClickListener(v -> { date = LocalDate.now(); update(); });
        nav.addView(prev);
        nav.addView(dateView, new LinearLayout.LayoutParams(
            0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        nav.addView(next);
        root.addView(nav);

        for (int i : ORDER) {
            LinearLayout row = new LinearLayout(this);
            row.setPadding(0, dp(8), 0, dp(8));
            TextView label = new TextView(this);
            label.setText(LABELS[i]);
            label.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24);
            timeViews[i] = new TextView(this);
            timeViews[i].setTextSize(TypedValue.COMPLEX_UNIT_SP, 32);
            timeViews[i].setGravity(Gravity.END);
            row.addView(label, new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
            row.addView(timeViews[i]);
            root.addView(row);
        }

        Button toggle = new Button(this);
        toggle.setText("Coefficients");
        toggle.setOnClickListener(v -> config.setVisibility(
            config.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE));
        root.addView(toggle);

        config = new LinearLayout(this);
        config.setOrientation(LinearLayout.VERTICAL);
        TextView help = new TextView(this);
        help.setText("Coller la sortie de 'make coeffs' (ou 3 lignes de "
                     + "7 coefficients : méridien, lever, coucher)");
        edit = new EditText(this);
        edit.setInputType(InputType.TYPE_CLASS_TEXT
                          | InputType.TYPE_TEXT_FLAG_MULTI_LINE
                          | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        edit.setTypeface(android.graphics.Typeface.MONOSPACE);
        edit.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        edit.setHorizontallyScrolling(true);
        Button save = new Button(this);
        save.setText("Enregistrer");
        save.setOnClickListener(v -> save());
        config.addView(help);
        config.addView(edit);
        config.addView(save);
        root.addView(config);

        ScrollView scroll = new ScrollView(this);
        scroll.addView(root);
        fitSystemBars(scroll);
        setContentView(scroll);

        String text = getSharedPreferences(PREFS, MODE_PRIVATE)
            .getString(KEY, "");
        edit.setText(text);
        coeffs = parse(text);
        config.setVisibility(coeffs == null ? View.VISIBLE : View.GONE);
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        update();
    }

    private void save()
    {
        String text = edit.getText().toString();
        double[][] c = parse(text);
        if (c == null) {
            edit.setError("Format invalide");
            return;
        }
        coeffs = c;
        getSharedPreferences(PREFS, MODE_PRIVATE).edit()
            .putString(KEY, text).apply();
        config.setVisibility(View.GONE);
        update();
    }

    // Lignes "a0 a1 b1 a2 b2 a3 b3" dans l'ordre 0 1 2,
    // ou lignes "<index>:<annees>:a0 ..." (sortie de make coeffs).
    // Si plusieurs lignes ont le meme index, la derniere l'emporte.
    static double[][] parse(String text)
    {
        double[][] c = new double[3][];
        int n = 0;
        for (String line : text.split("\n")) {
            line = line.trim();
            if (line.isEmpty()) {
                continue;
            }
            int idx = n;
            int colon = line.indexOf(':');
            if (colon >= 0) {
                try {
                    idx = Integer.parseInt(line.substring(0, colon).trim());
                } catch (NumberFormatException e) {
                    return null;
                }
                line = line.substring(line.lastIndexOf(':') + 1).trim();
            }
            String[] tok = line.split("\\s+");
            if (idx < 0 || idx > 2 || tok.length != 7) {
                return null;
            }
            double[] v = new double[7];
            try {
                for (int k = 0; k < 7; ++k) {
                    v[k] = Double.parseDouble(tok[k]);
                }
            } catch (NumberFormatException e) {
                return null;
            }
            c[idx] = v;
            ++n;
        }
        for (double[] v : c) {
            if (v == null) {
                return null;
            }
        }
        return c;
    }

    // Meme calcul que result.py : minutes UTC (jour de l annee via java.time)
    static double minutes(double[] c, LocalDate date)
    {
        int d = date.getDayOfYear();
        double w = 2 * 3.141593 / 365.242365;
        return c[0]
            + c[1] * Math.cos(1 * w * d) + c[2] * Math.sin(1 * w * d)
            + c[3] * Math.cos(2 * w * d) + c[4] * Math.sin(2 * w * d)
            + c[5] * Math.cos(3 * w * d) + c[6] * Math.sin(3 * w * d);
    }

    private void update()
    {
        dateView.setText(date.format(
            DateTimeFormatter.ofLocalizedDate(FormatStyle.FULL)));
        ZoneId zone = ZoneId.systemDefault();
        for (int i = 0; i < 3; ++i) {
            if (coeffs == null) {
                timeViews[i].setText("--:--");
                continue;
            }
            long min = (long) Math.floor(minutes(coeffs[i], date));
            ZonedDateTime t = date.atStartOfDay(ZoneOffset.UTC)
                .plusMinutes(min).withZoneSameInstant(zone);
            timeViews[i].setText(String.format("%02d:%02d",
                                               t.getHour(), t.getMinute()));
        }
    }

    private int dp(int v)
    {
        return (int) (v * getResources().getDisplayMetrics().density + 0.5f);
    }

    // Android 15+ (targetSdk 35) : affichage bord a bord impose,
    // le contenu doit s'ecarter des barres systeme et de l'encoche
    static void fitSystemBars(View view)
    {
        if (Build.VERSION.SDK_INT < 35) {
            return;
        }
        view.setOnApplyWindowInsetsListener((v, in) -> {
            Insets i = in.getInsets(WindowInsets.Type.systemBars()
                                    | WindowInsets.Type.displayCutout()
                                    | WindowInsets.Type.ime());
            v.setPadding(i.left, i.top, i.right, i.bottom);
            return WindowInsets.CONSUMED;
        });
    }
}
