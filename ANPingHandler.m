//
//  ANPingHandler.m
//  ANPingHelper
//
//  Created by 吴涵 on 2016/12/7.
//  Copyright © 2016年 吴涵. All rights reserved.
//

#import "ANPingHandler.h"

@implementation ANPingHandler
@synthesize host;
@synthesize pinger;
@synthesize sendTimer;
-(id)initPingHandler {
    self = [super init];
    self.host = [[NSString alloc] init];
    return self;
}
- (void)pingOneIP: (NSString *) address {
    NSLog(@"**************thread: %@*************", [NSThread currentThread]);

    self.pinger = [[SimplePing alloc] initWithHostName: address];
    self.pinger.delegate = self;
    self.pinger.addressStyle = SimplePingAddressStyleICMPv4;
    [self.pinger start];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (self.pinger != nil);
    NSLog(@"ANPingOneIP Finished");
}
- (void)pingGroupIP: (NSString *) localip with: (NSString *)netmask {
    
    NSLog(@"**************thread: %@*************", [NSThread currentThread]);
    char ipchar[ipLength], maskchar[ipLength];
    char start[ipLength], end[ipLength];
    struct in_addr myIp;
    struct in_addr startIp, endIp;
    
    memcpy(ipchar, [localip cStringUsingEncoding:NSUTF8StringEncoding], 2*[localip length]);
    memcpy(maskchar, [netmask cStringUsingEncoding:NSUTF8StringEncoding], 2*[netmask length]);
    
    if(inet_aton(ipchar, &myIp) == 0) {
        perror("inet_aton error");
        exit(3);
    }
    
    //get ip range
    NSDictionary * res = getIpRange(ipchar, maskchar);
    
    NSString * net = [res objectForKey:@"netIp"];
    NSString * broad = [res objectForKey:@"broadIp"];
    memcpy(start, [net cStringUsingEncoding:NSUTF8StringEncoding], 2*[net length]);
    memcpy(end, [broad cStringUsingEncoding:NSUTF8StringEncoding], 2*[broad length]);
    
    if(inet_aton(start, &startIp) == 0) {
        perror("inet_aton error");
        exit(3);
    }
    if(inet_aton(end, &endIp) == 0) {
        perror("inet_aton error");
        exit(3);
    }
    
    unsigned long startInUL = getUnsignedlongIp(startIp.s_addr + 0x1000000);
    unsigned long endInUL = getUnsignedlongIp(endIp.s_addr - 0x1000000);
    unsigned long myInUL = getUnsignedlongIp(myIp.s_addr);
    unsigned long pingInUL;
    

    int i =1;
    NSString * pingIpString = [[NSString alloc] init];
    for(pingInUL = myInUL-1; pingInUL >= startInUL; pingInUL-- ) {
        pingIpString = getIpFromUnsignedLong(pingInUL);
        self.pinger = [[SimplePing alloc] initWithHostName: pingIpString];
        self.pinger.delegate = self;
        self.pinger.addressStyle = SimplePingAddressStyleICMPv4;
        [self.pinger start];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (self.pinger != nil);
        NSLog(@"ip:%@,num:%d", pingIpString, i);
        i++;
    }
    
    for(pingInUL = myInUL + 1;pingInUL <= endInUL; pingInUL++ ) {
        pingIpString = getIpFromUnsignedLong(pingInUL);
        self.pinger = [[SimplePing alloc] initWithHostName: pingIpString];
        self.pinger.delegate = self;
        self.pinger.addressStyle = SimplePingAddressStyleICMPv4;
        [self.pinger start];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (self.pinger != nil);
        NSLog(@"ip:%@,num:%d", pingIpString, i);
        i++;
    }
    
}
- (void)stopPinger {
    self.pinger = nil;
}


/************************************************************/
//simpleping delegate
/************************************************************/
/*
 *  start成功
 */
// 发送测试报文数据
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [self.pinger sendPingWithData: nil];
    NSLog(@"didStartWithAddress");
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(stopPinger) userInfo: nil repeats: NO];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    self.pinger = nil;
    [self.pinger stop];
}
// 发送测试报文成功的回调方法
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"#%u sent", sequenceNumber);
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(stopPinger) userInfo: nil repeats: NO];
}

//发送测试报文失败的回调方法
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"#%u send failed: %@", sequenceNumber, error);
    self.pinger = nil;
}

// 接收到ping的地址所返回的数据报文回调方法
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    //todo：发送notification
    NSLog(@"didReceivePingResponsePacket");
    self.pinger = nil;
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    NSLog(@"didReceiveUnexpectedPacket");
    self.pinger = nil;
}

/************************************************************/
//simpleping delegate end
/************************************************************/
@end

