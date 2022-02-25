package io.privacy.anom;

import android.content.Context;
import android.os.Build;
import android.system.ErrnoException;
import android.system.Os;
import android.system.OsConstants;
import android.system.StructPollfd;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.io.Closeable;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Utility class for working with files.
 */

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public final class FileHelper {

    /**
     * Try open the file with {@link Context#openFileInput(String)}, falling back to a file of
     * the same name in the assets.
     */
    public static InputStream openRead(Context context, String filename) throws IOException {
        try {
            return context.openFileInput(filename);
        } catch (FileNotFoundException e) {
            return context.getAssets().open(filename);
        }
    }

    /**
     * Write to the given file in the private files dir, first renaming an old one to .bak
     *
     * @param context  A context
     * @param filename A filename as for @{link {@link Context#openFileOutput(String, int)}}
     * @return See @{link {@link Context#openFileOutput(String, int)}}
     * @throws IOException See @{link {@link Context#openFileOutput(String, int)}}
     */
    public static OutputStream openWrite(Context context, String filename) throws IOException {
        File out = context.getFileStreamPath(filename);

        // Create backup
        out.renameTo(context.getFileStreamPath(filename + ".bak"));

        return context.openFileOutput(filename, Context.MODE_PRIVATE);
    }

    private static Configuration readConfigFile(Context context, String name, boolean defaultsOnly) throws IOException {

        return new Configuration();
    }

//    public static Configuration loadCurrentSettings(Context context) {
//        try {
//            return readConfigFile(context, "settings.json", false);
//        } catch (Exception e) {
//            Toast.makeText(context, "Cannot get Config", Toast.LENGTH_LONG).show();
//            return loadPreviousSettings(context);
//        }
//    }
//
//    public static Configuration loadPreviousSettings(Context context) {
//        try {
//            return readConfigFile(context, "settings.json.bak", false);
//        } catch (Exception e) {
//            Toast.makeText(context,"Cannot restore Config", Toast.LENGTH_LONG).show();
//            return loadDefaultSettings(context);
//        }
//    }
//
//    public static Configuration loadDefaultSettings(Context context) {
//        try {
//            return readConfigFile(context, "settings.json", true);
//        } catch (Exception e) {
//            Toast.makeText(context, "Cannot Load Default Config", Toast.LENGTH_LONG).show();
//            return null;
//        }
//    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static int poll(StructPollfd[] fds, int timeout) throws ErrnoException, InterruptedException {
        while (true) {
            if (Thread.interrupted())
                throw new InterruptedException();
            try {
                return Os.poll(fds, timeout);
            } catch (ErrnoException e) {
                if (e.errno == OsConstants.EINTR)
                    continue;
                throw e;
            }
        }
    }

    public static FileDescriptor closeOrWarn(FileDescriptor fd, String tag, String message) {
        try {
            if (fd != null)
                Os.close(fd);
        } catch (ErrnoException e) {
            Log.e(tag, "closeOrWarn: " + message, e);
        } finally {
            return null;
        }
    }

    public static <T extends Closeable> T closeOrWarn(T fd, String tag, String message) {
        try {
            if (fd != null)
                fd.close();
        } catch (Exception e) {
            Log.e(tag, "closeOrWarn: " + message, e);
        } finally {
            return null;
        }
    }
}
