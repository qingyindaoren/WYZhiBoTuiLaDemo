//
//  NELogoView.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NELogoView.h"
#import "NEInternalMacro.h"

#define kImageSize UIScale(32)
#define kImageSizeLeft UIScale(10)
#define kImageSizeRight UIScale(10)
#define kImageSizeTop UIScale(26)

@implementation NELogoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        //统计按钮
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.infoButton.frame = CGRectMake(kImageSizeLeft, kImageSizeTop, kImageSize, kImageSize);
        [self.infoButton setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
        [self.infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.infoButton];
        
        //闪光灯按钮
        self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.flashButton.frame = CGRectMake((self.frame.size.width-kImageSize)/2, kImageSizeTop, kImageSize, kImageSize);
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flashstart"] forState:UIControlStateNormal];
        [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flashButton];
        
        //取消按钮
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(self.frame.size.width-kImageSize-kImageSizeRight, kImageSizeTop, kImageSize, kImageSize);
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        

    }
    return self;
}

- (void)infoButtonPressed:(id)sender
{
    if (self.backDeleagte && [self.backDeleagte respondsToSelector:@selector(info)]) {
        [self.backDeleagte info];
    }
}

- (void)flashButtonPressed:(id)sender
{
    self.flashButton.selected = !self.flashButton.selected;
    if (self.backDeleagte && [self.backDeleagte respondsToSelector:@selector(flash:)]) {
        [self.backDeleagte flash:self.flashButton.selected];
    }
}

- (void)backButtonPressed:(id)sender
{
    if (self.backDeleagte && [self.backDeleagte respondsToSelector:@selector(back)]) {
        [self.backDeleagte back];
    }
}

@end
