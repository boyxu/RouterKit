//
//  RKWLANChannel.h
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RKWLANChannelBand) {
    RKWLANChannelBandUnknown = 0,
    
    RKWLANChannelBand2GHz = 1,
    RKWLANChannelBand5GHz = 2,
};

typedef NS_ENUM(NSInteger, RKWLANChannelWidth) {
    RKWLANChannelWidthUnknown = 0,
    
    RKWLANChannelWidth20MHz = 1,
    RKWLANChannelWidth40MHz = 2,
};

typedef NS_ENUM(NSInteger, RKWLANChannelNumber) {
    RKWLANChannelNumberAuto = 0,
    RKWLANChannelNumberUnknown = -1
};

@interface RKWLANChannel : NSObject

- (id)initWithChannelNumber:(NSUInteger)channelNumber channelWidth:(RKWLANChannelWidth)channelWidth channelBand:(RKWLANChannelBand)channelBand;

@property (readonly) NSUInteger channelNumber;
@property (readonly) RKWLANChannelWidth channelWidth;
@property (readonly) RKWLANChannelBand channelBand;

@end
