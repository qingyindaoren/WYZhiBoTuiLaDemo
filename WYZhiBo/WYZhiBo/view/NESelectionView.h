//
//  NESelectionView.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectDelegate <NSObject>
-(void)startButtonPressed:(UIButton *)sender;
-(void)switchButtonPressed;
-(void)mainFilterBtnPressed;
-(void)musicButtonPressed;
-(void)interestButtonPressed;
@end

@interface NESelectionView : UIView
@property(nonatomic, weak) id<SelectDelegate> selectDelegate;
//开始按钮
@property (nonatomic,strong) UIButton *startBtn;
//趣味按钮
@property (nonatomic,strong) UIButton *interestBtn;
//相机按钮
@property (nonatomic,strong) UIButton *cameraBtn;
//滤镜按钮
@property (nonatomic,strong) UIButton *filterBtn;
//伴奏功能
@property(nonatomic,strong) UIButton* musicButton;

-(void)selectionFilter:(BOOL)isFilter;
@end
