//
//  BPHisContentView.h
//  SmartBPG
//
//  Created by JustFei on 2017/6/23.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPHisContentView : UIView

- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date;

//- (void)getDataFromDBWithMonth:(NSDate *)month;

@end
