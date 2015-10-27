//
//  MSCNetworkTypeMonitor.h
//  MSCNetworkTypeDemo
//
//  Created by MiaoShichang on 15/10/27.
//  Copyright © 2015年 MiaoShichang. All rights reserved.
//

#import <Foundation/Foundation.h>

// 网络类型值
typedef NS_ENUM(NSInteger, MSCNetworkType) {
    kMSCNetworkTypeNone = 0, //当前没有网络
    kMSCNetworkTypeWiFi,
    kMSCNetworkTypeWWAN,
    kMSCNetworkType2G,
    kMSCNetworkType3G,
    kMSCNetworkType4G,
};

/**
 说明：该类是一个单例类，请不要创建和初始化
 */
@interface MSCNetworkTypeMonitor : NSObject

/**
 *@brief 当前的网络状态
 */
@property (nonatomic, readonly)MSCNetworkType networkType;

/**
 *@brief 单例
 */
+ (instancetype)sharedInstance;

@end

/**
 *@brief 网络类型变化时的通知
 *通知中的object对象是MSCNetworkState类型，使用时查看Demo
 */
extern  NSString *const kMSCNetworkTypeChangedNotification;









