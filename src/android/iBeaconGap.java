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

import android.app.Activity;
import android.content.Context;

public class iBeaconGap extends CordovaPlugin {

    protected static final String TAG = "iBeaconGap";
    private CallbackContext callbackContext;
    private Context appContext;
    private Activity appActivity;
    private BeaconUtils myUtil;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        appActivity = this.cordova.getActivity();
        appContext = appActivity.getApplicationContext();
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {               
                myUtil = new BeaconUtils(appActivity);
            }
        });
        
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equalsIgnoreCase("getBeacons")) {
            // String message = args.getString(0);
            // this.getBeacons(callbackContext);
            
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, listToJSONArray(myUtil.myBeacons)));
            Log.d(TAG, "IBG: getBeacons.");
            return true;
        }
        return false;
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