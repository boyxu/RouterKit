//
//  RKMobileDevice_private.h
//  RouterKit
//
//  Created by Sinoru on 2015. 8. 15..
//  Copyright (c) 2015년 Jaehong Kang. All rights reserved.
//

#import <RouterKit/RKMobileDevice.h>
#import <RouterKit/RKDevice_private.h>

@interface RKMobileDevice ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) BOOL generatingSignalNotificationsIsOn;
@property (nonatomic) NSUInteger lastSignalLevel;

@end
