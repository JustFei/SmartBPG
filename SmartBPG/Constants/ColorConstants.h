//
//  ColorConstants.h
//  OnePiece
//
//  Created by JustFei on 2016/11/9.
//  Copyright © 2016年 manridy. All rights reserved.
//

#ifndef ColorConstants_h
#define ColorConstants_h

/** rgb颜色转换（16进制->10进制）*/
#define COLOR_WITH_HEX(rgbValue ,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

/** 带有RGBA的颜色设置 */
#define COLOR_WITH_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/** 透明色 */
#define CLEAR_COLOR [UIColor clearColor]

/** 常用颜色 */
#define WHITE_COLOR [UIColor whiteColor]
#define BLACK_COLOR [UIColor blackColor]
#define RED_COLOR [UIColor redColor]
#define BLUE_COLOR [UIColor blueColor]
#define GREEN_COLOR [UIColor greenColor]
#define GRAY_COLOR [UIColor grayColor]
#define ORANGE_COLOR [UIColor orangeColor]
#define PURPLE_COLOR [UIColor purpleColor]

/** 设置页面的背景颜色 */
#define SETTING_BACKGROUND_COLOR COLOR_WITH_HEX(0xf5f5f5, 1)

/** navigationBar 的颜色 */
#define NAVIGATION_BAR_COLOR COLOR_WITH_HEX(0x2196f3, 1)

/** tableView 线的颜色 */
#define TABLEVIEW_LINE_COLOR COLOR_WITH_HEX(0xcccccc,1)

/** 按钮的绿色 */
//#define kButtonGreenColor COLOR_WITH_HEX(0x18db30,1)

/** 底部通知栏的颜色 */
#define STATE_BAR_BACKGROUND_COLOR COLOR_WITH_HEX(0xf5f5f5,1)

/** 文字的颜色, 4 --> 0 由深到浅 */

/** 文字的颜色 --> 0.87 */
#define TEXT_BLACK_COLOR_LEVEL4 COLOR_WITH_HEX(0x000000,0.87)
/** 文字的颜色 --> 0.54 */
#define TEXT_BLACK_COLOR_LEVEL3 COLOR_WITH_HEX(0x000000,0.54)
/** 文字的颜色 --> 0.38 */
#define TEXT_BLACK_COLOR_LEVEL2 COLOR_WITH_HEX(0x000000,0.38)
/** 文字的颜色 --> 0.15 */
#define TEXT_BLACK_COLOR_LEVEL1 COLOR_WITH_HEX(0x000000,0.15)
/** 文字的颜色 --> 0.05 */
#define TEXT_BLACK_COLOR_LEVEL0 COLOR_WITH_HEX(0x000000,0.05)

/** 文字的颜色 --> 0.87 */
#define TEXT_WHITE_COLOR_LEVEL4 COLOR_WITH_HEX(0xffffff,0.87)
/** 文字的颜色 --> 0.54 */
#define TEXT_WHITE_COLOR_LEVEL3 COLOR_WITH_HEX(0xffffff,0.54)
/** 文字的颜色 --> 0.38 */
#define TEXT_WHITE_COLOR_LEVEL2 COLOR_WITH_HEX(0xffffff,0.38)
/** 文字的颜色 --> 0.15 */
#define TEXT_WHITE_COLOR_LEVEL1 COLOR_WITH_HEX(0xffffff,0.15)
/** 文字的颜色 --> 0.05 */
#define TEXT_WHITE_COLOR_LEVEL0 COLOR_WITH_HEX(0xffffff,0.05)

/** 心率页面 */
#define HR_CURRENT_BACKGROUND_COLOR COLOR_WITH_HEX(0xef5350,1)
#define HR_HISTORY_BACKGROUND_COLOR COLOR_WITH_HEX(0xd32f2f,1)
#define HR_CURRENT_CIRCLE_COLOR COLOR_WITH_HEX(0xffffff,0.87)
#define HR_CURRENT_SHADOW_CIRCLE_COLOR COLOR_WITH_HEX(0xffffff,0.15)
#define HR_HISTORY_CIRCLE_COLOR COLOR_WITH_HEX()

/** 血压页面 */
#define BP_CURRENT_BACKGROUND_COLOR COLOR_WITH_HEX()
#define BP_HISTORY_BACKGROUND_COLOR COLOR_WITH_HEX(0x00abc0,1)
#define BP_CURRENT_CIRCLE_COLOR COLOR_WITH_HEX(0xffffff,0.87)
#define BP_CURRENT_SHADOW_CIRCLE_COLOR COLOR_WITH_HEX(0x000000,0.1)



#endif /* ColorConstants_h */
