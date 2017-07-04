//
//  BPHisViewController.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/23.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "BPHisViewController.h"
#import "BPHisContentView.h"

@interface BPHisViewController ()

@end

@implementation BPHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //left
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 20, 20)];
    //    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"all_data_icon"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor whiteColor];
    [leftButton setTitle:@"fanhui" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //title
    self.title = @"历史记录";
    
    BPHisContentView *bpView = [[BPHisContentView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bpView];
    [bpView setBackgroundColor:WHITE_COLOR];
}

#pragma mark - Action
- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
