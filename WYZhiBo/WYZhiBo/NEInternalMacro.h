//
//  NEInternalMacro.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#ifndef NEInternalMacro_h
#define NEInternalMacro_h

//=============================================//
//LSMediaCapture精简包声明
//#define KLSMediaCaptureDemoCondense

#ifndef KLSMediaCaptureDemoCondense
#define KLSMediaCaptureDemolibyuvCondense
#endif
//=============================================//

#define UIScreenWidth        [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight       [UIScreen mainScreen].bounds.size.height
#define UISreenWidthScale    UIScreenWidth/320.0  //以iphone5 屏幕为基准
#define UIScale(x)           x*UISreenWidthScale

//============================================================================================

#define NAVI_COLOR [UIColor whiteColor]

#define FONT(s) [UIFont systemFontOfSize:s]

//--------------macro definition of the bitrate
#define SHQBITRATE 1200000
#define SQBITRATE 800000
#define HQBITRATE 600000
#define MQBITRATE 450000
#define LQBITRATE 300000

//弱引用
#define NEWeakify(weak, strong)  __weak __typeof(strong) weak = strong;
//强引用
#define NEStrongify(strong, weak)  __strong __typeof(weak) strong = weak;

#endif /* NEInternalMacro_h */
