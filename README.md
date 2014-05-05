iBeaconGap
==========

Phonegap/Cordova plugin wrapper for Android SDK (https://github.com/RadiusNetworks/android-ibeacon-reference)

- Create PhoneGap app
- `phonegap local build android`
- `phonegap local plugin add https://github.com/TheMattRay/iBeaconGap.git`
- `phonegap local build android` (again)

Usage
==
```
  iBeaconGap.getBeacons(gotBeacons, failedGettingBeacons);
  
  function gotBeacons(beacons) {
    for(var i=0; i<beacons.length;i++) {
      var thisBeacon = beacons[i];
      
    }
  }
  
  function failedGettingBeacon(err) {
    console.log(err);
  }
```
