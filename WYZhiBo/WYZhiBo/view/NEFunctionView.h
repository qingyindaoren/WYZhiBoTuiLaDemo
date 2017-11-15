//
//  NEFunctionView.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/25.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FunctionViewDelegate <NSObject>

- (void)recordBtnTapped:(UIButton *)sender;//开启／停止录制
- (void)audioBtnTapped:(UIButton *)sender;//开启／停止音频录制
- (void)videoBtnTapped:(UIButton *)sender;//开启／停止视频录制
- (void)screenCapBtnTapped;//视频截屏
- (void)waterMarkBtnTapped;//添加水印按钮

@end

@interface NEFunctionView : UIView

@property(nonatomic, weak) id<FunctionViewDelegate> functionViewDelegate;

@property(nonatomic, strong) UIButton *recordBtn;
//开启／停止音频按钮
@property(nonatomic, strong) UIButton *audioBtn;
//开启／停止视频
@property(nonatomic, strong) UIButton *videoBtn;
//截屏按钮
@property(nonatomic, strong) UIButton *screenCapBtn;
//添加水印按钮
@property(nonatomic, strong) UIButton *waterMarkBtn;

@end
