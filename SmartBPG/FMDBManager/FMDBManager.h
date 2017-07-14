//
//  FMDBManager.h
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class UserInfoModel;
@class BloodModel;

typedef enum : NSUInteger {
    QueryTypeAll = 0,
    QueryTypeWithDay,
    QueryTypeWithMonth,
    QueryTypeWithLastCount      //取出最后几条数据
} QueryType;

@interface FMDBManager : NSObject

- (instancetype)initWithPath:(NSString *)path;

#pragma mark - BloodPressureData
- (BOOL)insertBloodModel:(BloodModel *)model;

- (NSArray *)queryBlood:(NSString *)queryStr WithType:(QueryType)type;

//- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model;

//- (BOOL)deleteSleepData:(NSString *)deleteSql;


#pragma mark - CloseData
- (void)CloseDataBase;

@end
