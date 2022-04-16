package io.privacy.anom;



import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.VpnService;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.privacy.anom.vpn.AnomVPNService;

public class MainActivity extends FlutterActivity {
    private static final String Channel = "anom";
    final int REQUEST_START_VPN = 1;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        NotificationChannels.onCreate(this);
    }

    private void startService() {
        Log.i("Start", "Attempting to connect");
        Intent intent = VpnService.prepare(getContext());
        if (intent != null) {
            startActivityForResult(intent, 1);
        } else {
            onActivityResult(1, RESULT_OK, null);
        }
    }

    private boolean startStopService() {
        if (AnomVPNService.vpnStatus != AnomVPNService.VPN_STATUS_STOPPED) {
            Log.i("StartStop", "Attempting to disconnect");

            Intent intent = new Intent(getActivity(), AnomVPNService.class);
            intent.putExtra("COMMAND", AnomVPNService.Command.STOP.ordinal());
            getActivity().startService(intent);
        } else {
            startService();

        }
        return true;
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
    private void AnomwriteToFile(String data, Context context) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("blocklist", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }





    private void exportBin(byte[] data,String filename) throws IOException {
        File path = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOCUMENTS);
        try{

        File file = new File(path,filename);
        path.mkdirs();
        FileOutputStream outputStream = new FileOutputStream(file);
        outputStream.write(data);
        outputStream.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }




    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),Channel).setMethodCallHandler(
                (call,result) ->{

                    if(call.method.equals("privacy")){
                        String args = (String) call.arguments;
                        AnomwriteToFile(args,getContext());

                        startStopService();
                        result.success(null);
                    }
                    else if (call.method.equals("status")){
                        boolean out = AnomVPNService.vpnStatus == AnomVPNService.VPN_STATUS_RUNNING;
                        result.success(out);
                    }
                    else if (call.method.equals("export")){
                        try {
                            exportBin((byte[]) call.arguments,"password.sqlite3");
                            result.success(null);

                        } catch (IOException e) {
                            e.printStackTrace();
                            result.error("Export Operation Failed",null,null);

                        }
                    }

                    else{
                        result.notImplemented();

                    }
                }
        );
    }

}
