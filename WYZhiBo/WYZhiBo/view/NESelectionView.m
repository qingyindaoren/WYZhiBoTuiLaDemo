//
//  NESelectionView.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NESelectionView.h"
#import "UIView+NE.h"
#import "NEInternalMacro.h"


@implementation NESelectionView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)selectionFilter:(BOOL)isFilter
{
    CGFloat right   = UIScale(10);
    CGFloat bottom  = UIScale(10);
    CGFloat padding = UIScale(0);
    CGSize  buttonSize = CGSizeMake(UIScale(47), UIScale(47));
    
    //startBtn按钮
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.size  = buttonSize;
    self.startBtn.left  = UIScale(12);
    self.startBtn.bottom = self.height - bottom;
    [self.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
    [self addSubview:self.startBtn];
    [self.startBtn addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //music按钮
    self.musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.musicButton.size  = buttonSize;
    self.musicButton.right = self.width - right;
    self.musicButton.bottom = self.height - bottom;
    [self.musicButton setBackgroundImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
    [self addSubview:self.musicButton];
    [self.musicButton addTarget:self action:@selector(musicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat nextRight = self.musicButton.left;
    //filter按钮
    if (isFilter) {
        self.filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.filterBtn.size   = buttonSize;
        self.filterBtn.right  = nextRight - padding;
        self.filterBtn.bottom = self.height - bottom;
        [self.filterBtn setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [self addSubview:self.filterBtn];
        [self.filterBtn addTarget:self action:@selector(mainFilterBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        nextRight = self.filterBtn.left;
    }
    
    //camera按钮
    self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn.size   = buttonSize;
    self.cameraBtn.right  = nextRight - padding;
    self.cameraBtn.bottom = self.height - bottom;
    [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [self addSubview:self.cameraBtn];
    [self.cameraBtn addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    nextRight = self.cameraBtn.left;
    
    //interest按钮
    self.interestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interestBtn.size   = buttonSize;
    self.interestBtn.right  = nextRight - padding;
    self.interestBtn.bottom = self.height - bottom;
    [self.interestBtn setBackgroundImage:[UIImage imageNamed:@"interest"] forState:UIControlStateNormal];
    [self addSubview:self.interestBtn];
    [self.interestBtn addTarget:self action:@selector(interestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.interestBtn.hidden = YES;
}

#pragma mark - view delegate

-(void)startButtonPressed:(UIButton *)sender
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(startButtonPressed:)]) {
        [self.selectDelegate startButtonPressed:(UIButton *)sender];
    }
}

-(void)musicButtonPressed:(id)sender
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(musicButtonPressed)]) {
        [self.selectDelegate musicButtonPressed];
    }
}

-(void)mainFilterBtnPressed:(id)sender
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(mainFilterBtnPressed)]) {
        [self.selectDelegate mainFilterBtnPressed];
    }
}

-(void)switchButtonPressed:(id)sender
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(switchButtonPressed)]) {
        [self.selectDelegate switchButtonPressed];
    }
}

-(void)interestButtonPressed:(id)sender
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(interestButtonPressed)]) {
        [self.selectDelegate interestButtonPressed];
    }
}

@end
