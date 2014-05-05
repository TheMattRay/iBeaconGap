package com.thinketg.plugin.ibeacongap;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collection;

import com.radiusnetworks.ibeacon.IBeacon;
import com.radiusnetworks.ibeacon.IBeaconConsumer;
import com.radiusnetworks.ibeacon.IBeaconManager;
import com.radiusnetworks.ibeacon.Region;
import com.radiusnetworks.ibeacon.RangeNotifier;

import android.app.Activity;

import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;
import android.widget.EditText;

/**
 * This class echoes a string called from JavaScript.
 */
public class iBeaconGap extends CordovaPlugin implements IBeaconConsumer {

    protected static final String TAG = "RangingActivity";
    private CallbackContext startupCallbackContext;
    private CallbackContext callbackContext;
    private IBeaconManager iBeaconManager;

    private Collection<IBeacon> myBeacons = new Collection<IBeacon>();

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        iBeaconManager = IBeaconManager.getInstanceForApplication(this.cordova.getActivity().getApplicationContext());

        iBeaconManager.bind(this);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equalsIgnoreCase("getBeacons")) {
            // String message = args.getString(0);
            // this.getBeacons(callbackContext);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, listToJSONArray(myBeacons)));
            return true;
        }
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // iBeaconManager.bind(this);
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
                myBeacons.clear();
                // if (iBeacons.size() > 0) {
                myBeacons.addAll(iBeacons);
                    // EditText editText = (EditText)RangingActivity.this.findViewById(R.id.rangingText);
                    // logToDisplay("The first iBeacon I see is about "+iBeacons.iterator().next().getAccuracy()+" meters away.");             
                // }
            }
        });

        try {
            iBeaconManager.startRangingBeaconsInRegion(new Region("myRangingUniqueId", null, null, null));
        } catch (RemoteException e) {   }
    }

    private JSONArray listToJSONArray(Collection<Beacon> beacons) throws JSONException{
        JSONArray jArray = new JSONArray();
        for (Beacon beacon : beacons) {
            jArray.put(beaconToJSONObject(beacon));
        }
        return jArray;
    }

    // private void logToDisplay(final String line) {
    //     runOnUiThread(new Runnable() {
    //         public void run() {
    //             EditText editText = (EditText)RangingActivity.this
    //                     .findViewById(R.id.rangingText);
    //             editText.append(line+"\n");             
    //         }
    //     });
    // }
}
