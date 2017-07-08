//
//  BloodPressureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodPressureContentView.h"
#import "PNChart.h"

@interface BloodPressureContentView () < PNChartDelegate >

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *BPLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
//@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UILabel *highBPLabel;
//@property (nonatomic, strong) UILabel *lowBPLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) PNCircleChart *bpCircleChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *xArr;
@property (nonatomic, weak) PNBarChart *lowBloodChart;
@property (nonatomic, weak) PNBarChart *highBloodChart;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) NSMutableArray *hbArr;
@property (nonatomic, strong) NSMutableArray *lbArr;
//@property (nonatomic, strong) UILabel *leftTimeLabel;
//@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;


@end

@implementation BloodPressureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBPData:) name:GET_BP_DATA object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = BP_HISTORY_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@((350.f / 360.f) * VIEW_FRAME_WIDTH));
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
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
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
        
        UILabel *todayBPLabel = [[UILabel alloc] init];
        [todayBPLabel setText:@"今日血压"];
        [todayBPLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [todayBPLabel setFont:[UIFont systemFontOfSize:14]];
        [_view1 addSubview:todayBPLabel];
        [todayBPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_view1.mas_centerY);
            make.left.equalTo(_view1.mas_left).offset(22);
        }];
        
        self.highBloodChart.backgroundColor = CLEAR_COLOR;
        self.lowBloodChart.backgroundColor = CLEAR_COLOR;
        [self.highBloodChart strokeChart];
        [self.lowBloodChart strokeChart];
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    [self.bpCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"点击了 BPBarChart 的%ld", barIndex);
//    [self.timeLabel setText:self.timeArr[barIndex]];
//    [self.highBPLabel setText:[NSString stringWithFormat:@"%@", self.hbArr[barIndex]]];
//    [self.lowBPLabel setText:[NSString stringWithFormat:@"%@", self.lbArr[barIndex]]];
}


#pragma mark - Action
- (void)showHisVC:(UIButton *)sender
{
//    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
//    vc.vcType = ViewControllerTypeBP;
//    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)getBPData:(NSNotification *)noti
{
//    manridyModel *model = [noti object];
//    if (model.bloodModel.bloodState == BloodDataHistoryData || model.bloodModel.bloodState == BloodDataUpload) {
//        if ([model.bloodModel.highBloodString isEqualToString:@"0"] && [model.bloodModel.lowBloodString isEqualToString:@"0"]) {
//            [self.BPLabel setText:@"--"];
//            [self.lastTimeLabel setText:@""];
//        }else {
//            [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@", model.bloodModel.highBloodString, model.bloodModel.lowBloodString]];
//            NSString *monthStr = [model.bloodModel.dayString substringWithRange:NSMakeRange(5, 2)];
//            NSString *dayStr = [model.bloodModel.dayString substringWithRange:NSMakeRange(8, 2)];
//            NSString *timeStr = [model.bloodModel.timeString substringWithRange:NSMakeRange(0, 5)];
//            self.lastTimeLabel.text = [NSString stringWithFormat:@"%@月%@日 %@", monthStr, dayStr, timeStr];
//        }
//    }
}

/** 更新视图 */
- (void)updateBPUIWithDataArr:(NSArray *)dbArr
{
    /**
     1.更新血压记录的柱状图
     */
    float sumLowBp = 0;
    float sumHighBp = 0;
    [self.timeArr removeAllObjects];
    [self.hbArr removeAllObjects];
    [self.lbArr removeAllObjects];
    if (dbArr.count == 0) {
        [self showNoDataView];
        return ;
    }else  {
        self.noDataLabel.hidden = YES;
        for (NSInteger index = 0; index < dbArr.count; index ++) {
            BloodModel *model = dbArr[index];
            sumLowBp = sumLowBp + model.lowBloodString.floatValue;
            sumHighBp = sumHighBp + model.highBloodString.floatValue;
            [self.timeArr addObject:[model.timeString substringToIndex:5]];
            [self.hbArr addObject:@(model.highBloodString.integerValue)];
            [self.lbArr addObject:@(model.lowBloodString.integerValue)];
            [self.xArr addObject:@""];
//            if (index == 0) {
//                [self.leftTimeLabel setText:[model.timeString substringToIndex:5]];
//            }
//            if (index == dbArr.count - 1) {
//                [self.rightTimeLabel setText:[model.timeString substringToIndex:5]];
//            }
        }
    }

    BloodModel *model = dbArr.lastObject;
    [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@",model.highBloodString, model.lowBloodString]];
    [self.lastTimeLabel setText:[NSString stringWithFormat:@"%@ %@", model.dayString, model.timeString]];
//    [self.timeLabel setText:[model.timeString substringToIndex:5]];
//    [self.highBPLabel setText:model.highBloodString];
//    [self.lowBPLabel setText:model.lowBloodString];
    
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
    [self.lowBloodChart setXLabels:self.xArr];
    [self.lowBloodChart setYValues:self.lbArr];
//    [self.lowBloodChart strokeChart];
    [self.lowBloodChart updateChartData:self.lbArr];
    
    [self.highBloodChart setXLabels:self.xArr];
    [self.highBloodChart setYValues:self.hbArr];
//    [self.highBloodChart strokeChart];
    [self.highBloodChart updateChartData:self.hbArr];
}

- (void)showNoDataView
{
    self.noDataLabel.hidden = NO;
    [self.BPLabel setText:@"--"];
    [self.lastTimeLabel setText:@""];
//    [self.timeLabel setText:@"--"];
//    [self.highBPLabel setText:@"--"];
//    [self.lowBPLabel setText:@"--"];
}

#pragma mamrk - 懒加载
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
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(-11);
            make.right.equalTo(self.mas_right).offset(-11);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _lowBloodChart = view;
    }
    
    return _lowBloodChart;
}

- (PNBarChart *)highBloodChart
{
    if (!_highBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] init];
        view.delegate = self;
        [view setStrokeColor:COLOR_WITH_HEX(0x4caf50, 0.54)];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.barWidth = 12;
        view.showLabel = YES;
        view.showChartBorder = YES;
        view.isShowNumbers = YES;
        view.isGradientShow = YES;
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _highBloodChart = view;
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

- (NSMutableArray *)xArr
{
    if (!_xArr) {
        _xArr = [NSMutableArray array];
    }
    
    return _xArr;
}

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

@end
