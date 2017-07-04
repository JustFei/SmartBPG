//
//  manridyModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SetTimeModel.h"
#import "BloodModel.h"


typedef enum : NSUInteger {
    ResponsEcorrectnessDataFail = 0,
    ResponsEcorrectnessDataRgith,
} ResponsEcorrectnessData;

typedef enum : NSUInteger {
    ReturnModelTypeSetTimeModel = 0,
    ReturnModelTypeBloodModel
} ReturnModelType;

@interface manridyModel : NSObject

//判断返回数据是否成功
@property (nonatomic, assign) ResponsEcorrectnessData isReciveDataRight;

//返回信息的类型
@property (nonatomic, assign) ReturnModelType receiveDataType;

//返回设置时间数据
@property (nonatomic, strong) SetTimeModel *setTimeModel;

//血压模型
@property (nonatomic, strong) BloodModel *bloodModel;

@end



