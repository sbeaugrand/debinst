// ---------------------------------------------------------------------------
/// \file BootReceiver.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// ---------------------------------------------------------------------------
package fr.sbeaugrand.actif;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/** Relance le service au demarrage du telephone et apres mise a jour. */
public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        context.startForegroundService(
            new Intent(context, ActifService.class));
    }
}
