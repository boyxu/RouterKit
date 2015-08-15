//
//  RKDevice.h
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

@import Foundation;

@interface RKDevice : NSObject

+ (instancetype)currentDevice;
+ (BOOL)isGatewayRequiredURLCredential;
- (BOOL)setUser:(NSString *)user password:(NSString *)password;
- (BOOL)isURLCredentialCorrect;
- (BOOL)canSleep;
- (void)sleep;
- (BOOL)canPowerOff;
- (void)powerOff;
- (BOOL)canReboot;
- (void)reboot;

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *systemName;
@property (nonatomic, readonly, retain) NSString *systemVersion;
@property (nonatomic, readonly, retain) NSString *model;
@property (nonatomic, readonly, retain) NSUUID *uniqueIdentifier;
@property (nonatomic, readonly, retain) NSString *uniqueIdentifierString;
@property (nonatomic, readonly, retain) NSString *WANIPAddress;
@property (nonatomic, readonly, retain) NSArray *connectedClients;

@end
