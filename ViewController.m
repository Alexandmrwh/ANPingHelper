//
//  ViewController.m
//  ANPingHelper
//
//  Created by 吴涵 on 2016/12/7.
//  Copyright © 2016年 吴涵. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
- (IBAction)startscan:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scanner {
    ANPingHandler * handler = [[ANPingHandler alloc] init];
    
    NSDictionary * res = getNetInfo();
    NSString * ip = [res objectForKey: @"addr"];
    NSString * mask = [res objectForKey: @"mask"];
    [handler pingGroupIP: ip with: mask];

}
- (IBAction)startscan:(id)sender {

    NSThread * scanthread = [[NSThread alloc]initWithTarget:self selector: @selector(scanner) object:nil];
    [scanthread start];
    NSLog(@"main thread: %@", [NSThread currentThread]);
 
}
@end
