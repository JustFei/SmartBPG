//
//  BPHisContentView.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/23.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "BPHisContentView.h"
#import "FMDBManager.h"

@interface BPHisContentView () < PNChartDelegate >
{
    NSInteger highBlood;
    NSInteger lowBlood;
    NSInteger hr;
    NSInteger sumHb;
    NSInteger sumLb;
    NSInteger sumHr;
    
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_hbDataArr;
    NSMutableArray *_lbDataArr;
    NSMutableArray *_hrDataArr;
    NSMutableArray *_averageDataArr;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *BPLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic ,strong) UIScrollView *downScrollView;
@property (nonatomic, strong) PNCircleChart *bpCircleChart;
@property (nonatomic, weak) PNBarChart *lowBloodChart;
@property (nonatomic, weak) PNBarChart *highBloodChart;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) NSMutableArray *hbArr;
@property (nonatomic, strong) NSMutableArray *lbArr;
@property (nonatomic, strong) NSMutableArray *bpmArr;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UILabel *todayBPLabel;
@property (nonatomic, strong) FMDBManager *myFmdbManager;


@end

@implementation BPHisContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
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
        
        self.downScrollView = [[UIScrollView alloc] init];
        self.downScrollView.contentSize = CGSizeMake(2 * VIEW_FRAME_WIDTH, 0);
        self.downScrollView.bounces = NO;
        self.downScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.downScrollView];
        [self.downScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        self.highBloodChart.backgroundColor = CLEAR_COLOR;
        self.lowBloodChart.backgroundColor = CLEAR_COLOR;
        
        //获取这个月的天数
        NSDate *today = [NSDate date]; //Get a date object for today's date
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                               inUnit:NSCalendarUnitMonth
                              forDate:today];
        _dateArr = [NSMutableArray array];
        _lbDataArr = [NSMutableArray array];
        _hbDataArr = [NSMutableArray array];
        _hrDataArr = [NSMutableArray array];
        _averageDataArr = [NSMutableArray array];
        
        for (int i = 1; i <= days.length; i ++) {
            [_dateArr addObject:@(i)];
        }
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //绘制图表放在这里不会造成UI卡顿
    [self getHistoryDataWithIntDays:_dateArr.count withDate:[NSDate date]];
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

#pragma mark - UpdateUI
//#pragma mark - DB
- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    [_hbDataArr removeAllObjects];
    [_lbDataArr removeAllObjects];
    [_hrDataArr removeAllObjects];
    [_averageDataArr removeAllObjects];
    
    haveDataDays = 0;
    sumHb = 0;
    sumLb = 0;
    sumHr = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld/%02ld",(long)iCurYear ,iCurMonth ,i];
            NSLog(@"%@",dateStr);
            highBlood = 0;
            lowBlood = 0;
            hr = 0;
            NSArray *queryArr = [self.myFmdbManager queryBlood:dateStr WithType:QueryTypeWithDay];
            if (queryArr.count == 0) {
                [_hbDataArr addObject:@0];
                [_lbDataArr addObject:@0];
                [_hrDataArr addObject:@0];
            }else {
                
                for (BloodModel *model in queryArr) {
                    highBlood += model.highBloodString.integerValue;
                    lowBlood += model.lowBloodString.integerValue;
                    hr += model.bpmString.integerValue;
                }
                sumHb += highBlood / queryArr.count;
                sumLb += lowBlood / queryArr.count;
                sumHr += hr / queryArr.count;
                //当天的平均高，低压
                [_hbDataArr addObject:[NSString stringWithFormat:@"%ld",highBlood / queryArr.count]];
                [_lbDataArr addObject:[NSString stringWithFormat:@"%ld",lowBlood / queryArr.count]];
                [_hrDataArr addObject:[NSString stringWithFormat:@"%ld",hr / queryArr.count]];
                haveDataDays ++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger averageHb = sumHb / haveDataDays;
            NSInteger averageLb = sumLb / haveDataDays;
            NSInteger averageHr = sumHr / haveDataDays;
            [self.BPLabel setText:[NSString stringWithFormat:@"%ld/%ld",averageHb , averageLb]];
            [self.lastTimeLabel setText:[NSString stringWithFormat:@"心率:%ld",averageHr]];
            double progress = averageHb / 200.000;
            
            if (progress <= 1) {
                [self.bpCircleChart updateChartByCurrent:@(progress * 100)];
            }else if (progress >= 1) {
                [self.bpCircleChart updateChartByCurrent:@(100)];
            }
            
            [self.highBloodChart setYValues:_hbDataArr];
            [self.highBloodChart setXLabels:_dateArr];
            [self.lowBloodChart setYValues:_lbDataArr];
            [self.lowBloodChart setXLabels:_dateArr];
            
            [self.highBloodChart updateChartData:_hbDataArr];
            [self.lowBloodChart updateChartData:_lbDataArr];
        });
    });
}

- (void)getDataFromDBWithMonth
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    NSString *dayString = [formatter stringFromDate:[NSDate date]];
    
    NSArray *dbArr = [self.myFmdbManager queryBlood:dayString WithType:QueryTypeWithMonth];
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
        self.noDataLabel.hidden = YES;
        for (NSInteger index = 0; index < dbArr.count; index ++) {
            BloodModel *model = dbArr[index];
            [self.timeArr addObject:model.timeString];
            [self.hbArr addObject:@(model.highBloodString.integerValue)];
            [self.lbArr addObject:@(model.lowBloodString.integerValue)];
            [self.bpmArr addObject:@(model.bpmString.integerValue)];
        }
    }
    
    BloodModel *model = dbArr.lastObject;
    [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@",model.highBloodString, model.lowBloodString]];
    [self.lastTimeLabel setText:[NSString stringWithFormat:@"心率: %@", model.bpmString]];
    
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
    [self.lowBloodChart setXLabels:self.timeArr];
//    [self.lowBloodChart setYValues:self.lbArr];
    [self.lowBloodChart updateChartData:self.lbArr];
    
    [self.highBloodChart setXLabels:self.timeArr];
//    [self.highBloodChart setYValues:self.hbArr];
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
        view.barWidth = 5;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.barBackgroundColor = CLEAR_COLOR;
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(-5);
            make.right.equalTo(self.mas_right).offset(-5);
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
        [view setStrokeColor:COLOR_WITH_HEX(0x81c784, 0.54)];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.barWidth = 5;
        view.showLabel = YES;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.barBackgroundColor = CLEAR_COLOR;
        
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
