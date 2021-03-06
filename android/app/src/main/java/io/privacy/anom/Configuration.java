
package io.privacy.anom;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;



import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;


public class Configuration {
    private static final String TAG = "Configuration";

    public boolean autoStart;
    public DnsServers dnsServers = new DnsServers();

    // Apologies for the legacy alternate
    public Allowlist allowlist = new Allowlist();
    public boolean watchDog = false;
    public boolean ipV6Support = true;


    public static class Item {
        public static final int STATE_ALLOW = 1;
        public String location;
        public int state;

        public boolean isDownloadable() {
            return location.startsWith("https://") || location.startsWith("http://");
        }
    }

    public static class Hosts {
        public boolean enabled;
        public boolean automaticRefresh = false;
        public List<Item> items = new ArrayList<>();
    }

    public static class DnsServers {
        public boolean enabled;
        public List<Item> items = new ArrayList<>();
    }

    public static class Allowlist {
        /**
         * All apps use the VPN.
         */
        public static final int DEFAULT_MODE_ON_VPN = 0;
        /**
         * No apps use the VPN.
         */
        public static final int DEFAULT_MODE_NOT_ON_VPN = 1;
        /**
         * System apps (excluding browsers) do not use the VPN.
         */
        public static final int DEFAULT_MODE_INTELLIGENT = 2;

        public boolean showSystemApps;
        /**
         * The default mode to put apps in, that are not listed in the lists.
         */
        public int defaultMode = DEFAULT_MODE_ON_VPN;
        /**
         * Apps that should not be allowed on the VPN
         */
        public List<String> items = new ArrayList<>();
        /**
         * Apps that should be on the VPN
         */
        public List<String> itemsOnVpn = new ArrayList<>();

        /**
         * Categorizes all packages in the system into "on vpn" or
         * "not on vpn".
         *
         * @param pm       A {@link PackageManager}
         * @param onVpn    names of packages to use the VPN
         * @param notOnVpn Names of packages not to use the VPN
         */
        public void resolve(PackageManager pm, Set<String> onVpn, Set<String> notOnVpn) {
            Set<String> webBrowserPackageNames = new HashSet<String>();
            List<ResolveInfo> resolveInfoList = pm.queryIntentActivities(newBrowserIntent(), 0);
            for (ResolveInfo resolveInfo : resolveInfoList) {
                webBrowserPackageNames.add(resolveInfo.activityInfo.packageName);
            }

            webBrowserPackageNames.add("com.google.android.webview");
            webBrowserPackageNames.add("com.android.htmlviewer");
            webBrowserPackageNames.add("com.google.android.backuptransport");
            webBrowserPackageNames.add("com.google.android.gms");
            webBrowserPackageNames.add("com.google.android.gsf");

            for (ApplicationInfo applicationInfo : pm.getInstalledApplications(0)) {
                // We need to always keep ourselves using the VPN, otherwise our
                // watchdog does not work.
                if (applicationInfo.packageName.equals(BuildConfig.APPLICATION_ID)) {
                    onVpn.add(applicationInfo.packageName);
                } else if (itemsOnVpn.contains(applicationInfo.packageName)) {
                    onVpn.add(applicationInfo.packageName);
                } else if (items.contains(applicationInfo.packageName)) {
                    notOnVpn.add(applicationInfo.packageName);
                } else if (defaultMode == DEFAULT_MODE_ON_VPN) {
                    onVpn.add(applicationInfo.packageName);
                } else if (defaultMode == DEFAULT_MODE_NOT_ON_VPN) {
                    notOnVpn.add(applicationInfo.packageName);
                } else if (defaultMode == DEFAULT_MODE_INTELLIGENT) {
                    if (webBrowserPackageNames.contains(applicationInfo.packageName))
                        onVpn.add(applicationInfo.packageName);
                    else if ((applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM) != 0)
                        notOnVpn.add(applicationInfo.packageName);
                    else
                        onVpn.add(applicationInfo.packageName);
                }
            }
        }

        /**
         * Returns an intent for opening a website, used for finding
         * web browsers. Extracted method for mocking.
         */
        Intent newBrowserIntent() {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse("https://isabrowser.dns66.jak-linux.org/"));
            return intent;
        }
    }
}
