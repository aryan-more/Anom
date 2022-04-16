
package io.privacy.anom;

import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;

/**
 * Static class containing IDs of notification channels and code to create them.
 */
public class NotificationChannels {
    public static final String GROUP_SERVICE = "io.privacy.anom.notifications.service";
    public static final String SERVICE_RUNNING = "io.privacy.anom.notifications.service.running";
    public static final String SERVICE_PAUSED = "io.privacy.anom.notifications.service.paused";
    public static final String GROUP_UPDATE = "io.privacy.anom.notifications.update";
    public static final String UPDATE_STATUS = "io.privacy.anom.notifications.update.status";

    public static void onCreate(Context context) {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || notificationManager == null) {
            return;
        }

        notificationManager.createNotificationChannelGroup(new NotificationChannelGroup(GROUP_SERVICE, "Service"));
        notificationManager.createNotificationChannelGroup(new NotificationChannelGroup(GROUP_UPDATE, "Updates"));

        NotificationChannel runningChannel = new NotificationChannel(SERVICE_RUNNING, "Running service", NotificationManager.IMPORTANCE_MIN);
        runningChannel.setGroup(GROUP_SERVICE);
        runningChannel.setShowBadge(false);
        notificationManager.createNotificationChannel(runningChannel);

        NotificationChannel pausedChannel = new NotificationChannel(SERVICE_PAUSED, "Paused service", NotificationManager.IMPORTANCE_LOW);
        pausedChannel.setGroup(GROUP_SERVICE);
        pausedChannel.setShowBadge(false);
        notificationManager.createNotificationChannel(pausedChannel);

        NotificationChannel updateChannel = new NotificationChannel(UPDATE_STATUS, "Status", NotificationManager.IMPORTANCE_LOW);
        updateChannel.setGroup(GROUP_UPDATE);
        updateChannel.setShowBadge(false);
        notificationManager.createNotificationChannel(updateChannel);
    }
}
