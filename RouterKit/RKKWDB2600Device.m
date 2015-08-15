//
//  RKKWDB2600Device.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKKWDB2600Device.h"

#import <RouterKit/RKMobileDevice_private.h>

@implementation RKKWDB2600Device

+ (instancetype)currentDevice
{
    id eggDevice = [[self alloc] init];
    
    NSURLRequest *request = [eggDevice createRequestWithPort:nil path:@"/admin/state.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"<td .*>모델명<\\/td>\\r?\\n+\\s*<td .*>(.+)&nbsp;<\\/td>" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSString *modelName = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (error)
        return nil;
    
    if (!modelName)
        return nil;
    
    if (![modelName isEqualToString:@"KWD-B2600"])
        return nil;
    
    return eggDevice;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.model = @"KWD-B2600";
    }
    return self;
}

- (BOOL)canSleep
{
    return YES;
}

- (void)sleep
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/goform/deep_sleep" parameters:nil HTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    });
}

- (BOOL)canPowerOff
{
    return NO;
}

- (BOOL)canReboot
{
    return YES;
}

- (void)reboot
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/goform/reboot_system" parameters:@{ @"act" : @"act_system_reboot", @"param" : @"REBOOT" } HTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    });
}

- (NSString *)systemVersion
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/state.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"<td .*id=\"SWVersion\">(.+)&nbsp;<\\/td>" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSString *systemVersion = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (error)
        return nil;
    
    if (!systemVersion)
        return nil;
    
    return systemVersion;
}

- (NSString *)WANIPAddress
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/RS_getWiMAXInfo.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"window.parent.callback_SetWiMAXInfo\\( (.+) \\);" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSString *wimaxInfoJSONString = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (error)
        return nil;
    
    if (!wimaxInfoJSONString)
        return nil;
    
    NSArray *wimaxInfoArray = [NSJSONSerialization JSONObjectWithData:[wimaxInfoJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NULL error:&error];
    
    if (error)
        return nil;
    
    if (!wimaxInfoArray)
        return nil;
    
    if ([wimaxInfoArray count] != 11)
        return nil;
    
    return wimaxInfoArray[1];
}

- (NSArray *)connectedClients
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/wireless/stainfo.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"<tr><td .*>(.+)<\\/td><td .*>.+<\\/td><td .*>.+<\\/td><\\/tr>" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSArray *textCheckingResults = [regularExpression matchesInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSLog(@"%@", error);
    NSLog(@"%@", textCheckingResults);
    
    NSMutableArray *connectedClients = [[NSMutableArray alloc] init];
    
    [textCheckingResults enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSTextCheckingResult *textCheckingResult, NSUInteger idx, BOOL *stop){
        NSString *mac = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
        
        NSMutableDictionary *client = [@{ @"MACAddress" : mac } mutableCopy];
        
        [connectedClients addObject:client];
    }];
    
    return [connectedClients copy];
}

- (NSString *)wwanCarrierName
{
    return @"KT";
}

- (NSInteger)wwanRSSI
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/RS_getWiMAXInfo.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"window.parent.callback_SetWiMAXInfo\\( (.+) \\);" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSString *wimaxInfoJSONString = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (error)
        return nil;
    
    if (!wimaxInfoJSONString)
        return nil;
    
    NSArray *wimaxInfoArray = [NSJSONSerialization JSONObjectWithData:[wimaxInfoJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NULL error:&error];
    
    if (error)
        return nil;
    
    if (!wimaxInfoArray)
        return nil;
    
    if ([wimaxInfoArray count] != 11)
        return nil;
    
    NSArray *cinrAndRSSI = [wimaxInfoArray[10] componentsSeparatedByString:@" / "];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [[formatter numberFromString:cinrAndRSSI[1]] integerValue];
}

- (NSInteger)wwanCINR
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/RS_getWiMAXInfo.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"window.parent.callback_SetWiMAXInfo\\( (.+) \\);" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    NSString *wimaxInfoJSONString = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (error)
        return nil;
    
    if (!wimaxInfoJSONString)
        return nil;
    
    NSArray *wimaxInfoArray = [NSJSONSerialization JSONObjectWithData:[wimaxInfoJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NULL error:&error];
    
    if (error)
        return nil;
    
    if (!wimaxInfoArray)
        return nil;
    
    if ([wimaxInfoArray count] != 11)
        return nil;
    
    NSArray *cinrAndRSSI = [wimaxInfoArray[10] componentsSeparatedByString:@" / "];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [[formatter numberFromString:cinrAndRSSI[0]] integerValue];
}

- (NSString *)SSID
{
    NSURLRequest *request = [self createRequestWithPort:nil path:@"/admin/state.asp" parameters:nil HTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode != 200 || error)
        return nil;
    
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"<td .*>네트워크 이름 (SSID)<\\/td><td .*>(.+)&nbsp;<\\/td>" options:(NSRegularExpressionUseUnixLineSeparators) error:&error];
    
    if (error)
        return nil;
    
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:htmlString options:NULL range:NSMakeRange(0, htmlString.length)];
    
    if (!textCheckingResult)
        return nil;
    
    NSString *SSID = [htmlString substringWithRange:[textCheckingResult rangeAtIndex:(textCheckingResult.numberOfRanges - 1)]];
    
    if (!SSID)
        return nil;
    
    return SSID;
}

@end
