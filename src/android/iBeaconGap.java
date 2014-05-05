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

import com.radiusnetworks.ibeacon.IBeacon;
import com.radiusnetworks.ibeacon.IBeaconConsumer;
import com.radiusnetworks.ibeacon.IBeaconManager;
import com.radiusnetworks.ibeacon.Region;
import com.radiusnetworks.ibeacon.RangeNotifier;

//import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.RemoteException;

public class iBeaconGap extends CordovaPlugin implements IBeaconConsumer {

    protected static final String TAG = "iBeaconGap";
    private CallbackContext startupCallbackContext;
    private CallbackContext callbackContext;
    private IBeaconManager iBeaconManager;

    private ArrayList<IBeacon> myBeacons = new ArrayList<IBeacon>();

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        iBeaconManager = IBeaconManager.getInstanceForApplication(this.cordova.getActivity().getApplicationContext());

        iBeaconManager.bind(this);

        Log.d(TAG, "IBG: Done binding.");
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

    public void onDestroy() {        
        iBeaconManager.unBind(this);
    }

    protected void onPause() {
        if (iBeaconManager.isBound(this)) iBeaconManager.setBackgroundMode(this, true);         
    }

    protected void onResume() {
        if (iBeaconManager.isBound(this)) iBeaconManager.setBackgroundMode(this, false);            
    }

    @Override
    public void onIBeaconServiceConnect() {
        iBeaconManager.setRangeNotifier(new RangeNotifier() {
            @Override 
            public void didRangeBeaconsInRegion(Collection<IBeacon> iBeacons, Region region) {
                myBeacons.clear();
                // if (iBeacons.size() > 0) {
                myBeacons.addAll(iBeacons);
                Log.d(TAG, "IBG: didRangeBeaconsInRegion");
                    // EditText editText = (EditText)RangingActivity.this.findViewById(R.id.rangingText);
                    // logToDisplay("The first iBeacon I see is about "+iBeacons.iterator().next().getAccuracy()+" meters away.");             
                // }
            }
        });

        try {
            iBeaconManager.startRangingBeaconsInRegion(new Region("myRangingUniqueId", null, null, null));
        } catch (RemoteException e) {   }
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

    @Override
    public boolean bindService(Intent arg0, ServiceConnection arg1, int arg2) {
        // TODO Auto-generated method stub
        Log.d(TAG, "IBG: bindService");
        return super.bindService(arg0, arg1, arg2);
    }

    @Override
    public Context getApplicationContext() {
        // TODO Auto-generated method stub
        Log.d(TAG, "IBG: getapplicationContext");
        return super.getApplicationContext();
    }

    @Override
    public void unbindService(ServiceConnection arg0) {
        // TODO Auto-generated method stub
        super.unbindService(arg0);
        Log.d(TAG, "IBG: unbindService");
    }

}