//
//  VersionUpdateViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "VersionUpdateViewController.h"
#import "VersionUpdateTableViewCell.h"
//#import "AFNetworking.h"

static NSString *const VersionUpdateTableViewCellID = @"VersionUpdateTableViewCell";

@interface VersionUpdateViewController () < UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) MDToast *loadingToast;

@end

@implementation VersionUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"检查升级";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.tableView.backgroundColor = CLEAR_COLOR;
    self.view.backgroundColor = BP_HISTORY_BACKGROUND_COLOR;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VersionUpdateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VersionUpdateTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    
    cell.updateActionBlock = ^{
        
            self.loadingToast = [[MDToast alloc] initWithText:@"检查更新中" duration: 10000];
            [self.loadingToast show];
            [self.loadingToast setText:@"暂无更新"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.loadingToast dismiss];
            });
    };
    
    return cell;
}



#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(VersionUpdateTableViewCellID) forCellReuseIdentifier:VersionUpdateTableViewCellID];
        _tableView.allowsSelection = NO;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        VersionModel *model0 = [VersionModel modelWithTitle:@"软件版本" andVersion:app_Version];
        model0.versionType = VersionTypeSoftware;
        NSString *hardware_Version = [[NSUserDefaults standardUserDefaults] objectForKey:HARDWARE_VERSION];
        VersionModel *model1 = [VersionModel modelWithTitle:@"硬件版本" andVersion:hardware_Version == nil ? @"" : hardware_Version];
        model1.versionType = VersionTypeHardware;
        
        _dataArr = @[model0, model1];
    }
    
    return _dataArr;
}

@end
