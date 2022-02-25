package io.privacy.anom.blocklist;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashSet;
import java.util.Scanner;

public class BlockListDB {
    private static final BlockListDB instance = new BlockListDB();
    final HashSet<String> blockList = new HashSet<String>();

    public static BlockListDB getInstance() {
        return instance;
    }

    public boolean isBlocked(String domain) {
        return blockList.contains(domain);
    }

    public void initialize(Context context) {
        this.blockList.clear();
        try{
            InputStream inputStream = context.openFileInput("blocklist");
            if (inputStream != null){
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String site = "";
                while ( (site = bufferedReader.readLine()) != null ) {
                    blockList.add(site);
                }
                inputStream.close();
            }

        }
        catch (IOException e){

        }

    }
}
