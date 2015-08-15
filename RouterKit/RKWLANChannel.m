//
//  RKWLANChannel.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKWLANChannel_private.h"

@implementation RKWLANChannel

- (id)initWithChannelNumber:(NSUInteger)channelNumber channelWidth:(RKWLANChannelWidth)channelWidth channelBand:(RKWLANChannelBand)channelBand
{
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.channelWidth = channelWidth;
        self.channelBand = channelBand;
    }
    return self;
}

@end
