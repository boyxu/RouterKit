//
//  RKWLANChannel_private.h
//  RouterKit
//
//  Created by Sinoru on 2015. 8. 15..
//  Copyright (c) 2015년 Jaehong Kang. All rights reserved.
//

#import <RouterKit/RKWLANChannel.h>

@interface RKWLANChannel ()

@property (readwrite) NSUInteger channelNumber;
@property (readwrite) RKWLANChannelWidth channelWidth;
@property (readwrite) RKWLANChannelBand channelBand;

@end
