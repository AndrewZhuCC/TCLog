//
//  DemoViewController.m
//  TCLogDemo
//
//  Created by Andrew on 16/1/28.
//  Copyright © 2016年 Tecomtech. All rights reserved.
//

#import "DemoViewController.h"
#import "TCLog.h"
#import "DemoNavController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TCLOG_LIGHT(@"%@ : I am alive!",self);
    UIButton *btnf = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, 200, 30)];
    btnf.backgroundColor = [UIColor greenColor];
    [btnf addTarget:self action:@selector(btnfAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnf];
    
    UIButton *btns = [[UIButton alloc]initWithFrame:CGRectMake(10, 150, 200, 30)];
    btns.backgroundColor = [UIColor orangeColor];
    [btns addTarget:self action:@selector(btnsAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btns];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnfAction
{
    DemoViewController *vc = [[DemoViewController alloc]init];
    TCLOG_MID(@"%@ will be pushed!",vc);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnsAction
{
    DemoViewController *vc = [[DemoViewController alloc]init];
    DemoNavController *nvc = [[DemoNavController alloc]initWithRootViewController:vc];
    TCLOG_High(@"%@ will be present",nvc);
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
