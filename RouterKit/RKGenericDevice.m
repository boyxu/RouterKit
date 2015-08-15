//
//  RKGenericDevice.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKGenericDevice.h"

#import "RKDevice+WiFi.h"

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

@end
