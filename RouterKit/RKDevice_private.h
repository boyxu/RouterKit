//
//  RKDevice_private.h
//  RouterKit
//
//  Created by Sinoru on 2015. 8. 15..
//  Copyright (c) 2015년 Jaehong Kang. All rights reserved.
//

#import <RouterKit/RKDevice.h>

@interface RKDevice ()

+ (NSString *)geten0IPAddress;
+ (NSString *)getGatewayIPAddress;
+ (NSString *)getMacAddressFromIP:(NSString *)IPAddress;
+ (NSString *)getUniqueIdentifierString;
- (NSURLRequest *)createRequestWithPort:(NSNumber *)port path:(NSString *)path parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)HTTPMethod;

@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readwrite, retain) NSString *systemName;
@property (nonatomic, readwrite, retain) NSString *systemVersion;
@property (nonatomic, readwrite, retain) NSString *model;
@property (nonatomic, readwrite, retain) NSUUID *uniqueIdentifier;
@property (nonatomic, readwrite, retain) NSString *uniqueIdentifierString;
@property (nonatomic, readwrite, retain) NSString *gatewayIPAddress;

@property (nonatomic, readwrite, retain) NSString *username;
@property (nonatomic, readwrite, retain) NSString *password;

@end
