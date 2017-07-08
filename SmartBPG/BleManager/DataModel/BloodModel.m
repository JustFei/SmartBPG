//
//  BloodModel.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodModel.h"

@implementation BloodModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"_highBloodString == %@ _lowBloodString == %@ _bpmString == %@ _electricity == %@", _highBloodString, _lowBloodString, _bpmString, _electricity];
}

@end
