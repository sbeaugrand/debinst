// ---------------------------------------------------------------------------
/// \file MainActivity.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// ---------------------------------------------------------------------------
package fr.sbeaugrand.actif;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.PowerManager;
import android.provider.Settings;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Demande les autorisations, demarre le service et se fait discrete. */
public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Pas de demande de POST_NOTIFICATIONS : l'appli se veut discrete et le
        // service de premier plan tourne meme si la notification est masquee.
        startForegroundService(new Intent(this, ActifService.class));
    }

    @Override
    protected void onResume() {
        super.onResume();
        PowerManager pm = getSystemService(PowerManager.class);
        boolean batterieOk = pm.isIgnoringBatteryOptimizations(getPackageName());
        // Une fois la batterie reglee, on cache l'icone du lanceur.
        if (batterieOk) {
            cacherIcone();
        }
        afficher(batterieOk);
    }

    /** Desactive l'alias porteur de l'icone : disparait de la liste des apps. */
    private void cacherIcone() {
        ComponentName alias = new ComponentName(this,
            getPackageName() + ".Launcher");
        PackageManager pm = getPackageManager();
        if (pm.getComponentEnabledSetting(alias)
            != PackageManager.COMPONENT_ENABLED_STATE_DISABLED) {
            pm.setComponentEnabledSetting(alias,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP);
        }
    }

    private void afficher(boolean batterieOk) {
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        int p = (int) (16 * getResources().getDisplayMetrics().density);
        l.setPadding(p, p * 3, p, p);

        TextView t = new TextView(this);
        String msg = "Service demarre.\n\nA chaque allumage de l'ecran, requete DNS "
            + getString(R.string.host) + " puis chaque minute tant que l'ecran "
            + "reste allume.\n";
        if (batterieOk) {
            msg += "\nOptimisation de batterie desactivee. L'icone est "
                + "retiree de la liste des applications.\nPour rouvrir cet "
                + "ecran : make install.\n";
        }
        t.setText(msg);
        l.addView(t);

        Button test = new Button(this);
        test.setText("Tester maintenant");
        test.setOnClickListener(v -> startForegroundService(
            new Intent(this, ActifService.class)
                .setAction(ActifService.ACTION_TEST)));
        l.addView(test);

        if (!batterieOk) {
            Button batterie = new Button(this);
            batterie.setText("Desactiver l'optimisation de batterie");
            batterie.setOnClickListener(v -> startActivity(new Intent(
                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                Uri.parse("package:" + getPackageName()))));
            l.addView(batterie);
        }
        setContentView(l);
    }
}
