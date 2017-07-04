//
//  AnalysisProcotolTool.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class manridyModel;

@interface AnalysisProcotolTool : NSObject


@property (nonatomic ,assign) float staticLon;

@property (nonatomic ,assign) float staticLat;

+ (instancetype)shareInstance;

//解析设置时间数据（00|80）
- (manridyModel *)analysisSetTimeData:(NSData *)data WithHeadStr:(NSString *)head;

//解析血压数据（11|91）
- (manridyModel *)analysisBloodData:(NSData *)data WithHeadStr:(NSString *)head;

@end
