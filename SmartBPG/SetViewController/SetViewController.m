//
//  SetViewController.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/23.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "SetViewController.h"
#import "SettingTableViewCell.h"
#import "SettingHeaderView.h"

static NSString *const settingCellID = @"settingCell";

@interface SetViewController () < UITableViewDelegate, UITableViewDataSource >
{
    BOOL _isAuthorization;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *groupSecondDataSourceArr;
@property (nonatomic, strong) NSArray *vcArray;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.view.backgroundColor = BP_HISTORY_BACKGROUND_COLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getElectricity:) name:SET_FIRMWARE object:nil];
    self.headImageView.backgroundColor = WHITE_COLOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //移除 tableview，在 viewWillAppear 中重新创建
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getElectricity:(NSNotification *)noti
{
//    manridyModel *model = [noti object];
//    if (model.firmwareModel.mode == FirmwareModeGetElectricity) {
//        //电量
//        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.PerElectricity forKey:ELECTRICITY_INFO_SETTING];
//        self.groupFirstDataSourceArr = nil;
//        [self.tableView reloadData];
//    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupSecondDataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCellID];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.model = self.groupSecondDataSourceArr[indexPath.row];
    return cell;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = CLEAR_COLOR;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.left.equalTo(view.mas_left);
        make.right.equalTo(view.mas_right);
        make.bottom.equalTo(view.mas_top).offset(8);
    }];
    
    UILabel *functionChooseLabel = [[UILabel alloc] init];
    [functionChooseLabel setText:@"功能设置"];
    [functionChooseLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [functionChooseLabel setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:functionChooseLabel];
    [functionChooseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(16);
        make.centerY.equalTo(view.mas_centerY).offset(4);
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    id pushVC = [[NSClassFromString(self.vcArray[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:pushVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        
        [self.view addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_top).offset(150 * SCREEN_WIDTH / 375);
            make.width.equalTo(@150);
            make.height.equalTo(@150);
        }];
        _headImageView.layer.cornerRadius = 75;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.borderWidth = 1;
        _headImageView.layer.borderColor = WHITE_COLOR.CGColor;
        _headImageView.backgroundColor = WHITE_COLOR;
    }
    
    return _headImageView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        /** 注册 cell 和 headerView */
//        [_tableView registerNib:[UINib nibWithNibName:@"SettingPeripheralTableViewCell" bundle:nil] forCellReuseIdentifier:periperlCellID];
        [_tableView registerClass:NSClassFromString(@"SettingTableViewCell") forCellReuseIdentifier:settingCellID];
//        [_tableView registerNib:[UINib nibWithNibName:@"SettingTableViewCell" bundle:nil] forCellReuseIdentifier:settingCellID];
//        [_tableView registerClass:NSClassFromString(@"SettingHeaderView") forHeaderFooterViewReuseIdentifier:settingHeaderID];
        _tableView.scrollEnabled = NO;
        
        /** 偏移掉表头的 64 个像素 */
        _tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
        _tableView.backgroundColor = CLEAR_COLOR;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsMultipleSelection = NO;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(300 * SCREEN_WIDTH / 375);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    return _tableView;
}

- (NSArray *)groupSecondDataSourceArr
{
    if (!_groupSecondDataSourceArr) {
        NSArray *fucName = @[@"用户信息",@"设备绑定",@"关于"];
        NSArray *imageName = @[@"set_user_icon",@"set_ble_icon",@"set_about_icon"];
        NSMutableArray *dataArr = [NSMutableArray array];
        for (int i = 0; i < fucName.count; i ++) {
            SettingCellModel *model = [[SettingCellModel alloc] init];
            model.fucName = fucName[i];
            model.headImageName = imageName[i];
            [dataArr addObject:model];
        }
        _groupSecondDataSourceArr = [NSArray arrayWithArray:dataArr];
    }
    
    return _groupSecondDataSourceArr;
}

- (NSArray *)vcArray
{
    if (!_vcArray) {
        _vcArray = @[@"UserInfoViewController", @"BindPeripheralViewController", @"VersionUpdateViewController"];
    }
    
    return _vcArray;
}

@end
