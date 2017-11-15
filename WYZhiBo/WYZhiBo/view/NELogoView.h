//
//  NELogoView.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackDelegate <NSObject>
-(void)back;
-(void)flash:(BOOL)isOn;
-(void)info;
@end

@interface NELogoView : UIView
@property(nonatomic, weak) id<BackDelegate> backDeleagte;
//统计按钮
@property (nonatomic, strong) UIButton *infoButton;
//闪光灯按钮
@property (nonatomic, strong) UIButton *flashButton;
//返回按钮
@property (nonatomic, strong) UIButton *backButton;
@end
