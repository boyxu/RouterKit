//
//  RKGenericDevice.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKGenericDevice.h"

#if !TARGET_OS_IPHONE
@import CoreWLAN;
#endif

#import "RKDevice_private.h"

@implementation RKGenericDevice

+ (instancetype)currentDevice
{
    id routerDevice = [[self alloc] init];
    
    return routerDevice;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = @"Unknown";
        self.systemName = @"Unknown";
        self.systemVersion = @"Unknown";
        self.model = @"Unknown";
    }
    return self;
}

- (NSString *)SSID
{
    NSString *ssid = nil;
    
#if !TARGET_OS_IPHONE
    CWInterface *interface = [CWInterface interface];
    
    if (interface && ![interface.ssid isEqualToString:@""])
        ssid = interface.ssid;
#endif
    
    return ssid;
}

- (void)setSSID:(NSString *)SSID
{
    
}

@end
