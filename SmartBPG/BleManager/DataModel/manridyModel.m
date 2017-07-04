//
//  manridyModel.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "manridyModel.h"

@implementation manridyModel

- (SetTimeModel *)setTimeModel
{
    if (!_setTimeModel) {
        _setTimeModel = [[SetTimeModel alloc] init];
    }
    
    return _setTimeModel;
}

- (BloodModel *)bloodModel
{
    if (!_bloodModel) {
        _bloodModel = [[BloodModel alloc] init];
    }
    return _bloodModel;
}

@end
