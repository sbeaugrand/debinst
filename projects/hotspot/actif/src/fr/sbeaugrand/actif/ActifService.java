// ---------------------------------------------------------------------------
/// \file ActifService.java
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// ---------------------------------------------------------------------------
package fr.sbeaugrand.actif;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.SystemClock;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Quand l'ecran s'allume (SCREEN_ON), consulte l'URL tout de suite puis chaque
 * minute tant que l'ecran reste allume. S'arrete des que l'ecran s'eteint.
 *
 * SCREEN_ON est utilise plutot que USER_PRESENT (deverrouillage) car Samsung
 * "saute" (Skipped) la livraison de USER_PRESENT a l'appli lorsque le telephone
 * est reste verrouille un moment, alors que SCREEN_ON/SCREEN_OFF sont fiables.
 */
public class ActifService extends Service {
    static final String TAG = "Actif";
    static final String ACTION_TEST = "fr.sbeaugrand.actif.TEST";
    private static final String CANAL = "actif";
    private static final int NOTIF_ID = 1;
    private static final long PERIODE = 60 * 1000;

    private HandlerThread thread;
    private Handler handler;
    private volatile long dernierDeclenchement;
    private String dernier = "aucun appel";

    private final Runnable tick = new Runnable() {
        @Override
        public void run() {
            appeler();
            // Continue tant que l'ecran est allume ; filet de securite au
            // cas ou SCREEN_OFF serait manque.
            PowerManager pm = getSystemService(PowerManager.class);
            if (pm != null && pm.isInteractive()) {
                handler.postDelayed(this, PERIODE);
            }
        }
    };

    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.i(TAG, "evenement " + action);
            if (Intent.ACTION_SCREEN_ON.equals(action)) {
                demarrer();
            } else if (Intent.ACTION_SCREEN_OFF.equals(action)) {
                handler.removeCallbacks(tick);
            }
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        NotificationManager nm = getSystemService(NotificationManager.class);
        // IMPORTANCE_MIN : aucune icone dans la barre d'etat, notification
        // repliee en bas du volet (le minimum impose a un service de 1er plan).
        nm.createNotificationChannel(new NotificationChannel(CANAL,
            "Systeme", NotificationManager.IMPORTANCE_MIN));
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIF_ID, notification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE);
        } else {
            startForeground(NOTIF_ID, notification());
        }

        thread = new HandlerThread("actif");
        thread.start();
        handler = new Handler(thread.getLooper());

        IntentFilter filtre = new IntentFilter();
        filtre.addAction(Intent.ACTION_SCREEN_ON);
        filtre.addAction(Intent.ACTION_SCREEN_OFF);
        // scheduler = null : onReceive s'execute sur le thread principal, et non
        // sur le HandlerThread que appeler() bloque ~5 s. Ainsi les deux SCREEN_ON
        // que Samsung envoie (~185 ms d'ecart) arrivent rapproches et l'anti-rebond
        // de demarrer() les voit (sinon le 2e serait retarde a ~5 s et passerait).
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(receiver, filtre, null, null,
                Context.RECEIVER_NOT_EXPORTED);
        } else {
            registerReceiver(receiver, filtre, null, null);
        }

        // Au demarrage du service (ex. apres un redemarrage du telephone),
        // l'ecran est deja allume : le SCREEN_ON a ete emis avant notre
        // enregistrement. On declenche donc tout de suite si l'ecran est allume.
        PowerManager pm = getSystemService(PowerManager.class);
        if (pm != null && pm.isInteractive()) {
            demarrer();
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_TEST.equals(intent.getAction())) {
            handler.post(this::demarrer);
        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        unregisterReceiver(receiver);
        thread.quitSafely();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void demarrer() {
        // Anti-rebond : Samsung emet deux SCREEN_ON par allumage (~185 ms). On
        // ignore un declenchement survenant moins de 2 s apres le precedent.
        long now = SystemClock.elapsedRealtime();
        if (now - dernierDeclenchement < 2000) {
            return;
        }
        dernierDeclenchement = now;
        handler.removeCallbacks(tick);
        handler.post(tick);
    }

    private void appeler() {
        String heure = new SimpleDateFormat("HHmmss", Locale.ROOT)
            .format(new Date());
        String host = getString(R.string.host).replace("{t}", heure);
        String resultat;
        // Un seul paquet DNS UDP envoye a la main. Contrairement a getaddrinfo
        // (InetAddress / HttpURLConnection), aucune retransmission : si le DNS
        // du hotspot ne repond pas, on n'emet pas une 2e requete 5 s plus tard.
        try {
            InetAddress dns = premierDns();
            if (dns == null) {
                resultat = "aucun DNS";
            } else {
                byte[] q = requeteDns(host);
                DatagramSocket s = new DatagramSocket();
                try {
                    s.send(new DatagramPacket(q, q.length, dns, 53));
                    resultat = "envoye a " + dns.getHostAddress();
                } finally {
                    s.close();
                }
            }
        } catch (Exception e) {
            resultat = e.getClass().getSimpleName();
        }
        Log.i(TAG, host + " -> " + resultat);
        dernier = heure.substring(0, 2) + ":" + heure.substring(2, 4) + ":"
            + heure.substring(4) + " " + resultat;
        getSystemService(NotificationManager.class)
            .notify(NOTIF_ID, notification());
    }

    /** Premier serveur DNS du reseau actif (celui du hotspot). */
    private InetAddress premierDns() {
        ConnectivityManager cm = getSystemService(ConnectivityManager.class);
        Network n = cm.getActiveNetwork();
        if (n == null) {
            return null;
        }
        LinkProperties lp = cm.getLinkProperties(n);
        if (lp == null || lp.getDnsServers().isEmpty()) {
            return null;
        }
        return lp.getDnsServers().get(0);
    }

    /** Construit un paquet de requete DNS (type A, recursion demandee). */
    private byte[] requeteDns(String host) {
        ByteArrayOutputStream b = new ByteArrayOutputStream();
        int id = (int) (System.nanoTime() & 0xFFFF);
        b.write(id >> 8); b.write(id & 0xFF);
        b.write(0x01); b.write(0x00);   // flags : recursion demandee
        b.write(0x00); b.write(0x01);   // QDCOUNT = 1
        b.write(0x00); b.write(0x00);   // ANCOUNT
        b.write(0x00); b.write(0x00);   // NSCOUNT
        b.write(0x00); b.write(0x00);   // ARCOUNT
        for (String label : host.split("\\.")) {
            byte[] l = label.getBytes(StandardCharsets.UTF_8);
            b.write(l.length);
            b.write(l, 0, l.length);
        }
        b.write(0x00);                  // fin du nom
        b.write(0x00); b.write(0x01);   // QTYPE = A
        b.write(0x00); b.write(0x01);   // QCLASS = IN
        return b.toByteArray();
    }

    private Notification notification() {
        return new Notification.Builder(this, CANAL)
            .setSmallIcon(android.R.drawable.stat_notify_sync_noanim)
            .setContentTitle("Actif")
            .setContentText("Dernier appel : " + dernier)
            .setOngoing(true)
            .build();
    }
}
