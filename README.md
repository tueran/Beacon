# Example of Beacon.


## Installation

- Make sure that you have [Node](http://nodejs.org/) and [PhoneGap CLI](https://github.com/mwbrooks/phonegap-cli) installed on your machine.
- Create your PhoneGap/Cordova example app

```bash
phonegap create com.siteforum.beacon && cd $_
cordova create com.siteforum.beacon && cd $_
```

- Add the plugin to it

```bash
cordova plugin add https://github.com/tueran/Beacon
```

- Add to AppDelegate.m
```bash
#import <EstimoteSDK/EstimoteSDK.h>
#import "Beacon.h"

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    ......

    [[Beacon sharedManager] start];
}

```

- Add to ViewController.h
```bash
#import <EstimoteSDK/EstimoteSDK.h>

@interface MainViewController : CDVViewController <ESTBeaconManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLBeacon *beacon;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@end
```

- Add to ViewController.m
```bash
#import "Beacon.h"

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[Beacon sharedManager] setDelegate:self];   
}
```

## INCLUDED FUNTIONS

Beacon.js contains the following functions:

    addBeacon - Add a region to moitoring
    removeBeacon - Remove a region from monitoring
    setHost - sets the Host form the call url from outside
    setToken - sets the user toker from outside
    getWatchedBeaconIds - Returns a list of currently monitored region identifiers.
    


## PLUGIN CODE EXAMPLE

To add a new region to be monitored use the Beacon Beacon.addRegion function. The parameters are:

    bid - String - This is a unique identifier.
    puuid - String - proximity UUID
    major - int - latitude of the region.
    minor - int - Specifies the radius in meters of the region.
    

<strong>Example: addBeacon</strong>
```bash
Beacon.addBeacon(function(){
                             alert('success');
                             }, function(){
                             alert('error');
                             }, {
                             bid: 1234567890,
                             puuid: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
                             major: 11111,
                             minor: 23456
                             });

```

To remove an existing region use the Beacon removeRegion function. The parameters are: 

    bid - String - This is a unique identifier.
    puuid - String - proximity UUID
    major - int - latitude of the region.
    minor - int - Specifies the radius in meters of the region.

<strong>Example: removeBeacon</strong>
```bash
Beacon.removeBeacon(function(){
                             alert('success');
                             }, function(){
                             alert('error');
                             }, 
                             1234567890
                             );
```


To retrieve the list of identifiers of currently monitored regions use the Beacon getWatchedRegionIds function. No parameters.
The result object contains an array of strings in regionids

<strong>Example: getWatchedBeaconIds (Beacon)</strong>
```bash
Beacon.getWatchedBeaconIds(
                             function(result) {
                             alert("success: " + result);
                             },
                             function(error) {
                             alert("error");
                             });

```

To set the host for the callback url use Beacon setHost. It works only with https://

<strong>Example: setHost (Beacon)</strong>
```bash
Beacon.setHost(function(success){}, function(error){}, 'myfavorito.com');

```


To set the token for the callback url use Beacon setToken. It works only with https://

<strong>Example: setToken (Beacon)</strong>
```bash
Beacon.setToken(function(success){}, function(error){}, 'hkja8z8klahkjh899842kljah');

```


