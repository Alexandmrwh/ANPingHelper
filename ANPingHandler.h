//
//  ANPingHandler.h
//  ANPingHelper
//
//  Created by 吴涵 on 2016/12/7.
//  Copyright © 2016年 吴涵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"
#import "CommonUtils.h"
#import "ANPingHelperMarco.h"
@interface ANPingHandler : NSObject <SimplePingDelegate>
{
    NSString * host;
    SimplePing * pinger;
    NSTimer * sendTimer;
}
@property(nonatomic, strong) NSString * host;
@property(nonatomic, strong) SimplePing * pinger;
@property(nonatomic, strong) NSTimer * sendTimer;
-(id)initPingHandler;
-(void)PingOneIP: (NSString *) address;
-(void)PingGroupIP: (NSString *) localip with: (NSString *)netmask;
@end
