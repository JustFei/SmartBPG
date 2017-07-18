//
//  BloodPressureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodPressureContentView.h"
#import "PNChart.h"
#import "FMDBManager.h"

@interface BloodPressureContentView () < PNChartDelegate >

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *BPLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) FMDBManager *myFmdbManager;

//图表数据源和控件
@property (nonatomic, strong) PNCircleChart *bpCircleChart;
//@property (nonatomic, strong) NSMutableArray *xArr;
@property (nonatomic, strong) PNBarChart *lowBloodChart;
@property (nonatomic, strong) PNBarChart *highBloodChart;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) NSMutableArray *hbArr;
@property (nonatomic, strong) NSMutableArray *lbArr;
@property (nonatomic, strong) NSMutableArray *bpmArr;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) MDButton *startBtn;
@property (nonatomic, strong) UILabel *eleLabel;
@property (nonatomic, strong) UILabel *todayBPLabel;

@end

@implementation BloodPressureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        //血压压力值数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBPData:) name:BP_DATA object:nil];
        //血压计电量数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEleData:) name:ELECTRICITY_VALUE object:nil];
        //血压测量结果数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBPResultData:) name:BP_TEST_RESULT object:nil];
        //测量失败的结果
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithTestError:) name:BP_TEST_ERROR object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = BP_HISTORY_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@((350.f / 360.f) * VIEW_FRAME_WIDTH));
        }];
        
        _startBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
        [_startBtn setTitle:@"开始测量" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startTestAction:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:_startBtn];
        [_startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_upView.mas_left).offset(16);
            make.bottom.equalTo(_upView.mas_bottom).offset(-8);
        }];
        
        _eleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_eleLabel setText:@"电量：--"];
        [_eleLabel setTextColor:TEXT_WHITE_COLOR_LEVEL4];
        [_eleLabel setFont:[UIFont systemFontOfSize:14]];
        [_upView addSubview:_eleLabel];
        [_eleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_upView.mas_right).offset(-16);
            make.bottom.equalTo(_upView.mas_bottom).offset(-16);
        }];
        
        
        [self.bpCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.bpCircleChart strokeChart];
        
        [self.BPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.centerY.equalTo(self.bpCircleChart.mas_centerY);
        }];
        [self.BPLabel setText:@"--"];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"上次测量结果"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:15]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.bottom.equalTo(self.BPLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"bloodpressure_icon01"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.BPLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.width.equalTo(@(158 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@1);
        }];
        
        [self.lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.top.equalTo(lineView.mas_bottom).offset(2 * VIEW_FRAME_WIDTH / 360);
        }];
        
        _view1 = [[UIView alloc] init];
        _view1.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
        [self addSubview:_view1];
        [_view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.upView.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@(48 * VIEW_FRAME_WIDTH / 360));
        }];
        
        _todayBPLabel = [[UILabel alloc] init];
        [_todayBPLabel setText:@"今日血压"];
        [_todayBPLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_todayBPLabel setFont:[UIFont systemFontOfSize:14]];
        [_view1 addSubview:_todayBPLabel];
        [_todayBPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_view1.mas_centerY);
            make.left.equalTo(_view1.mas_left).offset(22);
        }];
        
        self.highBloodChart.backgroundColor = CLEAR_COLOR;
        self.lowBloodChart.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self getDataFromDBWithToday];
    });
}

- (void)drawProgress:(CGFloat )progress
{
    [self.bpCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"点击了 BPBarChart 的%ld", barIndex);
    [self.todayBPLabel setText:[NSString stringWithFormat:@"血压:%@/%@ 心率:%@ 测量时间:%@", self.hbArr[barIndex], self.lbArr[barIndex], self.bpmArr[barIndex], self.timeArr[barIndex]]];
}

#pragma mark - Action
- (void)startTestAction:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDidConnected) {
        if ([sender.titleLabel.text isEqualToString:@"开始测量"]) {
            [[BleManager shareInstance] writeBPCammandToPeripheral:WriteBPTestCammandStart];
            [sender setTitle:@"停止测量" forState:UIControlStateNormal];
        }else {
            [[BleManager shareInstance] writeBPCammandToPeripheral:WriteBPTestCammandEnd];
            [sender setTitle:@"开始测量" forState:UIControlStateNormal];
        }
    }else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"设备未连接";
        [hud hideAnimated:YES afterDelay:2];
    }
}

- (void)showHisVC:(UIButton *)sender
{
//    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
//    vc.vcType = ViewControllerTypeBP;
//    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

#pragma mark - NSNotification
//压力值的通知
- (void)getBPData:(NSNotification *)noti
{
    if (noti) {
        BloodModel *model = [noti object];
        [self.BPLabel setText:model.pressureString];
        NSLog(@"pressureString == %@", model.pressureString);
        [self.startBtn setTitle:@"停止测量" forState:UIControlStateNormal];
        float lowProgress = model.pressureString.floatValue / 200;
        
        if (lowProgress <= 1) {
            [self drawProgress:lowProgress];
        }else if (lowProgress >= 1) {
            [self drawProgress:1];
        }
        [self.bpCircleChart updateChartByCurrent:@(lowProgress)];
    }
}

//电量的通知
- (void)getEleData:(NSNotification *)noti
{
    if (noti) {
        BloodModel *model = [noti object];
        self.eleLabel.text = [NSString stringWithFormat:@"电量:%@%%", model.electricity];
    }
}

//血压计结果的通知
- (void)getBPResultData:(NSNotification *)noti
{
    if (noti) {
        BloodModel *model = [noti object];
        [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@", model.highBloodString, model.lowBloodString]];
        [self.startBtn setTitle:@"开始测量" forState:UIControlStateNormal];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM"];
        NSString *monthString = [formatter stringFromDate:[NSDate date]];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [formatter stringFromDate:[NSDate date]];
        [formatter setDateFormat:@"hh:mm"];
        NSString *timeString = [formatter stringFromDate:[NSDate date]];
        model.monthString = monthString;
        model.dayString = dayString;
        model.timeString = timeString;
        [self.myFmdbManager insertBloodModel:model];
        
        [self getDataFromDBWithToday];
    }
}

//错误通知
- (void)dealWithTestError:(NSNotification *)noti
{
    if (noti) {
        NSString *errorCode = [noti object];
        NSString *message;
        switch (errorCode.integerValue) {
            case 1:
                message = @"传感器信号异常";
                break;
            case 2:
                message = @"测量不出结果";
                break;
            case 3:
                message = @"测量结果异常";
                break;
            case 4:
                message = @"腕带过松或漏气";
                break;
            case 5:
                message = @"腕带过紧或气路堵塞";
                break;
            case 6:
                message = @"测量中压力干扰严重";
                break;
            case 7:
                message = @"压力超 300";
                break;
                
            default:
                break;
        }
        if (message.length > 0) {
            UIAlertController *errorVC = [UIAlertController alertControllerWithTitle:@"错误" message: message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAc  = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [errorVC addAction:sureAc];
            [[self findViewController:self] presentViewController:errorVC animated:YES completion:nil];
            [self.startBtn setTitle:@"开始测量" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UpdateUI
- (void)getDataFromDBWithToday
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy/MM/dd"];
//    NSString *dayString = [formatter stringFromDate:[NSDate date]];
    
    NSArray *dbArr = [self.myFmdbManager queryBlood:@"7" WithType:QueryTypeWithLastCount];
    [self updateBPUIWithDataArr:dbArr];
}

/** 更新视图 */
- (void)updateBPUIWithDataArr:(NSArray *)dbArr
{
    /**
     1.更新血压记录的柱状图
     */
//    float sumLowBp = 0;
//    float sumHighBp = 0;
    [self.timeArr removeAllObjects];
    [self.hbArr removeAllObjects];
    [self.lbArr removeAllObjects];
    [self.bpmArr removeAllObjects];
    if (dbArr.count == 0) {
        [self showNoDataView];
        return ;
    }else  {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [formatter stringFromDate:[NSDate     date]];
        
        self.noDataLabel.hidden = YES;
        for (NSInteger index = 0; index < dbArr.count; index ++) {
            BloodModel *model = dbArr[index];
            if ([model.dayString isEqualToString:dayString]) {
                [self.timeArr addObject:model.timeString];
                [self.hbArr addObject:@(model.highBloodString.integerValue)];
                [self.lbArr addObject:@(model.lowBloodString.integerValue)];
                [self.bpmArr addObject:@(model.bpmString.integerValue)];
            }
        }
        if (self.timeArr.count == 0) {
            return;
        }
    }

    BloodModel *model = dbArr.lastObject;
    if (model.highBloodString.length > 0 && model.lowBloodString.length > 0) {
        [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@",model.highBloodString, model.lowBloodString]];
    }else {
        [self.BPLabel setText:@"--"];
    }
    if (model.bpmString.length > 0) {
        [self.lastTimeLabel setText:[NSString stringWithFormat:@"心率: %@", model.bpmString]];
    }else {
        [self.lastTimeLabel setText:@"心率:--"];
    }
    
    
    float lowProgress = model.lowBloodString.floatValue / 200;
    
    if (lowProgress <= 1) {
        [self drawProgress:lowProgress];
    }else if (lowProgress >= 1) {
        [self drawProgress:1];
    }
    [self.bpCircleChart updateChartByCurrent:@(lowProgress)];
    [self showChartViewWithData];
}

- (void)showChartViewWithData
{
    [self.lowBloodChart strokeChart];
    [self.lowBloodChart setXLabels:self.timeArr];
    [self.lowBloodChart updateChartData:self.lbArr];
    [self.highBloodChart strokeChart];
    [self.highBloodChart setXLabels:self.timeArr];
    [self.highBloodChart updateChartData:self.hbArr];
}

- (void)showNoDataView
{
    self.noDataLabel.hidden = NO;
    [self.BPLabel setText:@"--"];
    [self.lastTimeLabel setText:@""];
}

#pragma mark - lazy
- (PNCircleChart *)bpCircleChart
{
    if (!_bpCircleChart) {
        _bpCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:BP_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_bpCircleChart setStrokeColor:BP_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_bpCircleChart];
    }
    
    return _bpCircleChart;
}

- (PNBarChart *)lowBloodChart
{
    if (!_lowBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] init];
        view.delegate = self;
        [view setStrokeColor:COLOR_WITH_HEX(0x81c784, 0.54)];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.showLabel = NO;
        view.barWidth = 12;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.barBackgroundColor = CLEAR_COLOR;
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(-11);
            make.right.equalTo(self.mas_right).offset(-11);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _lowBloodChart = view;
        [_lowBloodChart strokeChart];
    }
    
    return _lowBloodChart;
}

- (PNBarChart *)highBloodChart
{
    if (!_highBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] init];
        view.delegate = self;
        [view setStrokeColor:COLOR_WITH_HEX(0x81c784, 0.54)];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.barWidth = 12;
        view.showLabel = YES;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.barBackgroundColor = CLEAR_COLOR;
        
        [self addSubview:view];
        [view strokeChart];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _highBloodChart = view;
        [_highBloodChart strokeChart];
    }
    
    return _highBloodChart;
}

- (UILabel *)BPLabel
{
    if (!_BPLabel) {
        _BPLabel = [[UILabel alloc] init];
        [_BPLabel setTextColor:WHITE_COLOR];
        [_BPLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self addSubview:_BPLabel];
    }
    
    return _BPLabel;
}

- (UILabel *)lastTimeLabel
{
    if (!_lastTimeLabel) {
        _lastTimeLabel = [[UILabel alloc] init];
        [_lastTimeLabel setTextColor:WHITE_COLOR];
        [_lastTimeLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_lastTimeLabel];
    }
    
    return _lastTimeLabel;
}

//- (NSMutableArray *)xArr
//{
//    if (!_xArr) {
//        _xArr = [NSMutableArray array];
//    }
//    
//    return _xArr;
//}

- (NSMutableArray *)timeArr
{
    if (!_timeArr) {
        _timeArr = [NSMutableArray array];
    }
    
    return _timeArr;
}

- (NSMutableArray *)hbArr
{
    if (!_hbArr) {
        _hbArr = [NSMutableArray array];
    }
    
    return _hbArr;
}

- (NSMutableArray *)lbArr
{
    if (!_lbArr) {
        _lbArr = [NSMutableArray array];
    }
    
    return _lbArr;
}

- (NSMutableArray *)bpmArr
{
    if (!_bpmArr) {
        _bpmArr = [NSMutableArray array];
    }
    
    return _bpmArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.highBloodChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.highBloodChart.mas_centerX);
            make.centerY.equalTo(self.highBloodChart.mas_centerY);
        }];
    }
    
    return _noDataLabel;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:DB_NAME];
    }
    
    return _myFmdbManager;
}

@end
