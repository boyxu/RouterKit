//
//  RKDevice+WiFi.h
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import <RouterKit/RKDevice.h>
#import <RouterKit/RKWLANChannel.h>

typedef NS_OPTIONS(NSUInteger, RKDeviceWiFiPHYMode) {
    RKDeviceWiFiPHYModeUnknown      = 0,
    RKDeviceWiFiPHYModeA            = 1 << 0,
    RKDeviceWiFiPHYModeB            = 1 << 1,
    RKDeviceWiFiPHYModeG            = 1 << 2,
    RKDeviceWiFiPHYModeN            = 1 << 3,
    RKDeviceWiFiPHYModeAC           = 1 << 4,
    RKDeviceWiFiPHYModeAD           = 1 << 5,
};

typedef NS_ENUM(NSInteger, RKDeviceWiFiSecurityMode) {
    RKDeviceWiFiSecurityModeNone = 0,
    
    RKDeviceWiFiSecurityModeWEP,
    RKDeviceWiFiSecurityModeWPA,
    RKDeviceWiFiSecurityMode8021X,
};

typedef NS_OPTIONS(NSUInteger, RKDeviceWiFiWPAOptions) {
    RKDeviceWiFiWPAOptionNone                       = 0,
    
    RKDeviceWiFiWPAOptionVersion1                   = 1 << 0,
    RKDeviceWiFiWPAOptionVersion2                   = 1 << 1,
    
    RKDeviceWiFiWPAOptionEncryptionModeTKIP         = 1 << 8,
    RKDeviceWiFiWPAOptionEncryptionModeAESCCMP      = 1 << 9,
    
    RKDeviceWiFiWPAOptionKeyDistributionModePSK     = 1 << 20,
    RKDeviceWiFiWPAOptionKeyDistributionMode8021x   = 2 << 20,
};

typedef NS_ENUM(NSInteger, RKDeviceWiFiSignalStrength) {
    RKDeviceWiFiSignalStrengthUnknown = 0,
    
    RKDeviceWiFiSignalStrengthWeak,
    RKDeviceWiFiSignalStrengthMiddle,
    RKDeviceWiFiSignalStrengthStrong,
};

@interface RKDevice (WiFi)

@property (nonatomic, readwrite, retain) NSString *SSID;
@property (nonatomic, readwrite) RKDeviceWiFiPHYMode WiFiPHYMode;
@property (nonatomic, readwrite) RKDeviceWiFiSecurityMode WiFiSecurityMode;
@property (nonatomic, readwrite) RKDeviceWiFiWPAOptions WiFiWPAOptions;
@property (nonatomic, readwrite) RKDeviceWiFiSignalStrength WiFiSignalStrength;
@property (nonatomic, readwrite) NSArray *wlanChannels;
@property (nonatomic, readwrite) NSArray *availableWLANChannels;
@property (nonatomic, readwrite) NSString *WiFiSecurityPassword;

@end
