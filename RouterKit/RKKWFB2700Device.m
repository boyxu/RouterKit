//
//  RKKWFB2700Device.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKKWFB2700Device.h"

#import <RouterKit/RKMobileDevice_private.h>

@implementation RKKWFB2700Device

+ (instancetype)currentDevice
{
    id eggDevice;
    
    NSURLRequest *request = [[[self alloc] init] createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{@"act" : @"act_network_info", @"param" : @"DEV_NAME"} HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[self fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    if (![dictionary[@"data"][@"DEV_NAME"] isEqualToString:@"KWF-B2700"])
        return nil;
    
    eggDevice = [[self alloc] init];
    
    return eggDevice;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.model = @"KWF-B2700";
    }
    return self;
}

- (BOOL)canSleep
{
    return NO;
}

- (BOOL)canPowerOff
{
    return YES;
}

- (void)powerOff
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/upgrademain.cgi" parameters:@{ @"act" : @"act_system_reboot", @"param" : @"POWEROFF" } HTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    });
}

- (BOOL)canReboot
{
    return YES;
}

- (void)reboot
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/upgrademain.cgi" parameters:@{ @"act" : @"act_system_reboot", @"param" : @"REBOOT" } HTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    });
}

- (NSString *)systemVersion
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_version_info" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    return [dictionary[@"data"][@"ROOTFS_VERSION"] componentsSeparatedByString:@" "][0];
}

- (NSString *)WANIPAddress
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_network_info", @"param" : @"WI_IP_ADDR" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    return dictionary[@"data"][@"WI_IP_ADDR"];
}

- (NSArray *)connectedClients
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_attached_list" } HTTPMethod:@"GET"];
    
    if ([self.systemVersion isEqualToString:@"R4225"])
        request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_attatched_list" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSArray *dataKeys = [dictionary[@"data"] allKeys];
    
    NSArray *macKeys = [dataKeys objectsAtIndexes:[dataKeys indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        if (![obj hasPrefix:@"AD_MAC"])
            return NO;
        
        if ([[dictionary[@"data"][obj] componentsSeparatedByString:@":"] count] != 6)
            return NO;
        else if ([dictionary[@"data"][obj] isEqualToString:@"00:00:00:00:00:00"])
            return NO;
        else
            return YES;
    }]];
    
    NSMutableIndexSet *connectedClientIndexSet = [[NSMutableIndexSet alloc] init];
    
    [macKeys enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSNumber *clientIndex = [formatter numberFromString:[obj substringWithRange:NSMakeRange(7, [obj length] - 7)]];
        [connectedClientIndexSet addIndex:[clientIndex unsignedIntegerValue]];
    }];
    
    NSMutableArray *connectedClients = [[NSMutableArray alloc] initWithCapacity:[connectedClientIndexSet count]];
    
    [connectedClientIndexSet enumerateIndexesWithOptions:0 usingBlock:^(NSUInteger idx, BOOL *stop){
        NSString *nameKey = [NSString stringWithFormat:@"AD_NAME_%lu", (unsigned long)idx];
        NSString *macKey = [NSString stringWithFormat:@"AD_MAC_%lu", (unsigned long)idx];
        NSString *ipKey = [NSString stringWithFormat:@"AD_IP_%lu", (unsigned long)idx];
        
        NSString *name = dictionary[@"data"][nameKey];
        NSString *mac = dictionary[@"data"][macKey];
        NSString *ip = dictionary[@"data"][ipKey];
        
        NSMutableDictionary *client = [@{ @"MACAddress" : mac } mutableCopy];
        
        if (ip)
            [client setObject:ip forKey:@"IPAddress"];
        
        if (name)
            [client setObject:name forKey:@"name"];
        
        [connectedClients addObject:client];
    }];
    
    return [connectedClients copy];
}

+ (NSData *)fixJSONData:(NSData *)JSONData
{
    NSString *string = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:
                                   @"[{,]\\s*(\\w+)\\s*:"
                                                                            options:0
                                                                              error:NULL];
    NSMutableString *fixedString = [NSMutableString stringWithCapacity:([string length] * 1.1)];
    __block NSUInteger offset = 0;
    [regexp enumerateMatchesInString:string
                             options:0
                               range:NSMakeRange(0, [string length])
                          usingBlock:^(NSTextCheckingResult *result,
                                       NSMatchingFlags flags, BOOL *stop)
     {
         NSRange r = [result rangeAtIndex:1];
         [fixedString appendString:[string
                                    substringWithRange:NSMakeRange(offset,
                                                                   r.location - offset)]];
         [fixedString appendString:@"\""];
         [fixedString appendString:[string substringWithRange:r]];
         [fixedString appendString:@"\""];
         offset = r.location + r.length;
     }];
    [fixedString appendString:[string substringWithRange:NSMakeRange(offset,
                                                                     [string length] - offset)]];
    
    [fixedString replaceOccurrencesOfString:@"\"dummy09\":'XX'" withString:@"\"dummy09\":\"XX\"" options:0 range:NSMakeRange(0, fixedString.length)];
    
    return [fixedString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - WiFi

- (NSString *)SSID
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_network_info", @"param" : @"SSID" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    return dictionary[@"data"][@"SSID"];
}

- (RKDeviceWiFiPHYMode)WiFiPHYMode
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_network_info", @"param" : @"WI_MODE,SECUREMODE" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return RKDeviceWiFiPHYModeUnknown;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return RKDeviceWiFiPHYModeUnknown;
    
    if (!dictionary[@"result"])
        return RKDeviceWiFiPHYModeUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return RKDeviceWiFiPHYModeUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return RKDeviceWiFiPHYModeUnknown;
    
    RKDeviceWiFiPHYMode type = 0;
    
    if ([dictionary[@"data"][@"WI_MODE"] isEqualToString:@"802.11b"])
        type = RKDeviceWiFiPHYModeB;
    else if ([dictionary[@"data"][@"WI_MODE"] isEqualToString:@"802.11g"])
        type = RKDeviceWiFiPHYModeG;
    else if ([dictionary[@"data"][@"WI_MODE"] isEqualToString:@"802.11bg"])
        type = (RKDeviceWiFiPHYModeB | RKDeviceWiFiPHYModeG);
    
    return type;
}

- (RKDeviceWiFiSecurityMode)WiFiSecurityMode
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_network_info", @"param" : @"WI_MODE,SECUREMODE" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return RKDeviceWiFiSecurityModeNone;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return RKDeviceWiFiSecurityModeNone;
    
    if (!dictionary[@"result"])
        return RKDeviceWiFiSecurityModeNone;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return RKDeviceWiFiSecurityModeNone;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return RKDeviceWiFiSecurityModeNone;
    
    RKDeviceWiFiSecurityMode mode = RKDeviceWiFiSecurityModeNone;
    
    if ([dictionary[@"data"][@"SECUREMODE"] isEqualToString:@"WPA"] ||
        [dictionary[@"data"][@"SECUREMODE"] isEqualToString:@"WPA2"] ||
        [dictionary[@"data"][@"SECUREMODE"] isEqualToString:@"WPA/WPA2"])
        mode = RKDeviceWiFiSecurityModeWPA;
    
    return mode;
}

- (NSString *)WiFiSecurityPassword
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_ar6000_get" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return nil;
    
    if (!dictionary[@"result"])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return nil;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return nil;
    
    NSString *password;
    
    if (dictionary[@"data"][@"WPA_PASSWORD"] && ![dictionary[@"data"][@"WPA_PASSWORD"] isEqualToString:@""])
        password = dictionary[@"data"][@"WPA_PASSWORD"];
    
    return password;
}

- (RKDeviceWiFiWPAOptions)WiFiWPAOptions
{
    if ([self WiFiSecurityMode] != RKDeviceWiFiSecurityModeWPA)
        return 0;
    
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_ar6000_get" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return 0;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return 0;
    
    if (!dictionary[@"result"])
        return 0;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return 0;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return 0;
    
    RKDeviceWiFiWPAOptions options = RKDeviceWiFiWPAOptionKeyDistributionModePSK;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    switch ([[formatter numberFromString:dictionary[@"data"][@"WPA_TYPE"]] unsignedIntegerValue]) {
        case 0:
            options |= RKDeviceWiFiWPAOptionVersion1;
            break;
        case 1:
            options |= RKDeviceWiFiWPAOptionVersion2;
            break;
        case 2:
            options |= RKDeviceWiFiWPAOptionVersion1;
            options |= RKDeviceWiFiWPAOptionVersion2;
            break;
    }
    
    switch ([[formatter numberFromString:dictionary[@"data"][@"WPA_ENC"]] unsignedIntegerValue]) {
        case 0:
            options |= RKDeviceWiFiWPAOptionEncryptionModeAESCCMP;
            options |= RKDeviceWiFiWPAOptionEncryptionModeTKIP;
            break;
        case 1:
            options |= RKDeviceWiFiWPAOptionEncryptionModeTKIP;
            break;
        case 2:
            options |= RKDeviceWiFiWPAOptionEncryptionModeAESCCMP;
            break;
    }
    
    return options;
}

- (RKDeviceWiFiSignalStrength)WiFiSignalStrength
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_ar6000_get" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return RKDeviceWiFiSignalStrengthUnknown;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return RKDeviceWiFiSignalStrengthUnknown;
    
    if (!dictionary[@"result"])
        return RKDeviceWiFiSignalStrengthUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return RKDeviceWiFiSignalStrengthUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return RKDeviceWiFiSignalStrengthUnknown;
    
    if ([dictionary[@"data"][@"TXPOWER"] isEqualToString:@"index0"])
        return RKDeviceWiFiSignalStrengthStrong;
    else if ([dictionary[@"data"][@"TXPOWER"] isEqualToString:@"index1"])
        return RKDeviceWiFiSignalStrengthMiddle;
    else if ([dictionary[@"data"][@"TXPOWER"] isEqualToString:@"index2"])
        return RKDeviceWiFiSignalStrengthWeak;
    else
        return RKDeviceWiFiSignalStrengthUnknown;
}

- (NSArray *)wlanChannels
{
    return @[ [[RKWLANChannel alloc] initWithChannelNumber:0 channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz] ];
}

- (NSArray *)availableWLANChannels
{
    return @[
             [[RKWLANChannel alloc] initWithChannelNumber:RKWLANChannelNumberAuto channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz],
             [[RKWLANChannel alloc] initWithChannelNumber:1 channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz],
             [[RKWLANChannel alloc] initWithChannelNumber:5 channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz],
             [[RKWLANChannel alloc] initWithChannelNumber:9 channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz],
             [[RKWLANChannel alloc] initWithChannelNumber:13 channelWidth:RKWLANChannelWidth20MHz channelBand:RKWLANChannelBand2GHz]
             ];
}

#pragma mark - Mobile

- (RKMobileDeviceBatteryState)batteryState
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_battery_status", @"TYPE" : @"BISCUIT"} HTTPMethod:@"GET" ];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return RKMobileDeviceBatteryStateUnknown;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return RKMobileDeviceBatteryStateUnknown;
    
    if (!dictionary[@"result"])
        return RKMobileDeviceBatteryStateUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return RKMobileDeviceBatteryStateUnknown;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return RKMobileDeviceBatteryStateUnknown;
    
    if ([dictionary[@"data"][@"STATUS"] isEqualToString:@"normal"])
        return RKMobileDeviceBatteryStateUnplugged;
    else if ([dictionary[@"data"][@"STATUS"] isEqualToString:@"charging"])
        return RKMobileDeviceBatteryStateCharging;
    else
        return RKMobileDeviceBatteryStateUnknown;
}

- (float)batteryLevel
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_battery_status", @"TYPE" : @"BISCUIT"} HTTPMethod:@"GET" ];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return -1.0;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return -1.0;
    
    if (!dictionary[@"result"])
        return -1.0;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return -1.0;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return -1.0;
    
    if ([dictionary[@"data"][@"LEVEL"] isEqualToString:@"3"])
        return 1.0;
    else if ([dictionary[@"data"][@"LEVEL"] isEqualToString:@"2"])
        return 0.5;
    else if ([dictionary[@"data"][@"LEVEL"] isEqualToString:@"1"])
        return 0.2;
    else
        return -1.0;
}

- (NSString *)wwanCarrierName
{
    return @"KT";
}

- (NSInteger)wwanRSSI
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_wimax_status", @"param" : @"WIMAX_PHY_STATUS,WIMAX_LINK_STATUS" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return NSIntegerMin;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return NSIntegerMin;
    
    if (!dictionary[@"result"])
        return NSIntegerMin;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return NSIntegerMin;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return NSIntegerMin;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [[formatter numberFromString:dictionary[@"data"][@"rssm"]] integerValue];
}

- (NSInteger)wwanCINR
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/cgi-bin/webmain.cgi" parameters:@{ @"act" : @"act_wimax_status", @"param" : @"WIMAX_PHY_STATUS,WIMAX_LINK_STATUS" } HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return NSIntegerMin;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[self class] fixJSONData:data] options:0 error:&error];
    
    if (error)
        return NSIntegerMin;
    
    if (!dictionary[@"result"])
        return NSIntegerMin;
    else if ([dictionary[@"result"] isKindOfClass:[NSNumber class]] && ![dictionary[@"result"] isEqualToNumber:@(0)])
        return NSIntegerMin;
    else if ([dictionary[@"result"] isKindOfClass:[NSString class]] && ![dictionary[@"result"] isEqualToString:@"0"])
        return NSIntegerMin;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [[formatter numberFromString:dictionary[@"data"][@"cme"]] integerValue];
}

@end
