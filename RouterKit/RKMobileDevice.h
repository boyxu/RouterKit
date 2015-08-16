//
//  RKMobileDevice.h
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import <RouterKit/RKDevice.h>
#import <RouterKit/RKDevice+WiFi.h>
#import <RouterKit/RKDevice+WWAN.h>

@import CoreLocation;

typedef NS_ENUM(NSInteger, RKMobileDeviceBatteryState) {
    RKMobileDeviceBatteryStateUnknown,
    RKMobileDeviceBatteryStateUnplugged,   // on battery, discharging
    RKMobileDeviceBatteryStateCharging,    // plugged in, less than 100%
    RKMobileDeviceBatteryStateFull,        // plugged in, at 100%
};

@interface RKMobileDevice : RKDevice

@property (nonatomic, readonly) RKMobileDeviceBatteryState batteryState;
@property (nonatomic, readonly) float batteryLevel;

@end

@interface RKMobileDevice (Notification)

- (void)beginGeneratingSignalNotifications;
- (void)endGeneratingSignalNotifications;

@end

@interface RKDevice (Mobile)

+ (RKMobileDevice *)currentMobileDevice;

@end
