//
//  Beacon.m
//  Beacon
//
//  Created by Daniel Mauer on 26.06.14.
//
//

#import "Beacon.h"

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import <CoreLocation/CoreLocation.h>



#pragma mark - Geofenfing Implementation

@implementation Beacon

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (Beacon*)[super initWithWebView:(UIWebView*)theWebView];
    if (self)
    {
        
    }
    return self;
}

- (BOOL) isSignificantLocationChangeMonitoringAvailable
{
    BOOL significantLocationChangeMonitoringAvailablelassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)];
    if (significantLocationChangeMonitoringAvailablelassPropertyAvailable)
    {
        BOOL significantLocationChangeMonitoringAvailable = [CLLocationManager significantLocationChangeMonitoringAvailable];
        return (significantLocationChangeMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringAvailable
{
    BOOL regionMonitoringAvailableClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringAvailable)];
    if (regionMonitoringAvailableClassPropertyAvailable)
    {
        BOOL regionMonitoringAvailable = [CLLocationManager regionMonitoringAvailable];
        return (regionMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringEnabled
{
    BOOL regionMonitoringEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringEnabled)];
    if (regionMonitoringEnabledClassPropertyAvailable)
    {
        BOOL regionMonitoringEnabled = [CLLocationManager regionMonitoringEnabled];
        return (regionMonitoringEnabled);
    }
    
    // by default, assume NO
    return NO;
}

//- (BOOL) isAuthorized
//{
//    BOOL authorizationStatusClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
//    if (authorizationStatusClassPropertyAvailable)
//    {
//        NSUInteger authStatus = [CLLocationManager authorizationStatus];
//        return (authStatus == kCLAuthorizationStatusAuthorized) || (authStatus == kCLAuthorizationStatusNotDetermined);
//    }
//
//    // by default, assume YES (for iOS < 4.2)
//    return YES;
//}


- (BOOL) isLocationServicesEnabled
{
    BOOL locationServicesEnabledInstancePropertyAvailable = [[[BeaconHelper sharedBeaconHelper] locationManager] respondsToSelector:@selector(locationServicesEnabled)]; // iOS 3.x
    BOOL locationServicesEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]; // iOS 4.x
    
    if (locationServicesEnabledClassPropertyAvailable)
    { // iOS 4.x
        return [CLLocationManager locationServicesEnabled];
    }
    else if (locationServicesEnabledInstancePropertyAvailable)
    { // iOS 2.x, iOS 3.x
        return [(id)[[BeaconHelper sharedBeaconHelper] locationManager] locationServicesEnabled];
    }
    else
    {
        return NO;
    }
}

#pragma mark - iBeacon functions

-(void)addBeacon:(CDVInvokedUrlCommand *)command
{
    NSString* callbackId = command.callbackId;
    NSLog(@"command Arguments: %@", command.arguments);
    
    [[BeaconHelper sharedBeaconHelper] saveBeaconCallbackId:callbackId];
    [[BeaconHelper sharedBeaconHelper] setCommandDelegate:self.commandDelegate];
    NSLog(@"setCommandDelegate: self.commandDelegate: -  %@", self.commandDelegate);
    
    
    if (self.isLocationServicesEnabled) {
        BOOL forcePrompt = NO;
        
        if (forcePrompt) {
            [[BeaconHelper sharedBeaconHelper] returnBeaconError:PERMISSIONDENIED withMessage:nil];
            return;
        }
        
    }
    
    //    if (![self isAuthorized]) {
    //        NSString* message = nil;
    //        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
    //
    //        if (authStatusAvailable) {
    //            NSUInteger code = [CLLocationManager authorizationStatus];
    //
    //            if (code == kCLAuthorizationStatusNotDetermined) {
    //                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
    //                message = @"User undecided on application's use of location services";
    //            } else if (code == kCLAuthorizationStatusRestricted) {
    //                message = @"application use of location services is restricted";
    //            }
    //        }
    //        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
    //        [[BeaconHelper sharedBeaconHelper] returnBeaconError:PERMISSIONDENIED withMessage: message];
    //
    //        return;
    //    }
    
    
    
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"CLAuthorizationStatus: %d", status);
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        // [alertView show];
        
        // status when in use or denied
        NSString* errorMessage = nil;
        errorMessage = @"User undecided on application's use of location services";
        [[BeaconHelper sharedBeaconHelper] returnBeaconError:PERMISSIONDENIED withMessage: errorMessage];
        
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        //[self.locationManager requestAlwaysAuthorization];
        NSLog(@"requestAlwaysAuthorization - start");
        [[[BeaconHelper sharedBeaconHelper] locationManager] requestAlwaysAuthorization];
        NSLog(@"requestAlwaysAuthorization - end");
    }
    
    //    if (status == kCLAuthorizationStatusAuthorizedAlways) {
    //        NSLog(@"kCLAuthorizationStatusAuthorizedAlways: status: %d", status);
    //    }
    
    
    
    if (![self isRegionMonitoringAvailable])
    {
        [[BeaconHelper sharedBeaconHelper] returnBeaconError:REGIONMONITORINGUNAVAILABLE withMessage: @"Region monitoring is unavailable"];
        return;
    }
    
    if (![self isRegionMonitoringEnabled])
    {
        [[BeaconHelper sharedBeaconHelper] returnBeaconError:REGIONMONITORINGPERMISSIONDENIED withMessage: @"User has restricted the use of region monitoring"];
        return;
    }
    
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    NSLog(@"NSMutableDictionary - options: %@", options);
    [self addBeaconToMonitor:options];
    [[BeaconHelper sharedBeaconHelper] returnBeaconRegionSuccess];
    
    //NSLog(@"addRegions: options: %@", options);
    
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForRanging];
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForMonitoring];
    
}


- (void) addBeaconToMonitor:(NSMutableDictionary *)params {
    // Parse Incoming Params
    NSLog(@"addBeaconToMonitor - params: %@", params);
    NSString *beaconId = [[params objectForKey:KEY_BEACON_ID] stringValue];
    //    NSString *beaconId = [[params stringForK]]
    NSString *proximityUUID = [params objectForKey:KEY_BEACON_PUUID];
    NSInteger majorInt = [[params objectForKey:KEY_BEACON_MAJOR] intValue];
    NSInteger minorInt = [[params objectForKey:KEY_BEACON_MINOR] intValue];
    NSUUID *puuid = [[NSUUID alloc] initWithUUIDString:proximityUUID];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:puuid major:majorInt minor:minorInt identifier:beaconId];
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    beaconRegion.notifyEntryStateOnDisplay = YES;
    
    NSLog(@"Function: addRegion, BeaconRegion: %@", beaconRegion);
    [[[BeaconHelper sharedBeaconHelper] locationManager] startMonitoringForRegion:beaconRegion];
    
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForRanging];
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForMonitoring];
}


- (void)getWatchedBeaconIds:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    //NSLog(@"getWatchedBeaconRegionIds: callbackId: %@", callbackId);
    
    NSSet *beaconRegions = [[BeaconHelper sharedBeaconHelper] locationManager].monitoredRegions;
    //NSLog(@"getWatchedBeaconRegionIds: %@", beaconRegions);
    
    /*
     *      T E S T - O R D E R E D  N S S E T
     */
    
    NSMutableArray* beaconRegionArray = [[NSMutableArray alloc] init];
    
    for (id region in beaconRegions.allObjects) {
        if ([region isKindOfClass:[CLCircularRegion class]]) {
            //NSLog(@"hier ist eine Geofencing Region");
            // Abfragen auf circular-Properties die Du suchst....
        } else if ([region isKindOfClass:[CLBeaconRegion class]]) {
            //NSLog(@"hier ist eine Beacon Region");
            // Abfragen auf beacon-Properties die Su suchst...
            [beaconRegionArray addObject:region];
        }
    }
    
    NSLog(@"Mein neues Array nur mit Beacons: %@", beaconRegionArray);
    
    
    /*
     *          E N D E
     */
    
    NSMutableArray *watchedBeaconRegions = [NSMutableArray array];
    for (CLRegion *beaconRegion in beaconRegionArray) {
        [watchedBeaconRegions addObject:beaconRegion.identifier];
        //NSLog(@"beaconRegion.identifier: %@", beaconRegion.identifier);
        //NSLog(@"beaconRegion.description: %@", beaconRegion.description);
        
    }
    
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:3];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"BeaconRegion Success" forKey: @"message"];
    [posError setObject: watchedBeaconRegions forKey: @"beaconRegionids"];
    
    //CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:watchedBeaconRegions];
    NSLog(@"PluginResult: %@", pluginResult);
    NSLog(@"PositionError: %@", posError);
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        //NSLog(@"posError: %@", posError);
    }
    
    NSLog(@"watchedBeaconRegions: %@", watchedBeaconRegions);
    
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForRanging];
    [[BeaconHelper sharedBeaconHelper] checkLocationAccessForMonitoring];
    
}

- (void) removeBeaconToMonitor:(NSMutableDictionary *)params {
    // Parse Incoming Params
    NSLog(@"removeBeaconToMonitor - params: %@", params);
    
    NSString *beaconId = [[params objectForKey:KEY_BEACON_ID] stringValue];
    NSString *proximityUUID = [params objectForKey:KEY_BEACON_PUUID];
    NSInteger majorInt = [[params objectForKey:KEY_BEACON_MAJOR] intValue];
    NSInteger minorInt = [[params objectForKey:KEY_BEACON_MINOR] intValue];
    NSUUID *puuid = [[NSUUID alloc] initWithUUIDString:proximityUUID];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:puuid major:majorInt minor:minorInt identifier:beaconId];
    [[[BeaconHelper sharedBeaconHelper] locationManager] stopMonitoringForRegion:beaconRegion];
}


- (void)removeBeacon:(CDVInvokedUrlCommand*)command {
    
    NSString* callbackId = command.callbackId;
    NSLog(@"removeBeaconRegion.callbackId: %@", callbackId);
    NSLog(@"removeBeaconRegion.command.arguments: %@", command.arguments);
    [[BeaconHelper sharedBeaconHelper] saveBeaconCallbackId:callbackId];
    [[BeaconHelper sharedBeaconHelper] setCommandDelegate:self.commandDelegate];
    
    
    NSLog(@"isLocationServicesEnabled: %hhd", [self isLocationServicesEnabled]);
    if (![self isLocationServicesEnabled])
    {
        BOOL forcePrompt = NO;
        NSLog(@"removeRegion.forcePromt: %hhd", forcePrompt);
        if (!forcePrompt)
        {
            NSLog(@"removeRegion.forcePromt: %hhd", forcePrompt);
            [[BeaconHelper sharedBeaconHelper] returnBeaconError:PERMISSIONDENIED withMessage: nil];
            return;
        }
    }
    
    //    if (![self isAuthorized])
    //    {
    //        NSString* message = nil;
    //        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
    //        if (authStatusAvailable) {
    //            NSUInteger code = [CLLocationManager authorizationStatus];
    //            if (code == kCLAuthorizationStatusNotDetermined) {
    //                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
    //                message = @"User undecided on application's use of location services";
    //            } else if (code == kCLAuthorizationStatusRestricted) {
    //                message = @"application use of location services is restricted";
    //            }
    //        }
    //        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
    //        [[BeaconHelper sharedBeaconHelper] returnBeaconError:PERMISSIONDENIED withMessage: message];
    //
    //        return;
    //    }
    
    if (![self isRegionMonitoringAvailable])
    {
        [[BeaconHelper sharedBeaconHelper] returnBeaconError:REGIONMONITORINGUNAVAILABLE withMessage: @"Region monitoring is unavailable"];
        return;
    }
    
    if (![self isRegionMonitoringEnabled])
    {
        [[BeaconHelper sharedBeaconHelper] returnBeaconError:REGIONMONITORINGPERMISSIONDENIED withMessage: @"User has restricted the use of region monitoring"];
        return;
    }
    
    
    //    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[command.arguments objectAtIndex:0] forKey:@"bid"];
    NSLog(@"RemoveBeacon - options: %@", options);
    [self removeBeaconToMonitor:options];
    
    
    //    NSString *beaconId = [command.arguments objectAtIndex:0];
    //    NSLog(@"RemoveBeacon - options: %@", beaconId);
    //    [self removeBeaconToMonitor:beaconId];
    
    [[BeaconHelper sharedBeaconHelper] returnBeaconRegionSuccess];
}


-(void)setHost:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* beaconHost = [command.arguments objectAtIndex:0];
    NSLog(@"Parameter: %@", command.arguments);
    NSLog(@"Host: %@", beaconHost);
    
    // Save the host into ne nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:beaconHost forKey:@"BeaconHost"];
    [preferences synchronize]; //at the end of storage
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@", beaconHost]];
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
    
    
    NSUserDefaults *getBeaconPreferences = [NSUserDefaults standardUserDefaults];
    NSString *getBeaconHost = [getBeaconPreferences objectForKey:@"BeaconHost"];
    NSLog(@"getBeaconHost - objectForKey: %@", getBeaconHost);
    
    NSString *savedHost = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"BeaconHost"];
    NSLog(@"savedHost: %@", savedHost);
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







@end
