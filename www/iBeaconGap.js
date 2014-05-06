var exec = require('cordova/exec');

exports.getBeacons = function(success, error) {
    exec(success, error, "iBeaconGap", "getBeacons", []);
};

exports.stopScanning = function() {
	var success = function(){};
	var error = function(){};
    exec(success, error, "iBeaconGap", "stopScanning", []);
};