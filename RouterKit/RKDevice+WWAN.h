//
//  RKDevice+WWAN.h
//  RouterKit
//
//  Created by Sinoru on 2015. 8. 16..
//  Copyright © 2015년 Jaehong Kang. All rights reserved.
//

#import <RouterKit/RKDevice.h>

@interface RKDevice (WWAN)

@property (nonatomic, readonly) NSUInteger wwanSignalLevel;
@property (nonatomic, readonly) NSString *wwanCarrierName;
@property (nonatomic, readonly) NSInteger wwanRSSI;
@property (nonatomic, readonly) NSInteger wwanCINR;

@end
