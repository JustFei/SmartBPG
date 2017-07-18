//
//  BPHisViewController.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/23.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "BPHisViewController.h"
#import "BPHisContentView.h"
#import "HooDatePicker.h"

@interface BPHisViewController () <HooDatePickerDelegate>
{
    NSString *_todayStr;
}

@property (nonatomic, strong) BPHisContentView *bpView;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) HooDatePicker *datePicker;

@end

@implementation BPHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //left
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 20, 20)];
    [leftButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor whiteColor];
    [leftButton setTitle:@"fanhui" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //right
    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 50, 20)];
    //[leftButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(showMonthController:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.tintColor = [UIColor whiteColor];
    [_rightButton setTitle:@"本月" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //title
    self.title = @"历史记录";
    
    _bpView = [[BPHisContentView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bpView];
    [_bpView setBackgroundColor:WHITE_COLOR];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.bpView) {
        [self.bpView removeFromSuperview];
    }
}

#pragma mark - Action
- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMonthController:(UIButton *)sender
{
    [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];   //让时区正确
    NSDate *maxDate = [NSDate date];
    //self.datePicker.minimumDate = minDate;//设置显示的最小日期
    self.datePicker.maximumDate = maxDate;//设置显示的最大日期
    [self.datePicker setTintColor:TEXT_BLACK_COLOR_LEVEL3];//设置主色
    //默认日期一定要最后设置，否在会被覆盖成当天的日期(貌似没什么效果)
    [self.datePicker setDate:[sender.titleLabel.text isEqualToString:@"本月"] ? [NSDate date] : [dateFormatter dateFromString:sender.titleLabel.text]];
    
    [self.datePicker show];
}

#pragma mark - HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date
{
    //    NSLog(@"%@",datePicker.date);
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy/MM"];
    //    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //    NSString *currentDateString = [formatter stringFromDate:datePicker.date];
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender
{
    [datePicker dismiss];
}

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8 * 3600]];
    NSString *currentDateString = [formatter stringFromDate:date];
    
    [self.rightButton setTitle:[currentDateString isEqualToString:_todayStr] ? @"本月" : currentDateString forState:UIControlStateNormal];
    if (date) {
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                               inUnit:NSCalendarUnitMonth
                              forDate:date];
        [self.bpView getHistoryDataWithIntDays:days.length withDate:date];
    }
}

#pragma mark - lazy
- (HooDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    
    return _datePicker;
}

@end
