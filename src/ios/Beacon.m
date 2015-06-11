//
//  Beacon.m
//  Beacon
//
//  Created by Daniel Mauer on 09.06.15.
//
//

#import "Beacon.h"

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <EstimoteSDK/EstimoteSDK.h>


@interface Beacon () <ESTBeaconManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLBeacon *beacon;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, strong) NSObject *beaconLocationData;
@property (nonatomic, strong) NSObject *beaconArray;

@property (nonatomic, strong) CLRegion *region;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@end

#pragma mark - Implementation

@implementation Beacon
@synthesize delegate;

static Beacon *sharedInstance = nil;


+ (void) initialize
{
    if (self == [Beacon class])
    {
        sharedInstance = [[self alloc] init];
    }
}

+ (Beacon *) sharedManager
{
    return sharedInstance;
}

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (Beacon*)[super initWithWebView:(UIWebView*)theWebView];
    if (self)
    {
        
    }
    return self;
}


- (id) init {
    
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
        self.beaconLocationData = nil;
        
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        
        if([self.beaconManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.beaconManager requestAlwaysAuthorization];
        }
        
        self.beaconArray = [[NSObject alloc] init];
        
    }
    return self;
}

- (void)start
{
    for (CLBeaconRegion *beacon in [self.locationManager monitoredRegions])
    {
        if ([beacon isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *region = beacon;
            NSLog(@"beacon: %@", beacon);
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            region.notifyEntryStateOnDisplay = YES;
            
            [self.beaconManager startMonitoringForRegion:region];
            [self startRanging];
            [self.beaconManager startRangingBeaconsInRegion: region];
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (void) startRanging
{
    for (CLBeaconRegion *beacon in [self.locationManager monitoredRegions])
    {
        if ([beacon isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *region = beacon;
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            region.notifyEntryStateOnDisplay = YES;
            
            [self.beaconManager startRangingBeaconsInRegion: region];
        }
    }
}



#pragma mark - iBeacon functions

-(void)setHost:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* beaconHost = [command.arguments objectAtIndex:0];
    
    // Save the host into ne nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:beaconHost forKey:@"BeaconHost"];
    [preferences synchronize]; //at the end of storage
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@", beaconHost]];
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
    
    
    //    NSUserDefaults *getBeaconPreferences = [NSUserDefaults standardUserDefaults];
    //    NSString *getBeaconHost = [getBeaconPreferences objectForKey:@"BeaconHost"];
    //    NSLog(@"getBeaconHost - objectForKey: %@", getBeaconHost);
    //
    //    NSString *savedHost = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"BeaconHost"];
    //    NSLog(@"savedHost: %@", savedHost);
}


-(void)setToken:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* token = [command.arguments objectAtIndex:0];
    
    // Save the host into ne nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:token forKey:@"BeaconUsertoken"];
    [preferences synchronize]; //at the end of storage
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@", token]];
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}




#pragma mark - iBeacon Functions new

-(void)addBeacon:(CDVInvokedUrlCommand *)command
{
    // setup the beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    NSString* callbackId = command.callbackId;
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    NSString *beaconId = [[options objectForKey:KEY_BEACON_ID] stringValue];
    NSString *proximityUUID = [options objectForKey:KEY_BEACON_PUUID];
    NSInteger majorInt = [[options objectForKey:KEY_BEACON_MAJOR] intValue];
    NSInteger minorInt = [[options objectForKey:KEY_BEACON_MINOR] intValue];
    NSUUID *puuid = [[NSUUID alloc] initWithUUIDString:proximityUUID];
    
    // setup the beacon region
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:puuid
                                                                major:majorInt
                                                                minor:minorInt
                                                           identifier:beaconId];
    //    NSLog(@"self.beaconRegion: %@", self.beaconRegion);
    // let us know when we exit and enter a region
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    
    // must have on iOS8
    [self.beaconManager requestAlwaysAuthorization];
    
    // start monitoring
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    [self returnMonitoringForBeaconRegionCallback:callbackId];
    
    // start ranging
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    
    // must have on iOS8
    //[self.beaconManager requestAlwaysAuthorization];
    
    //    NSLog(@"Monitored Region: %@", [self.beaconManager monitoredRegions]);
}

- (void)removeBeacon:(CDVInvokedUrlCommand*)command {
    
    NSString* callbackId = command.callbackId;
    //    NSLog(@"callbackId: %@", callbackId);
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[command.arguments objectAtIndex:0] forKey:@"bid"];
    
    // load all regions
    NSSet *beaconRegions = [self.beaconManager monitoredRegions];
    
    // create array with only beacons
    NSMutableArray* beaconRegionArray = [[NSMutableArray alloc] init];
    for (id region in beaconRegions.allObjects) {
        if ([region isKindOfClass:[CLCircularRegion class]]) {
            // it's for geofencing regions
        } else if ([region isKindOfClass:[CLBeaconRegion class]]) {
            // filtered out beacons from watched regions
            [beaconRegionArray addObject:region];
        }
    }
    
    
    NSString * combinedStuff = [command.arguments componentsJoinedByString:@"separator"];
    for (CLBeaconRegion *beaconRegion in beaconRegionArray) {
        
        if ([combinedStuff isEqualToString:beaconRegion.identifier]) {
            //            NSLog(@"=======    EQUAL   ======= %@", beaconRegion.identifier);
            //            NSLog(@"identifier: %@", beaconRegion.identifier);
            //            NSLog(@"uuid: %@", beaconRegion.proximityUUID);
            //            NSLog(@"major: %@", beaconRegion.major);
            //            NSLog(@"minor: %@", beaconRegion.minor);
            
            
            NSString *beaconIdentifier = (NSString *)beaconRegion.identifier;
            NSString *beaconProximityUUID = (NSString *)beaconRegion.proximityUUID.UUIDString;
            //            NSLog(@"beaconProximityUUID: %@", beaconProximityUUID);
            
            int beaconMajorInt = [beaconRegion.major intValue];
            int beaconMinorInt = [beaconRegion.minor intValue];
            
            NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:beaconProximityUUID];
            
            //            NSLog(@"beaconIdentifier: %@", beaconIdentifier);
            //            NSLog(@"beaconProximityUUID: %@", beaconProximityUUID);
            //            NSLog(@"beaconMajorInt: %d", beaconMajorInt);
            //            NSLog(@"beaconMinorInt: %d", beaconMinorInt);
            //            NSLog(@"beaconUUID: %@", beaconUUID);
            
            CLBeaconRegion *beaconRegionStop = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID
                                                                                       major:beaconMajorInt
                                                                                       minor:beaconMinorInt
                                                                                  identifier:beaconIdentifier];
            
            // stop monitoring
            //            NSLog(@"self.beaconManager:%@", self.beaconManager);
            [self.beaconManager stopMonitoringForRegion:beaconRegionStop];
            [self returnMonitoringForBeaconRegionCallback:callbackId];
        }
    }
}




#pragma mark - iBeacon ranging and interaction


// check for region failure
-(void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    //    NSLog(@"Region Did Fail: Manager:%@ Region:%@ Error:%@",manager, region, error);
    
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [posError setObject: [NSNumber numberWithInt: error.code] forKey:@"code"];
    [posError setObject: region.identifier forKey: @"beacocnid"];
    
    //    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    //            if (callbackId) {
    //            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    //        }
    //
    //    self.beaconLocationData.beaconCallbacks = [NSMutableArray array];
    
    
}

// check permission status
-(void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Status:%d", status);
}

//Beacon manager did enter region
- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    //Adding a custom local notification to be presented
    //    UILocalNotification *notification = [[UILocalNotification alloc]init];
    //    notification.alertBody = @"Youve enter a region!";
    //    notification.soundName = @"Default.mp3";
    //    NSLog(@"Youve entered");
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    [self triggerURL:@"far" withIdentifier:region.identifier];
    [[self locationManager] startRangingBeaconsInRegion:region];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self triggerURL:@"far" withIdentifier:region.identifier];
    });
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [DSBezelActivityView newActivityViewForView:view];
    //    });
    
}

//Beacon Manager did exit the region
- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    //adding a custon local notification
    //    UILocalNotification *notification = [[UILocalNotification alloc]init];
    //    notification.alertBody = @"Youve exited!!!";
    //    NSLog(@"Youve exited");
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    // call the url
    [self triggerURL:@"away" withIdentifier:region.identifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self triggerURL:@"away" withIdentifier:region.identifier];
    });
    
}



-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    if (beacons.count > 0) {
        CLBeacon *firstBeacon = [beacons firstObject];
        [self textForProximity:firstBeacon.proximity withIdentifier:region.identifier];
    }
}

-(NSString *)textForProximity:(CLProximity)proximity withIdentifier:(NSString *)identifier
{
    
    switch (proximity) {
        case CLProximityFar:
            NSLog(@"far");
            [self triggerURL:@"far" withIdentifier:identifier];
            return @"Far";
            break;
        case CLProximityNear:
            NSLog(@"near");
            [self triggerURL:@"near" withIdentifier:identifier];
            return @"Near";
            break;
        case CLProximityImmediate:
            NSLog(@"immediate");
            [self triggerURL:@"immediate" withIdentifier:identifier];
            return @"Immediate";
            break;
        case CLProximityUnknown:
            NSLog(@"unknown " );
            [self triggerURL:@"unknown" withIdentifier:identifier];
            return @"Unknown";
            break;
        default:
            break;
    }
}


-(void)getMessage
{
    UILocalNotification *msg = [[UILocalNotification alloc]init];
    msg.alertBody = @"Youve done it!";
    msg.soundName = @"Default.mp3";
    NSLog(@"Youve entered");
    [[UIApplication sharedApplication] presentLocalNotificationNow:msg];
}


- (void)getWatchedBeaconIds:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    
    
    // init the beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    
    // init all monitored regions
    NSSet *beaconRegions = [self.beaconManager monitoredRegions];
    
    
    // create array with only beacons
    NSMutableArray* beaconRegionArray = [[NSMutableArray alloc] init];
    for (id region in beaconRegions.allObjects) {
        if ([region isKindOfClass:[CLCircularRegion class]]) {
            
            // it's for geofencing regions
            
        } else if ([region isKindOfClass:[CLBeaconRegion class]]) {
            
            // filtered out beacons from watched regions
            NSLog(@"region: %@", region);
            [beaconRegionArray addObject:region];
        }
    }
    
    // loop the array and put the identifier into a new array
    NSMutableArray *watchedBeaconRegions = [NSMutableArray array];
    for (CLRegion *beaconRegion in beaconRegionArray) {
        [watchedBeaconRegions addObject:beaconRegion.identifier];
    }
    
    
    NSMutableDictionary* regionStatus = [NSMutableDictionary dictionaryWithCapacity:3];
    CDVPluginResult* result = nil;
    
    if (callbackId != nil) {
        [regionStatus setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
        [regionStatus setObject: @"BeaconRegion Success" forKey: @"message"];
        [regionStatus setObject: watchedBeaconRegions forKey: @"beaconRegionids"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:regionStatus];
    } else {
        [regionStatus setObject: [NSNumber numberWithInt: CDVCommandStatus_ERROR] forKey:@"code"];
        [regionStatus setObject: @"BeaconRegion Error" forKey: @"message"];
        [regionStatus setObject: watchedBeaconRegions forKey: @"beaconRegionids"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:regionStatus];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
}




#pragma mark - iBeacon common

- (void) returnMonitoringForBeaconRegionCallback:(NSString *)callbackId {
    NSMutableDictionary* posStatus = [NSMutableDictionary dictionaryWithCapacity:2];
    
    CDVPluginResult* result = nil;
    if (callbackId != nil) {
        [posStatus setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
        [posStatus setObject: @"BeaconRegion Success" forKey: @"message"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posStatus];
    } else {
        [posStatus setObject: [NSNumber numberWithInt: CDVCommandStatus_ERROR] forKey:@"code"];
        [posStatus setObject: @"BeaconRegion Error" forKey: @"message"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posStatus];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void) triggerURL:(NSString *)proximity withIdentifier:(NSString *)identifier {
    // NSURL Request
    //    NSLog(@"===================");
    //    NSLog(@"Enter Region - URL Request");
    //    NSLog(@"proximity; %@", proximity);
    //    NSLog(@"identifier; %@", identifier);
    
    // Load the storage data from nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *getHost = [preferences stringForKey:@"BeaconHost"];
    NSString *getUsertoken = [preferences stringForKey:@"BeaconUsertoken"];
    
    
    //NSString* beaconUrl = [NSString stringWithFormat:@"https://%@/sf/beacons/%@/away?s=&token=%@", getHost, region.identifier, getUsertoken];
    //    NSString *beaconUrl = [NSString stringWithFormat:@"https://www.myfavorito.com/sf/daniel_beacons/%@/%@/?device(id)=9876543210&s=", identifier, proximity];
    NSString *beaconUrl = [NSString stringWithFormat:@"https://%@/sf/daniel_beacons/%@/%@/?token=%@&s=", getHost, identifier, proximity, getUsertoken];
    
    NSURL* sfUrl = [NSURL URLWithString:beaconUrl];
    //    NSLog(@"URL: %@", sfUrl);
    
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
                NSLog(@"Cancel");
            }
        } else {
            NSString* myResponse;
            myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
        }
    };
    
    //enqueueBlock();
    
    // Load NSUserDefaults
    NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beaconTimer%@_%@", identifier, proximity]];
    NSLog(@"savedDate: %@", savedDate);
    
    // if savedDate = nil set current time + 5 minutes
    if (savedDate == nil) {
        NSLog(@"No entry found");
        NSDate *dateNow = [NSDate date];
        NSDate *dateToSave = [dateNow dateByAddingTimeInterval:300];
        NSLog(@"dateNow: %@", dateNow);
        NSLog(@"dateToSave: %@", dateToSave);
        // Save the timer into ne nsuserdefaults
        NSUserDefaults *setBeaconTimers = [NSUserDefaults standardUserDefaults];
        [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", identifier, proximity]];
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
            [setBeaconTimers setObject:dateToSave forKey:[NSString stringWithFormat:@"beaconTimer%@_%@", identifier, proximity]];
            [setBeaconTimers synchronize]; //at the end of storage
            
            enqueueBlock();
            
            break;
    }
    
    //enqueueBlock();
    
}

- (void)writeLog
{
    NSLog(@"Test");
}



@end
