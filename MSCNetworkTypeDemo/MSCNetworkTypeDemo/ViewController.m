//
//  ViewController.m
//  MSCNetworkTypeDemo
//
//  Created by MiaoShichang on 15/10/27.
//  Copyright © 2015年 MiaoShichang. All rights reserved.
//

#import "ViewController.h"

#import "MSCNetworkTypeMonitor.h"

@interface ViewController ()
@property (nonatomic, strong)UILabel *networkTypeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.networkTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 44)];
    self.networkTypeLabel.textColor = [UIColor orangeColor];
    self.networkTypeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.networkTypeLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kMSCNetworkTypeChangedNotification
                                               object: nil];
    
    // 获取网络类型
    MSCNetworkType type = [MSCNetworkTypeMonitor sharedInstance].networkType;
    self.networkTypeLabel.text = [self networkTypeName:type];
}

// 网络类型发生改变
- (void)reachabilityChanged:(NSNotification *)note
{
    MSCNetworkTypeMonitor* monitor = [note object];
    MSCNetworkType status = monitor.networkType;
    NSString *name = [self networkTypeName:status];
    
    self.networkTypeLabel.text = name;
    
}
- (NSString *)networkTypeName:(MSCNetworkType)networkType
{
    NSString *string = @"*****";
    
    switch (networkType)
    {
        case kMSCNetworkTypeNone:
            NSLog(@"NotReachable");
            string = @"NotReachable";
            break;
            
        case kMSCNetworkTypeWiFi:
            NSLog(@"ReachableViaWiFi");
            string = @"ReachableViaWiFi";
            break;
            
        case kMSCNetworkTypeWWAN:
            NSLog(@"ReachableViaWWAN");
            string = @"ReachableViaWWAN";
            break;
            
        case kMSCNetworkType2G:
            NSLog(@"kReachableVia2G");
            string = @"kReachableVia2G";
            break;
            
        case kMSCNetworkType3G:
            NSLog(@"kReachableVia3G");
            string = @"kReachableVia3G";
            break;
            
        case kMSCNetworkType4G:
            NSLog(@"kReachableVia4G");
            string = @"kReachableVia4G";
            break;
        default:
            NSLog(@"default");
            string = @"default";
            break;
    }
    
    return string;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
