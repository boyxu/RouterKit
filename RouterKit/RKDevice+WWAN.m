//
//  RKDevice+WWAN.m
//  RouterKit
//
//  Created by Sinoru on 2015. 8. 16..
//  Copyright © 2015년 Jaehong Kang. All rights reserved.
//

#import "RKDevice+WWAN.h"

@implementation RKDevice (WWAN)

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

- (NSString *)wwanCarrierName
{
    return nil;
}

- (NSInteger)wwanRSSI
{
    return NSIntegerMin;
}

- (NSInteger)wwanCINR
{
    return NSIntegerMin;
}

@end
