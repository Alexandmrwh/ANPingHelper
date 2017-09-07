//
//  CommonUtils.m
//  ScanUtils
//
//  Created by 吴涵 on 16/9/21.
//  Copyright © 2016年 吴涵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonUtils.h"
/*************************************************
  Function:
        Turn ip into computable unsigned long
 *************************************************/
unsigned long getUnsignedlongIp(unsigned long ip) {
    
    unsigned char b1,b2,b3,b4;
    
    b1 = ip & 0x00FF;
    b2 = (ip >> 8) & 0x00FF;
    b3 = (ip >> 16) & 0x00FF;
    b4 = (ip >> 24) & 0x00FF;
    
    return (b1 <<24) | (b2 << 16) | (b3 << 8) | b4;
}

/*************************************************
  Function:
        Turn unsigned long into string
 *************************************************/
NSString * getIpFromUnsignedLong(unsigned long ipInUL) {
    unsigned char b1,b2,b3,b4;
    
    b1 = ipInUL & 0x00FF;
    b2 = (ipInUL >> 8) & 0x00FF;
    b3 = (ipInUL >> 16) & 0x00FF;
    b4 = (ipInUL >> 24) & 0x00FF;
    
    NSString * ipString = [NSString stringWithFormat:@"%@.%@.%@.%@",[NSNumber numberWithUnsignedChar:b4], [NSNumber numberWithUnsignedChar:b3],[NSNumber numberWithUnsignedChar:b2],[NSNumber numberWithUnsignedChar:b1]];
    
    return ipString;
}

/*************************************************
  Function:
        Get local address and mask
  Return:
        NSDictionary contains "addr" and "mask"
 *************************************************/
NSDictionary * getNetInfo() {
    NSString * address = [[NSString alloc]init];
    NSString * netmask = [[NSString alloc]init];
    NSDictionary * result = [[NSDictionary alloc]init];
    struct ifaddrs * interfaces = NULL;
    struct ifaddrs * temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    netmask = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr));
                    result = @{@"addr":address,
                               @"mask":netmask};
                    
                    //DEBUG
                    NSLog(@"result:%@", result);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return result;
}

/*************************************************
  Function:
        Get network address and broadcast address
  Parameters:
        local address and mask in char[]
  Return:
        NSDictionary contains "netIp" and "broadIp"
 *************************************************/
NSDictionary * getIpRange(char ip[], char netmask[]) {
    struct in_addr addr;
    struct in_addr mask;
    struct in_addr netIp;
    struct in_addr broadIp;
    NSString * netIpString = [[NSString alloc]init];
    NSString * broadIpString = [[NSString alloc]init];
    NSDictionary * result = [[NSDictionary alloc]init];
    
    if(inet_aton(ip, &addr) == 0) {
        perror("inet_aton error");
        exit(2);
    }
    if(inet_aton(netmask, &mask) == 0) {
        perror("inet_aton error");
        exit(2);
    }
    
    netIp.s_addr = addr.s_addr & mask.s_addr;
    broadIp.s_addr = addr.s_addr | (~mask.s_addr);
    
    netIpString = [NSString stringWithUTF8String:inet_ntoa(netIp)];
    broadIpString = [NSString stringWithUTF8String:inet_ntoa(broadIp)];
    result = @{@"netIp":netIpString,
               @"broadIp":broadIpString};
    
    //DEBUG
    NSLog(@"result:%@",result);
    
    return result;
}







