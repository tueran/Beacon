# Example of Geofencing.


## Installation

- Make sure that you have [Node](http://nodejs.org/) and [PhoneGap CLI](https://github.com/mwbrooks/phonegap-cli) installed on your machine.
- Create your PhoneGap example app

```bash
phonegap create com.siteforum.TestApp && cd $_
```

- Add the plugin to it

```bash
phonegap local plugin add https://github.com/tueran/Geofencing.git
```

## INCLUDED FUNTIONS

Geofencing.js contains the following functions:

    addRegion - Add a region to moitoring
    removeRegion - Remove a region from monitoring
    setHost - sets the Host form the call url from outside
    setToken - sets the user toker from outside
    startMonitoringRegion - Starts monitoring a region.
    stopMonitoringRegion - Clears an existing region from being monitored.
    getWatchedRegionIds - Returns a list of currently monitored region identifiers.
    startMonitoringSignificantLocationChanges - Starts monitoring significant location changes.
    stopMonitoringSignificantLocationChanges - Stops monitoring significant location changes.


## PLUGIN CODE EXAMPLE

To add a new region to be monitored use the Geofencing startMonitoringRegion function. The parameters are:

    fid - String - This is a unique identifier.
    latitude - String - latitude of the region.
    longitude - String - latitude of the region.
    radius - Integer - Specifies the radius in meters of the region.
    accuracy - Integer - Specifies the accuracy in meters.

Example:
```bash
var params = [location.id, location.location.lat, location.location.lng, "10", "3"];
Geofencing.startMonitoringRegion(params, function(result) {}, function(error) {
    alert("failed to add region");
});
```

To remove an existing region use the Geofencing removeRegion function. The parameters are: 1. fid - String - This is a unique identifier. 2. latitude - String - latitude of the region. 3. longitude - String - latitude of the region.

Example:
```bash
var params = [item.fid, item.latitude, item.longitude];
Geofencing.stopMonitoringRegion(params, 
function(result) {

    // not used.

}, function(error) {
    // not used
});
```


To retrieve the list of identifiers of currently monitored regions use the Geofencing getWatchedRegionIds function. No parameters.
The result object contains an array of strings in regionids

Example:

```bash
Geofencing.getWatchedRegionIds(
    function(result) { 
        alert("success: " + result.regionids);                 
    },
    function(error) {  
        alert("error");   
    }
);
```

To start monitoring signifaction location changes use the Geofencing startMonitoringSignificantLocationChanges function. No parameters.

Example:
```bash
Geofencing.startMonitoringSignificantLocationChanges(
    function(result) { 
        console.log("Location Monitor Success: " + result);                
    },
    function(error) {  
        console.log("failed to monitor location changes");   
    }
);
```

To start monitoring signifaction location changes use the Geofencing startMonitoringSignificantLocationChanges function. No parameters.

Example:
```bash
Geofencing.stopMonitoringSignificantLocationChanges(
    function(result) { 
        console.log("Stop Location Monitor Success: " + result);                   
    },
    function(error) {  
        console.log("failed to stop monitor location changes");   
    }
);
```



