package io.privacy.anom.vpn;


import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.VpnService;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;


import java.lang.ref.WeakReference;

import io.privacy.anom.Configuration;
import io.privacy.anom.MainActivity;
import io.privacy.anom.R;

public class AnomVPNService extends VpnService implements Handler.Callback{
    public static final int NOTIFICATION_ID_STATE = 10;
    public static final int REQUEST_CODE_START = 43;
    public static final int REQUEST_CODE_PAUSE = 42;
    public static final String VPN_UPDATE_STATUS_INTENT = "io.privacy.anom.VPN_UPDATE_STATUS";

    public enum Command {
        START, STOP, PAUSE, RESUME
    }
    public void showVPNNotification(String msg){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("io.privacy.anom.vpn.notification", "anom", NotificationManager.IMPORTANCE_DEFAULT);
            channel.setDescription("Nothing");
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "io.privacy.anom.vpn.notification")
                .setSmallIcon(R.drawable.launch_background)
                .setContentTitle("VPN Update")
                .setContentText(msg)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT);
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        notificationManager.notify(1, builder.build());

    }


    private static class MyHandler extends Handler {
        private final WeakReference<Callback> callback;
        public MyHandler(Handler.Callback callback) {
            this.callback = new WeakReference<Callback>(callback);
        }
        @Override
        public void handleMessage(Message msg) {
            Handler.Callback callback = this.callback.get();
            if (callback != null) {
                callback.handleMessage(msg);
            }
            super.handleMessage(msg);
        }
    }


    public static final int VPN_STATUS_STARTING = 0;
    public static final int VPN_STATUS_RUNNING = 1;
    public static final int VPN_STATUS_STOPPING = 2;
    public static final int VPN_STATUS_WAITING_FOR_NETWORK = 3;
    public static final int VPN_STATUS_RECONNECTING = 4;
    public static final int VPN_STATUS_RECONNECTING_NETWORK_ERROR = 5;

    public static final int VPN_STATUS_STOPPED = 6;

    public static final String VPN_UPDATE_STATUS_EXTRA = "VPN_STATUS";
    private static final int VPN_MSG_STATUS_UPDATE = 0;
    private static final int VPN_MSG_NETWORK_CHANGED = 1;
    private static final String TAG = "VpnService";
    public static int vpnStatus = VPN_STATUS_STOPPED;

    private final Handler handler = new MyHandler(this);
    private AnomVPNThread vpnThread = new AnomVPNThread(this, new AnomVPNThread.Notify() {
        @Override
        public void run(int value) {
            handler.sendMessage(handler.obtainMessage(VPN_MSG_STATUS_UPDATE, value, 0));
        }
    });
    private final BroadcastReceiver connectivityChangedReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            handler.sendMessage(handler.obtainMessage(VPN_MSG_NETWORK_CHANGED, intent));
        }
    };


    public static String vpnStatusToTextId(int status) {
        switch (status) {
            case VPN_STATUS_STARTING:
                return "VPN STATUS STARTING";
            case VPN_STATUS_RUNNING:
                return "VPN_STATUS_RUNNING";
            case VPN_STATUS_STOPPING:
                return "VPN_STATUS_STOPPING";
            case VPN_STATUS_WAITING_FOR_NETWORK:
                return "VPN_STATUS_WAITING_FOR_NETWORK";
            case VPN_STATUS_RECONNECTING:
                return "VPN_STATUS_RECONNECTING";
            case VPN_STATUS_RECONNECTING_NETWORK_ERROR:
                return "VPN_STATUS_RECONNECTING_NETWORK_ERROR";
            case VPN_STATUS_STOPPED:
                return "VPN_STATUS_STOPPED";
            default:
                throw new IllegalArgumentException("Invalid vpnStatus value (" + status + ")");
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();

    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static void checkStartVpnOnBoot(Context context) {
        Log.i("BOOT", "Checking whether to start ad buster on boot");
        Configuration config = new Configuration();
        if (config == null || !config.autoStart) {
            return;
        }
        if (!context.getSharedPreferences("state", MODE_PRIVATE).getBoolean("isActive", false)) {
            return;
        }

        if (VpnService.prepare(context) != null) {
            Log.i("BOOT", "VPN preparation not confirmed by user, changing enabled to false");
        }

        Log.i("BOOT", "Starting ad buster from boot");

        Intent intent = getStartIntent(context);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent);
        } else {
            context.startService(intent);
        }
    }

    @NonNull
    private static Intent getStartIntent(Context context) {
        Intent intent = new Intent(context, AnomVPNService.class);
        intent.putExtra("COMMAND", Command.START.ordinal());
        intent.putExtra("NOTIFICATION_INTENT",
                PendingIntent.getActivity(context, 0,
                        new Intent(context, MainActivity.class), 0));
        return intent;
    }

    @NonNull
    private static Intent getResumeIntent(Context context) {
        Intent intent = new Intent(context, AnomVPNService.class);
        intent.putExtra("COMMAND", Command.RESUME.ordinal());
        intent.putExtra("NOTIFICATION_INTENT",
                PendingIntent.getActivity(context, 0,
                        new Intent(context, MainActivity.class), 0));
        return intent;
    }
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
        Log.i(TAG, "onStartCommand" + intent);
        switch (intent == null ? Command.START : Command.values()[intent.getIntExtra("COMMAND", Command.START.ordinal())]) {
            case RESUME:
                NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.cancelAll();
                // fallthrough
            case START:
                getSharedPreferences("state", MODE_PRIVATE).edit().putBoolean("isActive", true).apply();
                startVpn();
                break;
            case STOP:
                getSharedPreferences("state", MODE_PRIVATE).edit().putBoolean("isActive", false).apply();
                stopVpn();
                break;
            case PAUSE:
                pauseVpn();
                break;
        }

        return Service.START_STICKY;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void pauseVpn() {
        stopVpn();
       showVPNNotification("Pause");
    }

    private void updateVpnStatus(int status) {
        vpnStatus = status;
        String notificationTextId = vpnStatusToTextId(status);
        showVPNNotification(notificationTextId);


        Intent intent = new Intent(VPN_UPDATE_STATUS_INTENT);
        intent.putExtra(VPN_UPDATE_STATUS_EXTRA, status);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }


    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void startVpn() {
        showVPNNotification("Starting VPN");
        updateVpnStatus(VPN_STATUS_STARTING);

        registerReceiver(connectivityChangedReceiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));

        restartVpnThread();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void restartVpnThread() {
        if (vpnThread == null) {
            Log.i(TAG, "restartVpnThread: Not restarting thread, could not find thread.");
            return;
        }

        vpnThread.stopThread();
        vpnThread.startThread();
    }


    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void stopVpnThread() {
        vpnThread.stopThread();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void waitForNetVpn() {
        stopVpnThread();
        updateVpnStatus(VPN_STATUS_WAITING_FOR_NETWORK);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void reconnect() {
        updateVpnStatus(VPN_STATUS_RECONNECTING);
        restartVpnThread();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void stopVpn() {
        Log.i(TAG, "Stopping Service");
        if (vpnThread != null)
            stopVpnThread();
        vpnThread = null;
        try {
            unregisterReceiver(connectivityChangedReceiver);
        } catch (IllegalArgumentException e) {
            Log.i(TAG, "Ignoring exception on unregistering receiver");
        }
        updateVpnStatus(VPN_STATUS_STOPPED);
        stopSelf();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void onDestroy() {
        Log.i(TAG, "Destroyed, shutting down");
        stopVpn();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public boolean handleMessage(Message message) {
        if (message == null) {
            return true;
        }

        switch (message.what) {
            case VPN_MSG_STATUS_UPDATE:
                updateVpnStatus(message.arg1);
                break;
            case VPN_MSG_NETWORK_CHANGED:
                connectivityChanged((Intent) message.obj);
                break;
            default:
                throw new IllegalArgumentException("Invalid message with what = " + message.what);
        }
        return true;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void connectivityChanged(Intent intent) {
        if (intent.getIntExtra(ConnectivityManager.EXTRA_NETWORK_TYPE, 0) == ConnectivityManager.TYPE_VPN) {
            Log.i(TAG, "Ignoring connectivity changed for our own network");
            return;
        }

        if (!ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
            Log.e(TAG, "Got bad intent on connectivity changed " + intent.getAction());
        }
        if (intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false)) {
            Log.i(TAG, "Connectivity changed to no connectivity, wait for a network");
            waitForNetVpn();
        } else {
            Log.i(TAG, "Network changed, try to reconnect");
            reconnect();
        }
    }

}