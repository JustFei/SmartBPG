//
//  FMDBManager.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FMDBManager.h"
#import "BloodModel.h"

@implementation FMDBManager

static FMDatabase *_fmdb;

#pragma mark - init
/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        
        NSLog(@"数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            NSLog(@"数据库打开成功");
        }
        
        //BloodData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists BloodData(id integer primary key,month text, day text, time text, highBlood text, lowBlood text, bpm text);"]];
    }
    
    return self;
}

#pragma mark - BloodPressureData
- (BOOL)insertBloodModel:(BloodModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO BloodData(month, day, time, highBlood, lowBlood, bpm) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');", model.monthString, model.dayString, model.timeString, model.highBloodString, model.lowBloodString,  model.bpmString];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入BloodData数据成功");
    }else {
        NSLog(@"插入BloodData数据失败");
    }
    return result;
}

- (NSArray *)queryBlood:(NSString *)queryStr WithType:(QueryType)type
{
    NSString *queryString;
    
    FMResultSet *set;
    switch (type) {
        case QueryTypeAll:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData;"];
            set = [_fmdb executeQuery:queryString];
        }
            break;
        case QueryTypeWithDay:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData where day = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithMonth:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData where month = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithLastCount:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM BloodData ORDER BY id DESC LIMIT %@) ORDER BY ID ASC;", queryStr];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            
        default:
            break;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *month = [set stringForColumn:@"month"];
        NSString *day = [set stringForColumn:@"day"];
        NSString *time = [set stringForColumn:@"time"];
        NSString *highBlood = [set stringForColumn:@"highBlood"];
        NSString *lowBlood = [set stringForColumn:@"lowBlood"];
        NSString *bpmString = [set stringForColumn:@"bpm"];
        
        BloodModel *model = [[BloodModel alloc] init];
        
        model.monthString = month;
        model.dayString = day;
        model.timeString = time;
        model.highBloodString = highBlood;
        model.lowBloodString = lowBlood;
        model.bpmString = bpmString;
        
        [arrM addObject:model];
    }
    NSLog(@"Blood查询成功");
    return arrM;
}

- (BOOL)deleteBloodData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"drop table BloodData"];
    
    if (result) {
        NSLog(@"Blood表删除成功");
    }else {
        NSLog(@"Blood表删除失败");
    }
    
    return result;
}

#pragma mark - CloseData
- (void)CloseDataBase
{
    [_fmdb close];
}

@end
