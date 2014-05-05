var exec = require('cordova/exec');

exports.getBeacons = function(success, error) {
    exec(success, error, "iBeaconGap", "getBeacons", []);
};