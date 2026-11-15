// -------------------------------------------------------------------------- //
/// \file MainActivity.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// -------------------------------------------------------------------------- //
package fr.sbeaugrand.soleilweb;

import android.app.Activity;
import android.graphics.Insets;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowInsets;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.FrameLayout;

// Affiche ../../html/build/soleil.html embarque dans les assets
public class MainActivity extends Activity
{
    private WebView web;

    @Override
    protected void onCreate(Bundle state)
    {
        super.onCreate(state);
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);  // localStorage : coefficients saisis
        s.setAllowFileAccess(true);    // file:///android_asset/
        s.setBlockNetworkLoads(true);
        FrameLayout frame = new FrameLayout(this);
        frame.addView(web);
        fitSystemBars(frame);
        setContentView(frame);
        if (state == null || web.restoreState(state) == null) {
            web.loadUrl("file:///android_asset/soleil.html");
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle state)
    {
        super.onSaveInstanceState(state);
        web.saveState(state);
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
