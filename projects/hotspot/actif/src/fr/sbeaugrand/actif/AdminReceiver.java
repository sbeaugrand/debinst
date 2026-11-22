// ---------------------------------------------------------------------------
/// \file AdminReceiver.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// ---------------------------------------------------------------------------
package fr.sbeaugrand.actif;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Administrateur de l'appareil. Tant qu'il est actif, le bouton Desinstaller
 * est grise : l'appli ne peut etre retiree qu'apres desactivation de l'admin
 * (par adb : dpm remove-active-admin, fait par make uninstall).
 */
public class AdminReceiver extends DeviceAdminReceiver {
    @Override
    public CharSequence onDisableRequested(Context context, Intent intent) {
        return "Actif cessera d'etre protege contre la desinstallation.";
    }
}
