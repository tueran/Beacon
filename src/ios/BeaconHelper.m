//
//  BeaconHelper.m
//  Beacon
//
//  Created by Daniel Mauer on 26.06.14.
//
//

#import "BeaconHelper.h"


static BeaconHelper *sharedBeaconHelper = nil;

#pragma mark - LocationData Implementation

@implementation LocationData

@synthesize locationStatus, locationInfo;
@synthesize locationCallbacks;
//@synthesize geofenceCallbacks;

@synthesize beaconCallbacks;

-(LocationData*) init
{
    self = (LocationData*)[super init];
    if (self) {
        self.locationInfo = nil;
    }
    return self;
}

@end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - BeaconHelper Implementation
@implementation BeaconHelper

@synthesize webView;
@synthesize locationManager;
@synthesize beaconRegion;
@synthesize locationData;
@synthesize didLaunchForRegionUpdate;
@synthesize commandDelegate;


/*
 -(void)saveGeofenceCallbackId:(NSString *)callbackId
 {
 if (!self.locationData) {
 self.locationData = [[LocationData alloc] init];
 }
 
 LocationData* lData = self.locationData;
 if (!lData.geofenceCallbacks) {
 lData.geofenceCallbacks = [NSMutableArray array];
 }
 
 // add the callbackId into the array so we can call back when get data
 [lData.geofenceCallbacks enqueue:callbackId];
 }
 */
-(void)saveLocationCallbackId:(NSString *)callbackId
{
    if (!self.locationData) {
        self.locationData = [[LocationData alloc] init];
    }
    
    LocationData* lData = self.locationData;
    if (!lData.locationCallbacks) {
        lData.locationCallbacks = [NSMutableArray array];
    }
    
    // add the callbackId into the array so we cann call back when get data
    [lData.locationCallbacks enqueue:callbackId];
}


#pragma mark - location Manager

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [posError setObject: [NSNumber numberWithInt: error.code] forKey:@"code"];
    [posError setObject: region.identifier forKey: @"regionid"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.beaconCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    self.locationData.beaconCallbacks = [NSMutableArray array];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: error.code] forKey:@"code"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    self.locationData.locationCallbacks = [NSMutableArray array];
}

- (void) returnRegionSuccess; {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.beaconCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    self.locationData.beaconCallbacks = [NSMutableArray array];
}


- (void) returnLocationSuccess; {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString* callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    
    
    self.locationData.locationCallbacks = [NSMutableArray array];
}


- (void) returnLocationError: (NSUInteger) errorCode withMessage: (NSString*) message
{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: errorCode] forKey:@"code"];
    [posError setObject: message ? message : @"" forKey: @"message"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    
    self.locationData.locationCallbacks = [NSMutableArray array];
}


- (id) init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
        self.locationData = nil;
        
    }
    return self;
}

+(BeaconHelper *)sharedBeaconHelper
{
    //objects using shard instance are responsible for retain/release count
    //retain count must remain 1 to stay in mem
    
    if (!sharedBeaconHelper)
    {
        sharedBeaconHelper = [[BeaconHelper alloc] init];
    }
    
    return sharedBeaconHelper;
}


+ (NSString*) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}



#pragma mark - iBeacon

-(void)saveBeaconCallbackId:(NSString *)callbackId
{
    if (!self.locationData) {
        self.locationData = [[LocationData alloc] init];
    }
    
    LocationData* lData = self.locationData;
    if (!lData.beaconCallbacks) {
        lData.beaconCallbacks = [NSMutableArray array];
    }
    
    // add the callbackId into the array so we can call back when get data
    [lData.beaconCallbacks enqueue:callbackId];
}


- (void) returnBeaconRegionSuccess; {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"BeaconRegion Success" forKey: @"message"];
    
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.beaconCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    self.locationData.beaconCallbacks = [NSMutableArray array];
}



- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    // Load the storage data from nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *getHost = [preferences stringForKey:@"BeaconHost"];
    NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
    NSLog(@"nsuserdefaults Ausgabe: %@", getHost);
    
    
    NSLog(@"Enter Region with beacon: %@", region.identifier);
    
    NSLog(@"----> Beacon Region: %@", beaconRegion);
    NSLog(@"----> Beacon Region with region: %@", region);
    NSLog(@"Beacon sharedBeaconHelper: %@", [BeaconHelper sharedBeaconHelper]);
    NSLog(@"Beacon sharedBeaconHelper Locationmanager: %@", [[BeaconHelper sharedBeaconHelper] locationManager]);
    //  [[[GeofencingHelper sharedGeofencingHelper] locationManager] startRangingBeaconsInRegion:region];
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegionNew = (CLBeaconRegion *)region;
        
        NSLog(@"Passt ------- OK");
        NSLog(@"New CLBeaconRegion: %@", beaconRegionNew);
        [self.locationManager startRangingBeaconsInRegion:beaconRegionNew];
    }
    
    CLBeaconRegion *beaconRegionNew2 = (CLBeaconRegion *)region;
    [[[BeaconHelper sharedBeaconHelper] locationManager] startRangingBeaconsInRegion:beaconRegionNew2];
    
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    /*
     if (self.didLaunchForRegionUpdate) {
     NSString *path = [GeofencingHelper applicationDocumentsDirectory];
     NSString *finalPath = [path stringByAppendingPathComponent:@"notifications.txt"];
     NSMutableArray *updates = [NSMutableArray arrayWithContentsOfFile:finalPath];
     
     if (!updates) {
     updates = [NSMutableArray array];
     }
     
     NSMutableDictionary *update = [NSMutableDictionary dictionary];
     
     [update setObject:region.identifier forKey:@"fid"];
     [update setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
     [update setObject:@"left" forKey:@"status"];
     
     [updates addObject:update];
     
     [updates writeToFile:finalPath atomically:YES];
     
     
     
     
     
     } else {
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
     [dict setObject:@"left" forKey:@"status"];
     [dict setObject:region.identifier forKey:@"fid"];
     NSString *jsStatement = [NSString stringWithFormat:@"Geofencing.regionMonitorUpdate(%@);", [dict JSONString]];
     [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
     
     
     // Remove for GoLive and change it
     
     NSString *path = [GeofencingHelper applicationDocumentsDirectory];
     NSString *finalPath2 = [path stringByAppendingPathComponent:@"siteforum_geofencing.txt"];
     
     NSMutableArray *dicts = [NSMutableArray arrayWithContentsOfFile:finalPath2];
     
     if (!dicts) {
     dicts = [NSMutableArray array];
     }
     
     [dicts addObject:dict];
     [dicts writeToFile:finalPath2 atomically:YES];
     
     }
     
     
     
     // Load the storage data from nsuserdefaults
     NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
     NSString *getHost = [preferences stringForKey:@"GeofencingHost"];
     NSString *getUsertoken = [preferences stringForKey:@"Usertoken"];
     NSLog(@"nsuserdefaults Ausgabe: %@", getHost);
     
     // NSURL Request
     NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/regions/%@/exit?s=&token=%@", getHost, region.identifier, getUsertoken];
     //NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/daniel/%@/exit?s=&token=%@", getHost, region.identifier, getUsertoken];
     NSURL* sfUrl = [NSURL URLWithString:geofencingUrl];
     NSLog(@"URL: %@", sfUrl);
     
     // set the request
     NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
     NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
     __block NSUInteger tries = 0;
     
     typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
     __block CompletionBlock completionHandler = nil;
     
     // Block to start the request
     dispatch_block_t enqueueBlock = ^{
     [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
     };
     
     completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
     tries++;
     if (sfError) {
     if (tries < 3) {
     enqueueBlock();
     NSLog(@"Error: %@", sfError);
     } else {
     NSLog(@"Abbruch nach 3 Versuchen.");
     }
     } else {
     NSString* myResponse;
     myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
     NSLog(@"Response: %@", myResponse);
     
     NSLog(@"----------------------------------------------------------");
     NSLog(@"----->  E X I T   R E G I O N   C O N D I T I O N   <-----");
     NSLog(@"----------------------------------------------------------");
     }
     };
     
     enqueueBlock();
     
     */
    
    NSLog(@"Exit Region");
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegionNew = (CLBeaconRegion *)region;
        [self.locationManager stopRangingBeaconsInRegion:beaconRegionNew];
        NSLog(@"No more beaconRanging");
    }
    
    /*
     NSDate *alertTime = [[NSDate date]
     dateByAddingTimeInterval:1];
     UIApplication* app = [UIApplication sharedApplication];
     UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
     init];
     if (notifyAlarm)
     {
     notifyAlarm.fireDate = alertTime;
     notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
     notifyAlarm.repeatInterval = 0;
     //notifyAlarm.soundName = @"bell_tree.mp3";
     notifyAlarm.alertBody = [NSString stringWithFormat:@"You left Region %@", region.identifier];
     [app scheduleLocalNotification:notifyAlarm];
     }
     */
    
}


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"didRangeBeacons");
    NSLog(@"all beacons: %lu", (unsigned long)[beacons count]);
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    NSLog(@"Beacons ProximityUUID: %@", beacon.proximityUUID);
    //  NSLog(@"Beacons Major: %@", beacon.major);
    //  NSLog(@"Beacons Minor: %@", beacon.minor);
    
    NSLog(@"----> Beacons: %@", beacons);
    //NSLog(@"alle gefundenen Beacons: %@ \n Beacons count: %lu", beacons, (unsigned long)[beacons count] );
    
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Count: %d", beacons.count);
        NSLog(@"Ranging beacon: %@", beacon.proximityUUID);
        NSLog(@"%@ - %@", beacon.major, beacon.minor);
        NSLog(@"Range: %@", [self stringForProximity:beacon.proximity]);
        NSLog(@"==========================================================");
        
        NSLog(@"----------------------------------------");
        NSLog(@"--------------PROXIMITY-----------------");
        NSLog(@"----------------------------------------");
        if (beacon.proximity == CLProximityUnknown) {
            NSLog(@"Proximity: Unknown: %d", beacon.proximity);
            
            // Load the storage data from nsuserdefaults
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            NSString *getHost = [preferences stringForKey:@"BeaconHost"];
            NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
            NSLog(@"nsuserdefaultsgetHost: %@", getHost);
            
            NSString* beaconUrl = [NSString stringWithFormat:@"https://%@/sf/daniel_beacons/%@/away?s=&token=%@", getHost, region.identifier, getUsertoken];
            NSURL* sfUrl = [NSURL URLWithString:beaconUrl];
            NSLog(@"URL: %@", sfUrl);
            // set the request
            NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
            NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
            __block NSUInteger tries = 0;
            
            typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
            __block CompletionBlock completionHandler = nil;
            
            // Block to start the request
            dispatch_block_t enqueueBlock = ^{
                [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
            };
            
            completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
                tries++;
                if (sfError) {
                    if (tries < 3) {
                        enqueueBlock();
                        NSLog(@"Error: %@", sfError);
                    } else {
                        NSLog(@"Abbruch nach 3 Versuchen.");
                    }
                } else {
                    NSString* myResponse;
                    myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
                }
            };
            
            NSDate *entryDate = [NSDate date];
            NSLog(@"Date: %@", entryDate);
            NSDate *entryDateIntervall = [[NSDate date] dateByAddingTimeInterval:3];
            NSLog(@"DateIntervall: %@", entryDateIntervall);
            
            //enqueueBlock();
            
            // Load NSUserDefaults
            NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
            
            NSLog(@"nsuserdefaults date Ausgabe: %@", savedDate);
            
            // if savedDate = nil set current time + 5 minutes
            if (savedDate == nil) {
                NSLog(@"No entry found");
                NSDate *dateNow = [NSDate date];
                NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                // Save the timer into ne nsuserdefaults
                NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                [setBeaconTimers synchronize]; //at the end of storage
            }
            
            // compare current date and saved date
            NSDate *dateNow = [NSDate date];
            switch ([dateNow compare:savedDate]){
                case NSOrderedAscending:
                    NSLog(@"NSOrderedAscending");
                    NSLog(@"Time is into the future");
                    
                    
                    break;
                case NSOrderedSame:
                    NSLog(@"NSOrderedSame");
                    break;
                case NSOrderedDescending:
                    NSLog(@"NSOrderedDescending");
                    NSLog(@"Date is in past");
                    
                    NSDate *dateNow = [NSDate date];
                    NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                    // Save the timer into ne nsuserdefaults
                    NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                    [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                    [setBeaconTimers synchronize]; //at the end of storage
                    
                    enqueueBlock();
                    
                    break;
            }
            
            
            
        } else if (beacon.proximity == CLProximityImmediate) {
            NSLog(@"Proximity: Immediate: %d", beacon.proximity);
            
            // Load the storage data from nsuserdefaults
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            NSString *getHost = [preferences stringForKey:@"BeaconHost"];
            NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
            NSLog(@"nsuserdefaultsgetHost: %@", getHost);
            
            NSString* beaconUrl = [NSString stringWithFormat:@"https://%@/sf/daniel_beacons/%@/immediate?s=&token=%@", getHost, region.identifier, getUsertoken];
            NSURL* sfUrl = [NSURL URLWithString:beaconUrl];
            NSLog(@"URL: %@", sfUrl);
            // set the request
            NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
            NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
            __block NSUInteger tries = 0;
            
            typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
            __block CompletionBlock completionHandler = nil;
            
            // Block to start the request
            dispatch_block_t enqueueBlock = ^{
                [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
            };
            
            completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
                tries++;
                if (sfError) {
                    if (tries < 3) {
                        enqueueBlock();
                        NSLog(@"Error: %@", sfError);
                    } else {
                        NSLog(@"Abbruch nach 3 Versuchen.");
                    }
                } else {
                    NSString* myResponse;
                    myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
                }
            };
            
            //[NSTimer scheduledTimerWithTimeInterval:.06 target:self selector:@selector(goToSecondButton:) userInfo:nil repeats:NO];
            
            //enqueueBlock();
            
            // Load NSUserDefaults
            NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
            
            NSLog(@"nsuserdefaults date Ausgabe: %@", savedDate);
            
            // if savedDate = nil set current time + 5 minutes
            if (savedDate == nil) {
                NSLog(@"No entry found");
                NSDate *dateNow = [NSDate date];
                NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                // Save the timer into ne nsuserdefaults
                NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                [setBeaconTimers synchronize]; //at the end of storage
                
                enqueueBlock();
            }
            
            // compare current date and saved date
            NSDate *dateNow = [NSDate date];
            switch ([dateNow compare:savedDate]){
                case NSOrderedAscending:
                    NSLog(@"NSOrderedAscending");
                    NSLog(@"Time is into the future");
                    
                    
                    break;
                case NSOrderedSame:
                    NSLog(@"NSOrderedSame");
                    break;
                case NSOrderedDescending:
                    NSLog(@"NSOrderedDescending");
                    NSLog(@"Date is in past");
                    
                    NSDate *dateNow = [NSDate date];
                    NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                    // Save the timer into ne nsuserdefaults
                    NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                    [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                    [setBeaconTimers synchronize]; //at the end of storage
                    
                    enqueueBlock();
                    
                    break;
            }
            
            
        } else if (beacon.proximity == CLProximityNear) {
            NSLog(@"Proximity: Near: %d", beacon.proximity);
            
            // Load the storage data from nsuserdefaults
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            NSString *getHost = [preferences stringForKey:@"BeaconHost"];
            NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
            NSLog(@"nsuserdefaultsgetHost: %@", getHost);
            
            NSString* beaconUrl = [NSString stringWithFormat:@"https://%@/sf/daniel_beacons/%@/near?s=&token=%@", getHost, region.identifier, getUsertoken];
            NSURL* sfUrl = [NSURL URLWithString:beaconUrl];
            NSLog(@"URL: %@", sfUrl);
            // set the request
            NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
            NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
            __block NSUInteger tries = 0;
            
            typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
            __block CompletionBlock completionHandler = nil;
            
            // Block to start the request
            dispatch_block_t enqueueBlock = ^{
                [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
            };
            
            completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
                tries++;
                if (sfError) {
                    if (tries < 3) {
                        enqueueBlock();
                        NSLog(@"Error: %@", sfError);
                    } else {
                        NSLog(@"Abbruch nach 3 Versuchen.");
                    }
                } else {
                    NSString* myResponse;
                    myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
                }
            };
            
            //enqueueBlock();
            
            // Load NSUserDefaults
            NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
            
            NSLog(@"nsuserdefaults date Ausgabe: %@", savedDate);
            
            // if savedDate = nil set current time + 5 minutes
            if (savedDate == nil) {
                NSLog(@"No entry found");
                NSDate *dateNow = [NSDate date];
                NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                // Save the timer into ne nsuserdefaults
                NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                [setBeaconTimers synchronize]; //at the end of storage
                
                enqueueBlock();
            }
            
            // compare current date and saved date
            NSDate *dateNow = [NSDate date];
            switch ([dateNow compare:savedDate]){
                case NSOrderedAscending:
                    NSLog(@"NSOrderedAscending");
                    NSLog(@"Time is into the future");
                    
                    
                    break;
                case NSOrderedSame:
                    NSLog(@"NSOrderedSame");
                    break;
                case NSOrderedDescending:
                    NSLog(@"NSOrderedDescending");
                    NSLog(@"Date is in past");
                    
                    NSDate *dateNow = [NSDate date];
                    NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                    // Save the timer into ne nsuserdefaults
                    NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                    [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                    [setBeaconTimers synchronize]; //at the end of storage
                    
                    enqueueBlock();
                    
                    break;
            }
            
            
            
        } else if (beacon.proximity == CLProximityFar) {
            NSLog(@"Proximity: Far: %d", beacon.proximity);
            
            
            // Load the storage data from nsuserdefaults
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            NSString *getHost = [preferences stringForKey:@"BeaconHost"];
            NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
            NSLog(@"nsuserdefaultsgetHost: %@", getHost);
            
            // Build url to call
            NSString* beaconUrl = [NSString stringWithFormat:@"https://%@/sf/daniel_beacons/%@/far?s=&token=%@", getHost, region.identifier, getUsertoken];
            //"https://" + host + "/sf/beacons/" + id + "/" + proximity + "?s=&token=" + token;
            NSURL* sfUrl = [NSURL URLWithString:beaconUrl];
            NSLog(@"URL: %@", sfUrl);
            // set the request
            NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
            NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
            __block NSUInteger tries = 0;
            
            typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
            __block CompletionBlock completionHandler = nil;
            
            // Block to start the request
            dispatch_block_t enqueueBlock = ^{
                [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
            };
            
            completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
                tries++;
                if (sfError) {
                    if (tries < 3) {
                        enqueueBlock();
                        NSLog(@"Error: %@", sfError);
                    } else {
                        NSLog(@"Abbruch nach 3 Versuchen.");
                    }
                } else {
                    NSString* myResponse;
                    myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
                    NSLog(@"Response: %@", myResponse);
                    
                }
            };
            
            //enqueueBlock();
            
            NSDate *entryDate = [NSDate date];
            NSLog(@"Date: %@", entryDate);
            NSDate *entryDateIntervall = [[NSDate date] dateByAddingTimeInterval:300];
            NSLog(@"DateIntervall: %@", entryDateIntervall);
            
            
            
            NSDate *dateNow = [NSDate date];
            NSDate *dateSaved = [dateNow dateByAddingTimeInterval:300];
            
            NSLog(@"Date Now: %@", dateNow);
            NSLog(@"Date Three: dateOne + 5 minutes: %@", dateSaved);
            NSLog(@"Region.identifier: %@", region.identifier);
            
            
            // Load NSUserDefaults
            NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
            
            NSLog(@"nsuserdefaults date Ausgabe: %@", savedDate);
            
            // if savedDate = nil set current time + 5 minutes
            if (savedDate == nil) {
                NSLog(@"No entry found");
                NSDate *dateNow = [NSDate date];
                NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                // Save the timer into ne nsuserdefaults
                NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                [setBeaconTimers synchronize]; //at the end of storage
                
                enqueueBlock();
            }
            
            // compare current date and saved date
            switch ([dateNow compare:savedDate]){
                case NSOrderedAscending:
                    NSLog(@"NSOrderedAscending");
                    NSLog(@"Time is into the future");
                    
                    
                    break;
                case NSOrderedSame:
                    NSLog(@"NSOrderedSame");
                    break;
                case NSOrderedDescending:
                    NSLog(@"NSOrderedDescending");
                    NSLog(@"Date is in past");
                    
                    NSDate *dateNow = [NSDate date];
                    NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
                    // Save the timer into ne nsuserdefaults
                    NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
                    [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", region.identifier, [self stringForProximity:beacon.proximity]]];
                    [setBeaconTimers synchronize]; //at the end of storage
                    
                    enqueueBlock();
                    
                    break;
            }
            
            
            
        }
        
        
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside) {
        CLBeaconRegion *beaconRegionNew = (CLBeaconRegion *)region;
        [[[BeaconHelper sharedBeaconHelper] locationManager] startRangingBeaconsInRegion:beaconRegionNew];
        NSLog(@"---- CALLLLLLLLLL");
    }
}
/*
 - (void)setColorForProximity:(CLProximity)proximity {
 switch (proximity) {
 case CLProximityUnknown:
 //self.view.backgroundColor = [UIColor whiteColor];
 NSLog(@"Proximity: Unknown");
 break;
 
 case CLProximityFar:
 //self.view.backgroundColor = [UIColor yellowColor];
 NSLog(@"Proximity: Immediate:");
 break;
 
 case CLProximityNear:
 //self.view.backgroundColor = [UIColor orangeColor];
 NSLog(@"Proximity: Near:");
 break;
 
 case CLProximityImmediate:
 //self.view.backgroundColor = [UIColor redColor];
 NSLog(@"Proximity: Far:");
 break;
 
 default:
 break;
 }
 }
 */
- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"Away";
        case CLProximityFar:        return @"Far";
        case CLProximityNear:       return @"Near";
        case CLProximityImmediate:  return @"Immediate";
        default:
            return nil;
    }
}


@end

