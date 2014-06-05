
/**
 * Constructor
 */
function Beacon() {}

Beacon.prototype.addRegion = function(success, fail, params) {
  exec(success, fail, "Beacon", "addRegion", [params || {}]);
};

Beacon.prototype.removeRegion = function(success, fail, params) {
  exec(success, fail, "Beacon", "removeRegion", [params || {}]);
};
               
Beacon.prototype.setHost = function(success, fail, params) {
   exec(success, fail, "Beacon", "setHost", [params || {}]);
};
               
Beacon.prototype.setToken = function(success, fail, params) {
   exec(success, fail, "Beacon", "setToken", [params || {}]);
};

/*
Params:
NONE
*/
Beacon.prototype.getWatchedRegionIds = function(success, fail) {
  exec(success, fail, "Beacon", "getWatchedRegionIds", []);
};

/*
Params:
NONE
*/
Beacon.prototype.getPendingRegionUpdates = function(success, fail) {
  exec(success, fail, "Beacon", "getPendingRegionUpdates", []);
};

/*
Params:
NONE
*/
Beacon.prototype.startMonitoringSignificantLocationChanges = function(success, fail) {
  exec(success, fail, "Beacon", "startMonitoringSignificantLocationChanges", []);
};

/*
Params:
NONE
*/
Beacon.prototype.stopMonitoringSignificantLocationChanges = function(success, fail) {
  exec(success, fail, "Beacon", "stopMonitoringSignificantLocationChanges", []);
};

/*
This is used so the JavaScript can be updated when a region is entered or exited
*/
Beacon.prototype.regionMonitorUpdate = function(regionupdate) {
        console.log("regionMonitorUpdate: " + regionupdate);
        var ev = document.createEvent('HTMLEvents');
        ev.regionupdate = regionupdate;
        ev.initEvent('region-update', true, true, arguments);
        document.dispatchEvent(ev);
};

/*
This is used so the JavaScript can be updated when a significant change has occured
*/
Beacon.prototype.locationMonitorUpdate = function(locationupdate) {
        console.log("locationMonitorUpdate: " + locationupdate);
        var ev = document.createEvent('HTMLEvents');
        ev.locationupdate = locationupdate;
        ev.initEvent('location-update', true, true, arguments);
        document.dispatchEvent(ev);
};


// exports
var Beacon = new Beacon();
module.exports = Beacon;

