//
//  CommonUtils.h
//  ScanUtils
//
//  Created by 吴涵 on 16/9/21.
//  Copyright © 2016年 吴涵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <pthread.h>
#include <arpa/inet.h>
#import  <ifaddrs.h>

unsigned long getUnsignedlongIp(unsigned long ip);
NSString * getIpFromUnsignedLong(unsigned long ipInUL);
NSDictionary * getNetInfo();
NSDictionary * getIpRange(char ip[], char netmask[]);
