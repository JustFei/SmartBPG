//
//  BloodModel.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BloodModel : NSObject

@property (nonatomic, assign) BOOL testSuccess;
@property (nonatomic, copy) NSString *electricity;
//用来按月查找
@property (nonatomic, copy) NSString *monthString;
@property (nonatomic ,copy) NSString *dayString;
@property (nonatomic ,copy) NSString *timeString;
@property (nonatomic ,copy) NSString *highBloodString;
@property (nonatomic ,copy) NSString *lowBloodString;
@property (nonatomic ,copy) NSString *bpmString;

@end
