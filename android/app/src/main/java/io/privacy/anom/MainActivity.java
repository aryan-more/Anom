package io.privacy.anom;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.net.VpnService;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.io.BufferedReader;
import java.io.FileDescriptor;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.util.List;

import io.flutter.FlutterInjector;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMethodCodec;
import io.privacy.anom.vpn.AnomVPNService;

public class MainActivity extends FlutterActivity {
    private static final String Channel = "anom";
    final int REQUEST_START_VPN = 1;

    private void startService() {
        Log.i("Start", "Attempting to connect");
        Intent intent = VpnService.prepare(getContext());
        if (intent != null) {
            startActivityForResult(intent, 1);
        } else {
            onActivityResult(1, RESULT_OK, null);
        }
    }

    private boolean VpnStatus() {
        return AnomVPNService.vpnStatus == AnomVPNService.VPN_STATUS_RUNNING;
    }

    private void startStopService() {
        if (AnomVPNService.vpnStatus != AnomVPNService.VPN_STATUS_STOPPED) {
            Log.i("StartStop", "Attempting to disconnect");
            Intent intent = new Intent(getActivity(), AnomVPNService.class);
            intent.putExtra("COMMAND", AnomVPNService.Command.STOP.ordinal());
            getActivity().startService(intent);
        } else {
            startService();

        }
    }

    private void writeToFile(String data, Context context) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("blocklist", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        final String TAG = "OnActivity";
        Log.d(TAG, "onActivityResult: Received result=" + resultCode + " for request=" + requestCode);
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_START_VPN && resultCode == RESULT_CANCELED) {
            Toast.makeText(getContext(), "Config Failed", Toast.LENGTH_LONG).show();
        }
        if (requestCode == REQUEST_START_VPN && resultCode == RESULT_OK) {
            Log.d("MainActivity", "onActivityResult: Starting service");
            Intent intent = new Intent(getContext(), AnomVPNService.class);
            intent.putExtra("COMMAND", AnomVPNService.Command.START.ordinal());
            intent.putExtra("NOTIFICATION_INTENT",
                    PendingIntent.getActivity(getContext(), 0,
                            new Intent(getContext(), MainActivity.class), 0));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                getContext().startForegroundService(intent);
            } else {
                getContext().startService(intent);
            }

        }
    }
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        AssetManager manager =  getAssets();



        BinaryMessenger.TaskQueue queue = messenger.makeBackgroundTaskQueue();
        new MethodChannel(messenger, Channel, StandardMethodCodec.INSTANCE, queue)
                .setMethodCallHandler(
                        (call, result) -> {
                            try {
                                if (call.method.equals("privacy")) {
                                        String args = (String) call.arguments;
                                        writeToFile(args,getContext());
                                        startStopService();
                                        result.success(null);

                                } else if (call.method.equals("vpn")) {
                                    result.success(VpnStatus());
                                } else {
                                    result.notImplemented();
                                }

                            } catch (Exception e) {
                                result.error("",e.toString(),"Method Channel Failed");

                            }
                        });
    }

}
