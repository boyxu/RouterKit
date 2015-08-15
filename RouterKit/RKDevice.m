//
//  RKDevice.m
//  
//
//  Created by Sinoru on 2015. 8. 15..
//
//

#import "RKDevice_private.h"

#include <err.h>

#include <netdb.h>

#include <sys/sysctl.h>

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <netinet/in.h>

#if TARGET_OS_IPHONE
#include "if_ether.h"
#else
#include "netinet/if_ether.h"
#endif

#include <net/if.h>
#include <net/if_dl.h>

#if TARGET_OS_IPHONE
#include "route.h"
#else
#include "net/route.h"
#endif

#if TARGET_OS_IPHONE
#include "if_arp.h"
#else
#include "net/if_arp.h"
#endif

#include <CommonCrypto/CommonHMAC.h>

#import "RKGenericDevice.h"
#import "RKMobileDevice.h"

@import SSKeychain;

@implementation RKDevice

@synthesize name;
@synthesize systemName;
@synthesize systemVersion;
@synthesize model;
@synthesize uniqueIdentifier;

+ (instancetype)currentDevice
{
    static RKDevice *routerDevice;
    
    NSString *uniqueIdentifierString = [self getUniqueIdentifierString];
    
    if (!uniqueIdentifierString)
        return nil;
    
    do {
        if (routerDevice && ![routerDevice isKindOfClass:[RKGenericDevice class]] && [[routerDevice uniqueIdentifierString] isEqualToString:uniqueIdentifierString])
            break;
        
        routerDevice = [RKMobileDevice currentDevice];
        if (routerDevice)
            break;
        
        routerDevice = [RKGenericDevice currentDevice];
    } while (0);
    
    return routerDevice;
}

+ (BOOL)isGatewayRequiredURLCredential
{
    return ![self checkURLCredentialCorrectWithUsername:nil password:nil];
}

- (BOOL)setUser:(NSString *)user password:(NSString *)password
{
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = [self keychainServiceName];
    query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
    
    [[query fetchAll:nil] enumerateObjectsUsingBlock:^(NSDictionary *account, NSUInteger idx, BOOL *stop){
        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
        query.service = [self keychainServiceName];
        query.account = account[kSSKeychainAccountKey];
        query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
        [query deleteItem:nil];
    }];
    
    query = [[SSKeychainQuery alloc] init];
    query.service = [self keychainServiceName];
    query.account = user;
    query.password = password;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
    [query save:nil];
    
    [self loadDeviceInformation];
    
    return [self isURLCredentialCorrect];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.uniqueIdentifierString = [[self class] getUniqueIdentifierString];
        if ([NSUUID class])
            self.uniqueIdentifier = [[NSUUID alloc] initWithUUIDString:self.uniqueIdentifierString];
        
        [self loadDeviceInformation];
    }
    return self;
}

- (void)loadDeviceInformation
{
    if ([self.uniqueIdentifierString isEqualToString:[[self class] getUniqueIdentifierString]]) {
        self.gatewayIPAddress = [[self class] getGatewayIPAddress];
        
        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
        query.service = [self keychainServiceName];
        query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
        
        self.username = [query fetchAll:nil][0][kSSKeychainAccountKey];
        
        if (self.username != nil) {
            SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
            query.service = [self keychainServiceName];
            query.account = self.username;
            query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
            [query fetch:nil];
            
            self.password = query.password;
        }
    }
}

- (BOOL)isURLCredentialCorrect
{
    return [[self class] checkURLCredentialCorrectWithUsername:self.username password:self.password];
}

- (BOOL)canSleep
{
    return NO;
}

- (BOOL)canPowerOff
{
    return NO;
}

- (BOOL)canReboot
{
    return NO;
}

- (NSString *)keychainServiceName
{
    return [NSString stringWithFormat:@"%@.RouterDevice.%@", [[NSBundle mainBundle] bundleIdentifier], self.uniqueIdentifierString];
}

+ (BOOL)checkURLCredentialCorrectWithUsername:(NSString *)username password:(NSString *)password
{
    NSString *gatewayIPAddress = [[self class] getGatewayIPAddress];
    
    NSURL *baseURL = [[NSURL alloc] initWithScheme:@"http" host:gatewayIPAddress path:@"/"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    do {
        NSURL *url;
        
        if ((username && ![username isEqualToString:@""]) && (password && ![password isEqualToString:@""]))
            url = [[NSURL alloc] initWithScheme:@"http" host:[NSString stringWithFormat:@"%@:%@@%@", username, password, baseURL.host] path:baseURL.path];
        else
            url = baseURL;
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3.0f];
        
        NSData *recevicedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSString *redirectLocation = response.allHeaderFields[@"Location"];
        
        if (redirectLocation) {
            baseURL = [NSURL URLWithString:redirectLocation relativeToURL:baseURL];
            continue;
        }
        
        NSStringEncoding encoding;
        
        if (response.textEncodingName) {
            CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef) [response textEncodingName]);
            encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
        }
        else
            encoding = NSUTF8StringEncoding;
        
        NSString *receviedText = [[NSString alloc] initWithData:recevicedData encoding:encoding];
        
        baseURL = nil;
    } while (baseURL);
    
    if (error.code == -1012 || response.statusCode == 401 || response.statusCode == 403)
        return NO;
    
    return YES;
}

+ (NSString *)geten0IPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/* $Id: getgateway.c,v 1.23 2012/03/05 19:38:37 nanard Exp $ */
/* libnatpmp
 
 Copyright (c) 2007-2011, Thomas BERNARD
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * The name of the author may not be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

+ (NSString *)getGatewayIPAddress
{
    NSString *ipString;
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;
    if (sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return nil;
    }
    if (l>0) {
        buf = (char *)malloc(l);
        if (sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            free(buf);
            return nil;
        }
        for (p = buf; p < buf + l; p += rt -> rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i = 0; i < RTAX_MAX; i++) {
                if (rt -> rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char *strBuf = (char *)malloc(l);
                    
                    in_addr_t addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    socklen_t addrlen = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_len;
                    inet_ntop(AF_INET, &addr, strBuf, addrlen);
                    ipString = [[NSString alloc] initWithCString:strBuf encoding:NSUTF8StringEncoding];
                    
                    free(strBuf);
                }
            }
        }
        free(buf);
    }
    
    return ipString;
}

+ (NSString *)getMacAddressFromIP:(NSString *)IPAddress
{
    if (!IPAddress)
        return nil;
    
    const char *ip = [IPAddress UTF8String];
    
    if (!ip)
        return nil;
    
    int nflag, found_entry;
    
    NSString *mAddr = nil;
    u_long addr = inet_addr(ip);
    int mib[6];
    size_t needed;
    char *host, *lim, *buf, *next;
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    extern int h_errno;
    struct hostent *hp;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    if ((buf = (char *)malloc(needed)) == NULL)
        err(1, "malloc");
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    
    lim = buf + needed;
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        if (addr) {
            if (addr != sin->sin_addr.s_addr)
                continue;
            found_entry = 1;
        }
        if (nflag == 0)
            hp = gethostbyaddr((caddr_t)&(sin->sin_addr),
                               sizeof sin->sin_addr, AF_INET);
        else
            hp = 0;
        if (hp)
            host = hp->h_name;
        else {
            host = (char *)"?";
            if (h_errno == TRY_AGAIN)
                nflag = 1;
        }
        
        if (sdl->sdl_alen) {
            
            u_char *cp = (unsigned char *)LLADDR(sdl);
            
            mAddr = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        }
        else
            mAddr = nil;
    }
    
    if (found_entry == 0) {
        return nil;
    } else {
        return mAddr;
    }
}

+ (NSString *)getUniqueIdentifierString
{
    NSString *gatewayIPAddress = [self getGatewayIPAddress];
    NSString *gatewayMacAddress = [self getMacAddressFromIP:gatewayIPAddress];
    
    if (!gatewayMacAddress || !([[gatewayMacAddress componentsSeparatedByString:@":"] count] == 6))
        return nil;
    
    NSString *signatureKey = [NSString stringWithFormat:@"%@&%@", [[NSBundle mainBundle] bundleIdentifier], [NSString stringWithFormat:@"%@.RouterDevice", [[NSBundle mainBundle] bundleIdentifier]]];
    NSString *signatureString = [NSString stringWithFormat:@"%@&%@", gatewayMacAddress, gatewayIPAddress];
    
    const char *cKey  = [signatureKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [signatureString cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_MD5_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    CFUUIDBytes bytes;
    [HMAC getBytes:&bytes];
    CFUUIDRef UUIDRef = CFUUIDCreateFromUUIDBytes(NULL, bytes);
    
    return (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, UUIDRef));
}

- (NSURLRequest *)createRequestWithPort:(NSNumber *)port path:(NSString *)path parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)HTTPMethod
{
    NSString *gatewayIPAddress = self.gatewayIPAddress;
    
    if (![self uniqueIdentifierString])
        return nil;
    
    NSMutableString *host = [NSMutableString stringWithString:@""];
    
    if (([self.username isKindOfClass:[NSString class]] && ![self.username isEqualToString:@""]) && ([self.password isKindOfClass:[NSString class]] && ![self.password isEqualToString:@""]))
        [host appendFormat:@"%@:%@@", self.username, self.password];
    
    [host appendString:gatewayIPAddress];
    
    if (port)
        [host appendFormat:@":%@", [port stringValue]];
    
    NSString *HTTPBodyString;
    
    if (parameters && [parameters count]) {
        NSMutableArray *parts = [NSMutableArray array];
        
        for (id key in parameters)
        {
            @autoreleasepool {
                NSString *part;
                id value;
                value = [parameters objectForKey:key];
                part = [NSString stringWithFormat:@"%@=%@", ([key isKindOfClass:[NSString class]] ? [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] : key), ([value isKindOfClass:[NSString class]] ? [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] : value)];
                [parts addObject:part];
            }
        }
        
        [parts sortUsingSelector:@selector(compare:)];
        
        HTTPBodyString = [parts componentsJoinedByString:@"&"];
    }
    
    NSMutableString *newPath = [NSMutableString stringWithString:path];
    
    if (HTTPBodyString && ![HTTPMethod isEqualToString:@"POST"])
        [newPath appendFormat:@"?%@", HTTPBodyString];
    
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:[host copy] path:[newPath copy]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3.0f];
    
    request.HTTPMethod = HTTPMethod;
    
    if (HTTPBodyString && [HTTPMethod isEqualToString:@"POST"]) {
        request.HTTPBody = [HTTPBodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [request copy];
}

@end
