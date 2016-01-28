//
//  DemoNavController.m
//  TCLogDemo
//
//  Created by Andrew on 16/1/28.
//  Copyright © 2016年 Tecomtech. All rights reserved.
//

#import "DemoNavController.h"
#import "TCLog.h"

@implementation DemoNavController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TCLOG_SHOWCUSTOM_LOG;
}

@end
