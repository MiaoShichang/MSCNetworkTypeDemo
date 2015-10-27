//
//  MSCNetworkTypeMonitor.m
//  MSCNetworkTypeDemo
//
//  Created by MiaoShichang on 15/10/27.
//  Copyright © 2015年 MiaoShichang. All rights reserved.
//

#import "MSCNetworkTypeMonitor.h"
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>


NSString * const kMSCNetworkTypeChangedNotification = @"kMSCNetworkTypeChangedNotification";

static void msc_reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    NSCAssert(info != NULL, @"info was NULL in msc_reachabilityCallback");
    
    if ([(__bridge NSObject *)info isKindOfClass:MSCNetworkTypeMonitor.class]) {
        MSCNetworkTypeMonitor* noteObject = (__bridge MSCNetworkTypeMonitor *)info;
        // Post a notification to notify the client that the network reachability changed.
        [[NSNotificationCenter defaultCenter] postNotificationName: kMSCNetworkTypeChangedNotification object: noteObject];
    }
    else {
#if DEBUG
        NSLog(@"【info was wrong class in msc_reachabilityCallback】");
#endif
    }
}

@interface MSCNetworkTypeMonitor ()
{
    SCNetworkReachabilityRef _reachabilityRef;
}

@end

@implementation MSCNetworkTypeMonitor

+ (instancetype)sharedInstance
{
    static dispatch_once_t s_onceToken;
    static id s_sharedInstance;
    
    dispatch_once(&s_onceToken, ^{
        s_sharedInstance = [self new];
    });
    
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setupMonitor];
        [self startMonitor];
    }
    
    return self;
}

#pragma mark - 辅助函数
- (void)setupMonitor
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    
    if (reachability != NULL)
    {
        self->_reachabilityRef = reachability;
    }
}

#pragma mark - Start and stop monitor
- (BOOL)startMonitor
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, msc_reachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)stopMonitor
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc
{
    [self stopMonitor];
    
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}

#pragma mark - Network Flag Handling
- (MSCNetworkType)networkTypeForFlags:(SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        return kMSCNetworkTypeNone;
    }
    
    MSCNetworkType returnValue = kMSCNetworkTypeNone;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        returnValue = kMSCNetworkTypeWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            returnValue = kMSCNetworkTypeWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        if (floor(NSFoundationVersionNumber) > floor(993.00)) // iOS 7+ (NSFoundationVersionNumber_iOS_6_1)
        {
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            
            if (currentRadioAccessTechnology)
            {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                {
                    returnValue =  kMSCNetworkType4G;
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
                {
                    returnValue =  kMSCNetworkType2G;
                }
                else
                {
                    returnValue =  kMSCNetworkType3G;
                }
                
                return returnValue;
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
        {
            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired)
            {
                returnValue =  kMSCNetworkType2G;
                return returnValue;
            }
            
            returnValue =  kMSCNetworkType3G;
            return returnValue;
        }
        
        returnValue = kMSCNetworkTypeWWAN;
    }
    
    return returnValue;
}

- (MSCNetworkType)currentNetworkType
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkType called with NULL SCNetworkReachabilityRef");
    
    MSCNetworkType returnValue = kMSCNetworkTypeNone;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)){
        returnValue = [self networkTypeForFlags:flags];
    }
    
    return returnValue;
}

- (MSCNetworkType)networkType
{
    return [self currentNetworkType];
}

@end

#pragma mark - 初始化单例
@interface UIResponder(EXNetState)
@end

@implementation UIResponder(EXNetState)

+(void)initialize
{
    if ([@"UIResponder" isEqualToString:NSStringFromClass(self.class)]) {
        NSLog(@"class:%@ -- initialize", NSStringFromClass(self.class));
        [MSCNetworkTypeMonitor sharedInstance];
    }
}

@end

