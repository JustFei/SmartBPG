//
//  BPViewController.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/22.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "BPViewController.h"
#import "BloodPressureContentView.h"
#import "BPHisViewController.h"
#import "SetViewController.h"

@interface BPViewController ()

@end

@implementation BPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //left
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 20, 20)];
    //    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"all_data_icon"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(showHistoryView) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor whiteColor];
    [leftButton setTitle:@"fanhui" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //title
    self.title = @"血压";
    
    //right
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 17, 20, 20)];
    //    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"all_set_icon"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    rightButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.navigationBar.barTintColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    BloodPressureContentView *bpView = [[BloodPressureContentView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bpView];
    [bpView setBackgroundColor:WHITE_COLOR];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:0];
}

#pragma mark - Action
- (void)showHistoryView
{
    BPHisViewController *vc = [[BPHisViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSettingView
{
    SetViewController *vc = [[SetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
