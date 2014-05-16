/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVLocationManager.h"

@implementation CDVLocationManager {

}

# pragma mark CDVPlugin

- (void)pluginInitialize
{
    NSLog(@"[LocationManager Plugin] pluginInitialize()");
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.debugEnabled = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
}

- (void) pageDidLoad: (NSNotification*)notification{
    NSLog(@"[LocationManager Plugin] pageDidLoad()");
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    [self debugLog:@"didDetermineState: %@", [self regionStateAsString:state]];
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject: [self jsCallbackNameForSelector:_cmd] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        [dict setObject:[self regionStateAsString:state] forKey:@"state"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self debugLog:@"didEnterRegion: %@", region.identifier];
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:[self jsCallbackNameForSelector:(_cmd)] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self debugLog:@"didExitRegion: %@", region.identifier];
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self debugLog:@"didStartMonitoringForRegion: %@", region];

    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [self debugLog:@"monitoringDidFailForRegion: %@", error.description];
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        [dict setObject:@"error" forKey:error.description];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    [self debugLog:@"didRangeBeacons: %@", beacons];
    
    NSMutableArray* beaconsMapsArray = [[NSMutableArray alloc] init];
    for (CLBeacon* beacon in beacons) {
        NSDictionary* dictOfBeacon = [self mapOfBeacon:beacon];
        [beaconsMapsArray addObject:dictOfBeacon];
    }
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
        [dict setObject:[self mapOfRegion:region] forKey:@"region"];
        [dict setObject:beaconsMapsArray forKey:@"beacons"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.delegateCallbackId];
    }];
}


# pragma mark Javascript Plugin API

- (void)disableDebugLogs:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand * command) {
        _debugEnabled = false;
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } :command];

}

- (void)enableDebugLogs:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand * command) {
        _debugEnabled = true;
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } :command];
}

- (void)appendToDeviceLog:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand * command) {
        
        NSString* message = [command.arguments objectAtIndex:0];
        if (message != nil && [message length] > 0) {
            [self debugLog:[@"[DOM] " stringByAppendingString:message]];
            return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
        } else {
            return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
    } :command];
}

- (void)startMonitoringForRegion:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSError* error;
        CLRegion* region = [self parseRegion:command returningError:&error];
        if (region == nil) {
            if (error != nil) {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error.userInfo];
            } else {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown error."];
            }
        } else {
            [_locationManager startMonitoringForRegion:region];
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [result setKeepCallbackAsBool:YES];
            return result;
        }
    } :command];
}

- (void)stopMonitoringForRegion:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSError* error;
        CLRegion* region = [self parseRegion:command returningError:&error];
        if (region == nil) {
            if (error != nil) {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error.userInfo];
            } else {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown error."];
            }
        } else {
            [_locationManager stopMonitoringForRegion:region];
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [result setKeepCallbackAsBool:YES];
            return result;
        }
        
    } :command];
}

- (void)getAuthorizationStatus:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];

        NSString* authorizationStatusString = [self authorizationStatusAsString:authorizationStatus];
        
        NSDictionary *dict = @{@"authorizationStatus": authorizationStatusString};
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        
        
    } :command];
}

- (void)getMonitoredRegions:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSArray* arrayOfRegions = [self mapsOfRegions:self.locationManager.monitoredRegions];
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arrayOfRegions];
    } :command];
}

- (void)getRangedRegions:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSArray* arrayOfRegions = [self mapsOfRegions:self.locationManager.rangedRegions];
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arrayOfRegions];
    } :command];
}


- (void)isRangingAvailable:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand* command) {
        BOOL isRangingAvailable = [CLLocationManager isRangingAvailable];
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: isRangingAvailable];
    } :command];
}

- (void)registerDelegateCallbackId:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand* command) {
        self.delegateCallbackId = command.callbackId;
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        return result;
    } :command];
}

#pragma mark Parsing 

- (CLRegion*) parseRegion:(CDVInvokedUrlCommand*) command returningError:(out NSError **)error {
    
    NSDictionary* dict = command.arguments[0];

    NSString* typeName = [dict objectForKey:@"typeName"];
    if (typeName == nil) {
        *error = [self parseErrorWithDescription:@"'typeName' is missing, cannot parse CLRegion."];
        return nil;
    }
    
    NSString* identifier = [dict objectForKey:@"identifier"];
    if (identifier == nil) {
        *error = [self parseErrorWithDescription:@"'identifier' is missing, cannot parse CLRegion."];
        return nil;
    }
  
    if ([typeName isEqualToString:@"BeaconRegion"]) {
        return [self parseBeaconRegionFromMap:dict andIdentifier:identifier returningError:error];
    } else if ([typeName isEqualToString:@"CircularRegion"]) {
        return [self parseCircularRegionFromMap:dict andIdentifier:identifier returningError:error];
    } else {
        NSString* description = [NSString stringWithFormat:@"unsupported CLRegion subclass: %@", typeName];
        *error = [self parseErrorWithDescription: description];
        return nil;
    }
}

- (CLRegion*) parseCircularRegionFromMap:(NSDictionary*) dict andIdentifier:(NSString*) identifier returningError:(out NSError **)error {
    CLRegion *region;
    
    NSNumber *latitude = [dict objectForKey:@"latitude"];
    if (latitude == nil) {
        *error = [self parseErrorWithDescription:@"'latitude' is missing, cannot parse CLCircularRegion."];
        return nil;
    }
    
    NSNumber *longitude = [dict objectForKey:@"longitude"];
    if (longitude == nil) {
        *error = [self parseErrorWithDescription:@"'longitude' is missing, cannot parse CLCircularRegion."];
        return nil;
    }
    
    NSNumber *radiusAsNumber = [dict objectForKey:@"radius"];
    if (radiusAsNumber == nil) {
        *error = [self parseErrorWithDescription:@"'radius' is missing, cannot parse CLCircularRegion."];
        return nil;
    }
    
    CLLocationDistance radius = [radiusAsNumber doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
    if ([self isBelowIos7]) {
        region = [[CLCircularRegion alloc]initCircularRegionWithCenter:center radius:radius identifier:identifier];
    } else {
        region = [[CLRegion alloc] initCircularRegionWithCenter:center radius:radius identifier:identifier];
    }
    if (region == nil) {
        *error = [self parseErrorWithDescription:@"CLCircularRegion parsing failed for unknown reason."];
    }
    return region;
}

- (CLBeaconRegion*) parseBeaconRegionFromMap:(NSDictionary*) dict andIdentifier:(NSString*) identifier returningError:(out NSError **)error {
    CLBeaconRegion *region;
    if ([self isBelowIos7]) {
        *error = [self parseErrorWithDescription:@"CLBeaconRegion only supported on iOS 7 and above."];
        return nil;
    }
    NSString *uuidString = [dict objectForKey:@"uuid"];
    if (uuidString == nil) {
        *error = [self parseErrorWithDescription:@"'uuid' is missing, cannot parse CLBeaconRegion."];
        return nil;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    if (uuid == nil) {
        NSString* description = [NSString stringWithFormat:@"'uuid' %@ is not a valid UUID. Cannot parse CLBeaconRegion.", uuidString];
        *error = [self parseErrorWithDescription:description];
        return nil;
    }
    
    NSNumber *major = [dict objectForKey:@"major"];
    NSNumber *minor = [dict objectForKey:@"minor"];
    
    if (major == nil && minor == nil) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    } else if (major != nil && minor == nil){
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[major doubleValue] identifier:identifier];
    } else if (major != nil && major != nil) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[major doubleValue] minor:[minor doubleValue] identifier:identifier];
    } else {
        *error = [self parseErrorWithDescription:@"Unsupported combination of 'major' and 'minor' parameters."];
        return nil;
    }
    
    if (region == nil) {
        *error = [self parseErrorWithDescription:@"CLBeaconRegion parsing failed for unknown reason."];
    }
    return region;
}

#pragma mark iBeaconGap

- (void)startScanning:(CDVInvokedUrlCommand*)command {
    [self startMonitoringForRegion:command];
}

- (void)stopScanning:(CDVInvokedUrlCommand*)command {
    [self stopMonitoringForRegion:command];
}

- (void)getBeacons:(CDVInvokedUrlCommand*)command {

}

#pragma mark Utilities

- (NSError*) parseErrorWithDescription:(NSString*) description {
    return [self errorWithCode:CDV_LOCATION_MANAGER_INPUT_PARSE_ERROR andDescription:description];
}


- (NSError*) errorWithCode: (int)code andDescription:(NSString*) description {

    NSMutableDictionary* details;
    if (description != nil) {
        details = [NSMutableDictionary dictionary];
        [details setValue:description forKey:NSLocalizedDescriptionKey];
    }
    
    return [[NSError alloc] initWithDomain:@"CDVLocationManager" code:code userInfo:details];
}

- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command  {
    [self _handleCallSafely:unsafeHandler :command :true];
}

- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command : (BOOL) runInBackground :(NSString*) callbackId {
    if (runInBackground) {
        [self.commandDelegate runInBackground:^{
            @try {
                [self.commandDelegate sendPluginResult:unsafeHandler(command) callbackId:callbackId];
            }
            @catch (NSException * exception) {
                [self _handleExceptionOfCommand:command :exception];
            }
        }];
    } else {
        @try {
            [self.commandDelegate sendPluginResult:unsafeHandler(command) callbackId:callbackId];
        }
        @catch (NSException * exception) {
            [self _handleExceptionOfCommand:command :exception];
        }
    }
}

- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command : (BOOL) runInBackground {
    [self _handleCallSafely:unsafeHandler :command :true :command.callbackId];
    
}

- (void) _handleExceptionOfCommand: (CDVInvokedUrlCommand*) command : (NSException*) exception {
    NSLog(@"Uncaught exception: %@", exception.description);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.description];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (BOOL) isBelowIos7 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0;
}

- (NSString *)regionStateAsString: (CLRegionState) regionState {
    NSDictionary *states = @{@(CLRegionStateInside): @"CLRegionStateInside",
                             @(CLRegionStateOutside): @"CLRegionStateOutside",
                             @(CLRegionStateUnknown): @"CLRegionStateUnknown"};
    return [states objectForKey:[NSNumber numberWithInteger:regionState]];
}

- (NSString *)authorizationStatusAsString: (CLAuthorizationStatus) authorizationStatus {
    
    NSDictionary* statuses = @{@(kCLAuthorizationStatusNotDetermined) : @"AuthorizationStatusNotDetermined",
      @(kCLAuthorizationStatusAuthorized) : @"AuthorizationStatusAuthorized",
      @(kCLAuthorizationStatusDenied) : @"AuthorizationStatusDenied",
      @(kCLAuthorizationStatusRestricted) : @"AuthorizationStatusRestricted"};
    
    return [statuses objectForKey:[NSNumber numberWithInt: authorizationStatus]];
}

- (NSString*) proximityAsString: (CLProximity) proximity {
    NSDictionary *dict = @{@(CLProximityNear): @"ProximityNear",
                           @(CLProximityFar): @"ProximityFar",
                           @(CLProximityImmediate): @"ProximityImmediate",
                           @(CLProximityUnknown): @"ProximityUnknown"};
    return [dict objectForKey:[NSNumber numberWithInteger:proximity]];
}

- (void) debugLog: (NSString*) format, ... {
    if (!self.debugEnabled) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"%@", msg);
}

- (NSArray*) mapsOfRegions: (NSSet*) regions {
    NSMutableArray* array = [NSMutableArray new];
    for(CLRegion* region in regions) {
        [array addObject:[self mapOfRegion:region]];
    }
    return array;
}


- (NSDictionary*) mapOfRegion: (CLRegion*) region {
    NSMutableDictionary* dict;
    
    // identifier
    if (region.identifier != nil) {
        [dict setObject:region.identifier forKey:@"identifier"];
    }
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion* beaconRegion = (CLBeaconRegion*) region;
        return [[NSMutableDictionary alloc] initWithDictionary:[self mapOfBeaconRegion:beaconRegion]];
    } else {
        dict = [[NSMutableDictionary alloc] init];
    }
    
    // radius
    NSNumber* radius = [NSNumber numberWithDouble: region.radius];
    [dict setValue: radius forKey:@"radius"];

    
    NSNumber* latitude = [NSNumber numberWithDouble: region.center.latitude ];
    NSNumber* longitude = [NSNumber numberWithDouble: region.center.longitude];
    // center
    [dict setObject: latitude forKey:@"latitude"];
    [dict setObject: longitude forKey:@"longitude"];
    
    [dict setObject:region.identifier forKey:@"identifier"];
    
    // typeName - First two characters are cut down to remove the "CL" prefix.
    NSString *typeName = [NSStringFromClass([region class]) substringFromIndex:2];
    [dict setObject:typeName forKey:@"typeName"];
    
    [self debugLog:@"Created map from CLRegion => %@", dict];
    
    return dict;
}

- (NSDictionary*) mapOfBeaconRegion: (CLBeaconRegion*) region {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:region.proximityUUID.UUIDString forKey:@"uuid"];
    
    if (region.major != nil) {
        [dict setObject: region.major forKey:@"major"];
    }
    
    if (region.minor != nil) {
        [dict setObject:region.minor forKey:@"minor"];
    }
    
    
    return dict;
}

- (NSDictionary*) mapOfBeacon: (CLBeacon*) beacon {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    // uuid
    NSString* uuid = beacon.proximityUUID.UUIDString;
    [dict setObject:uuid forKey:@"uuid"];
    
    // proximity
    CLProximity proximity = beacon.proximity;
    NSString* proximityString = [self proximityAsString:proximity];
    [dict setObject:proximityString forKey:@"proximity"];
    
    // major
    [dict setObject:beacon.major forKey:@"major"];
    
    // minor
    [dict setObject:beacon.minor forKey:@"minor"];
    
    // rssi
    NSNumber * rssi = [[NSNumber alloc] initWithInteger:beacon.rssi];
    [dict setObject:rssi forKey:@"rssi"];
    
    return dict;
}

- (NSString*) jsCallbackNameForSelector: (SEL) selector {
    NSString* fullName = NSStringFromSelector(selector);
    
    NSString* shortName = [fullName stringByReplacingOccurrencesOfString:@"locationManager:" withString:@""];

    NSRange range = [shortName rangeOfString:@":"];
    
    while(range.location != NSNotFound) {
        shortName = [shortName stringByReplacingCharactersInRange:range withString:@""];
        if (range.location < shortName.length) {
            NSString* upperCaseLetter = [[shortName substringWithRange:range] uppercaseString];
            shortName = [shortName stringByReplacingCharactersInRange:range withString:upperCaseLetter];
        }

        range = [shortName rangeOfString:@":"];
    };
    
    [self debugLog:@"Converted %@ into %@", fullName, shortName];
    return shortName;
}


@end
