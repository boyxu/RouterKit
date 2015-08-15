//
//  RKDevice+WiFi.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKDevice+WiFi.h"

#if !TARGET_OS_IPHONE
@import CoreWLAN;
#endif

@implementation RKDevice (WiFi)

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

- (RKDeviceWiFiPHYMode)WiFiPHYMode
{
    return RKDeviceWiFiPHYModeUnknown;
}

- (void)setWiFiPHYMode:(RKDeviceWiFiPHYMode)WiFiPHYMode
{
    
}

- (RKDeviceWiFiSecurityMode)WiFiSecurityMode
{
    return RKDeviceWiFiSecurityModeNone;
}

- (void)setWiFiSecurityMode:(RKDeviceWiFiSecurityMode)WiFiSecurityMode
{
    
}

- (NSString *)WiFiSecurityPassword
{
    return nil;
}

- (void)setWiFiSecurityPassword:(NSString *)WiFiSecurityPassword
{
    
}

- (RKDeviceWiFiWPAOptions)WiFiWPAOptions
{
    return RKDeviceWiFiWPAOptionNone;
}

- (void)setWiFiWPAOptions:(RKDeviceWiFiWPAOptions)WiFiWPAOptions
{
    
}

- (RKDeviceWiFiSignalStrength)WiFiSignalStrength
{
    return RKDeviceWiFiSignalStrengthUnknown;
}

- (void)setWiFiSignalStrength:(RKDeviceWiFiSignalStrength)WiFiSignalStrength
{
    
}

@end
