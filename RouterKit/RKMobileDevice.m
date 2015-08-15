//
//  RKMobileDevice.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKMobileDevice_private.h"

#import "RKKWDB2600Device.h"
#import "RKKWFB2700Device.h"

@implementation RKMobileDevice

+ (instancetype)currentDevice
{
    id mobileDevice;
    
    mobileDevice = [RKKWDB2600Device currentDevice];
    if (mobileDevice)
        return mobileDevice;
    
    mobileDevice = [RKKWFB2700Device currentDevice];
    if (mobileDevice)
        return mobileDevice;
    
    return nil;
}

- (NSString *)name
{
    return self.SSID;
}

- (NSUInteger)wwanSignalLevel
{
    NSInteger RSSI = [self wwanRSSI];
    NSInteger CINR = [self wwanCINR];
    
    NSUInteger level = 0;
    
    // Using KT's signal level calculation formula
    if (RSSI > -55) {
        if (CINR > 15)
            level = 5;
        else if (CINR > 10)
            level = 5;
        else if (CINR > 3)
            level = 3;
        else if (CINR > 0)
            level = 2;
        else if (CINR > -3)
            level = 1;
        else
            level = 0;
    }
    else if (RSSI > -65) {
        if (CINR > 15)
            level = 5;
        else if (CINR > 10)
            level = 4;
        else if (CINR > 3)
            level = 2;
        else if (CINR > 0)
            level = 1;
        else if (CINR > -3)
            level = 1;
        else
            level = 0;
    }
    else if (RSSI > -75) {
        if (CINR > 15)
            level = 4;
        else if (CINR > 10)
            level = 3;
        else if (CINR > 3)
            level = 1;
        else if (CINR > 0)
            level = 1;
        else if (CINR > -3)
            level = 0;
        else
            level = 0;
    }
    else if (RSSI > -84) {
        if (CINR > 15)
            level = 2;
        else if (CINR > 10)
            level = 1;
        else if (CINR > 3)
            level = 1;
        else if (CINR > 0)
            level = 1;
        else if (CINR > -3)
            level = 0;
        else
            level = 0;
    }
    
    return level;
}

- (void)startCheckSignal
{
    NSUInteger timeInterval = 10;
    
    while (self.generatingSignalNotificationsIsOn && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]]) {
        [self checkSignal];
    }
}

- (void)checkSignal
{
    if (self.lastSignalLevel != self.wwanSignalLevel) {
        [[NSNotificationCenter defaultCenter] postNotificationName:nil object:nil userInfo:nil];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self checkSignal];
}

@end

@implementation RKMobileDevice (Notification)

- (void)beginGeneratingSignalNotifications
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0)
    if ([CLLocationManager instancesRespondToSelector:@selector(pausesLocationUpdatesAutomatically)])
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
#endif
    
    [self.locationManager startUpdatingLocation];
    
    self.generatingSignalNotificationsIsOn = YES;
}

- (void)endGeneratingSignalNotifications
{
    
}

@end
