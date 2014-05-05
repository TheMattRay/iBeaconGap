package com.thinketg.plugin.ibeacongap;

import java.util.ArrayList;
import java.util.Collection;

import com.radiusnetworks.ibeacon.IBeacon;
import com.radiusnetworks.ibeacon.IBeaconConsumer;
import com.radiusnetworks.ibeacon.IBeaconManager;
import com.radiusnetworks.ibeacon.Region;
import com.radiusnetworks.ibeacon.RangeNotifier;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.RemoteException;
import android.speech.RecognizerIntent;

public class RadiusReference extends Activity implements IBeaconConsumer {
    protected static final String TAG = "RangingActivity";
    private IBeaconManager iBeaconManager;// = IBeaconManager.getInstanceForApplication(this);
    
    public ArrayList<IBeacon> myBeacons = new ArrayList<IBeacon>();
    
    private Context thisContext;
    
    public RadiusReference(Context appContext) {
        thisContext = appContext;
        iBeaconManager.getInstanceForApplication(appContext);
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        iBeaconManager.bind(this);
    }
    @Override 
    protected void onDestroy() {
        super.onDestroy();
        iBeaconManager.unBind(this);
    }
    @Override 
    protected void onPause() {
        super.onPause();
        if (iBeaconManager.isBound(this)) iBeaconManager.setBackgroundMode(this, true);         
    }
    @Override 
    protected void onResume() {
        super.onResume();
        if (iBeaconManager.isBound(this)) iBeaconManager.setBackgroundMode(this, false);            
    }

    @Override
    public void onIBeaconServiceConnect() {
        iBeaconManager.setRangeNotifier(new RangeNotifier() {
        @Override 
        public void didRangeBeaconsInRegion(Collection<IBeacon> iBeacons, Region region) {
            refreshSet(iBeacons);
        }

        });

        try {
            iBeaconManager.startRangingBeaconsInRegion(new Region("myRangingUniqueId", null, null, null));
        } catch (RemoteException e) {   }
    }
    private void refreshSet(final Collection<IBeacon> beacons) {
        runOnUiThread(new Runnable() {
            public void run() {
                myBeacons.clear();
                myBeacons.addAll(beacons);
            }
        });
    }
}