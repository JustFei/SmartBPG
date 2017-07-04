//
//  AnalysisProcotolTool.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AnalysisProcotolTool.h"
#import "manridyModel.h"
#import "NSStringTool.h"

@interface AnalysisProcotolTool ()<CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation AnalysisProcotolTool

#pragma mark - Singleton
static AnalysisProcotolTool *analysisProcotolTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analysisProcotolTool = [[self alloc] init];
    });
    
    return analysisProcotolTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analysisProcotolTool = [super allocWithZone:zone];
    });
    
    return analysisProcotolTool;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 解析协议数据
#pragma mark 解析设置时间数据（00|80）
- (manridyModel *)analysisSetTimeData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSetTimeModel;
    
    if ([head isEqualToString:@"00"]) {
        NSData *timeData = [data subdataWithRange:NSMakeRange(1, 7)];
        NSString *timeStr = [NSStringTool convertToNSStringWithNSData:timeData];
        model.setTimeModel.time = timeStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        //        NSLog(@"设定了时间为：%@\n%@",timeStr,model.setTimeModel.time);
    }else if ([head isEqualToString:@"80"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析血压的数据（11|91）
//解析血压数据（11|91）
- (manridyModel *)analysisBloodData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeBloodModel;
    
    if ([head isEqualToString:@"11"]) {
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.bloodModel.bloodState = BloodDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.bloodModel.sumCount = sumStr;
            model.bloodModel.currentCount = currentStr;
            model.bloodModel.bloodState = BloodDataHistoryData;
        }else if ([TyStr isEqualToString:@"02"]) {
            model.bloodModel.bloodState = BloodDataHistoryCount;
            NSData *AL = [data subdataWithRange:NSMakeRange(2, 2)];
            int ALinterger = [NSStringTool parseIntFromData:AL];
            model.bloodModel.sumCount = [NSString stringWithFormat:@"%d", ALinterger];
        }else if ([TyStr isEqualToString:@"03"]) {
            model.bloodModel.bloodState = BloodDataUpload;
        }
        
        NSData *year = [data subdataWithRange:NSMakeRange(6, 1)];
        NSString *yearStr = [NSStringTool convertToNSStringWithNSData:year];
        NSData *month = [data subdataWithRange:NSMakeRange(7, 1)];
        NSString *monthStr = [NSStringTool convertToNSStringWithNSData:month];
        NSData *day = [data subdataWithRange:NSMakeRange(8, 1)];
        NSString *dayStr = [NSStringTool convertToNSStringWithNSData:day];
        NSData *hour = [data subdataWithRange:NSMakeRange(9, 1)];
        NSString *hourStr = [NSStringTool convertToNSStringWithNSData:hour];
        NSData *min = [data subdataWithRange:NSMakeRange(10, 1)];
        NSString *minStr = [NSStringTool convertToNSStringWithNSData:min];
        NSData *sencond = [data subdataWithRange:NSMakeRange(11, 1)];
        NSString *sencondStr = [NSStringTool convertToNSStringWithNSData:sencond];
        
        NSData *highBlood = [data subdataWithRange:NSMakeRange(12, 1)];
        int highBloodinteger = [NSStringTool parseIntFromData:highBlood];
        NSString *hbStr = [NSString stringWithFormat:@"%d",highBloodinteger];
        
        NSData *lowBlood = [data subdataWithRange:NSMakeRange(13, 1)];
        int lowBloodinteger = [NSStringTool parseIntFromData:lowBlood];
        NSString *lbStr = [NSString stringWithFormat:@"%d",lowBloodinteger];
        
        NSData *bpm = [data subdataWithRange:NSMakeRange(14, 1)];
        int bpminteger = [NSStringTool parseIntFromData:bpm];
        NSString *bpmStr = [NSString stringWithFormat:@"%d",bpminteger];
        
        NSString *monthString = [NSString stringWithFormat:@"20%@/%@", yearStr, monthStr];
        NSString *dayString = [NSString stringWithFormat:@"20%@/%@/%@", yearStr,monthStr ,dayStr];
        NSString *timeString = [NSString stringWithFormat:@"%@:%@:%@",hourStr ,minStr ,sencondStr];
        
        model.bloodModel.monthString = monthString;
        model.bloodModel.dayString = dayString;
        model.bloodModel.timeString = timeString;
        model.bloodModel.highBloodString = hbStr;
        model.bloodModel.lowBloodString = lbStr;
        model.bloodModel.bpmString = bpmStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"91"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

@end
