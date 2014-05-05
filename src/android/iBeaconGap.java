package com.thinketg.plugin.ibeacongap;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;

import android.util.Log;

import com.radiusnetworks.ibeacon.*;
import com.radiusnetworks.ibeacon.service.*;

import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
//import android.content.Intent;
//import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.Messenger;
import android.os.RemoteException;

public class iBeaconGap extends CordovaPlugin {

    protected static final String TAG = "iBeaconGap";
//    private CallbackContext startupCallbackContext;
    private CallbackContext callbackContext;
    
//    private RadiusReference myRadius;
    private Context appContext;
    
    private IBeaconManager ibm;
//    private Context appContext;
    
    private IBeaconService ibs;
    
    private ArrayList<IBeacon> myBeacons = new ArrayList<IBeacon>();
    
    private IBeaconConsumer myConsumer;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        appContext = this.cordova.getActivity().getApplicationContext();
        
        ibm = IBeaconManager.getInstanceForApplication(appContext);
        
        ibs = new IBeaconService();
        
        IBeaconManager.LOG_DEBUG = true;
        
        Log.d(TAG, "Availability:" + ibm.checkAvailability());
        
        ibm.setForegroundScanPeriod(2000);
        ibm.setForegroundBetweenScanPeriod(2000);
        
        ibm.setRangeNotifier(new RangeNotifier(){
            @Override
            public void didRangeBeaconsInRegion(Collection<IBeacon> beacons, Region region) {
                myBeacons.clear();
                myBeacons.addAll(beacons);
                Log.d(TAG, "didRangeBeaconsInRegion");
            }
        });
        
        myConsumer = new IBeaconConsumer() {
            @Override
            public boolean bindService(Intent arg0, ServiceConnection arg1, int arg2) {
                // TODO Auto-generated method stub
                ibs.bindService(arg0, arg1, arg2);
                return true;
            }

            @Override
            public Context getApplicationContext() {
                // TODO Auto-generated method stub
                return appContext;
            }

            @Override
            public void onIBeaconServiceConnect() {
                // TODO Auto-generated method stub
                try {
                    ibm.startRangingBeaconsInRegion(new Region("etg001", null, null, null));
                } catch (RemoteException e) {   
                    Log.d(TAG, e.getMessage());
                }
            }

            @Override
            public void unbindService(ServiceConnection arg0) {
                // TODO Auto-generated method stub
                
            }
        };
        
        ibm.bind(myConsumer);
        
        try {
            ibm.startRangingBeaconsInRegion(new Region("etg001", null, null, null));
        } catch (RemoteException e) {   
            Log.d(TAG, e.getMessage());
        }
        
        Log.d(TAG, "IBG: initializing.");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equalsIgnoreCase("getBeacons")) {
            // String message = args.getString(0);
            // this.getBeacons(callbackContext);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, listToJSONArray(myBeacons)));
            Log.d(TAG, "IBG: getBeacons.");
            return true;
        }
        return false;
    }

    protected void onCreate(Bundle savedInstanceState) {
        // iBeaconManager.bind(this);
    }

    private JSONArray listToJSONArray(Collection<IBeacon> beacons) throws JSONException{
        JSONArray jArray = new JSONArray();
        for (IBeacon beacon : beacons) {
            jArray.put(beaconToJSONObject(beacon));
        }
        return jArray;
    }

    private JSONObject beaconToJSONObject(IBeacon beacon) throws JSONException{
        JSONObject object = new JSONObject();        
        object.put("proximityUUID", beacon.getProximityUuid());
        object.put("major", beacon.getMajor());
        object.put("minor", beacon.getMinor());
        object.put("rssi", beacon.getRssi());
        object.put("macAddress", beacon.getBluetoothAddress());
        object.put("measuredPower", beacon.getTxPower());
        object.put("distance", beacon.getAccuracy());
        return object;
    }
}