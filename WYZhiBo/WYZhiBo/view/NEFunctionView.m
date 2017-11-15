//
//  NEFunctionView.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/25.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEFunctionView.h"
#import "Masonry.h"
#import "NEInternalMacro.h"

@implementation NEFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubViews {
    self.recordBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //FIX ME: image
        [btn setBackgroundImage:[UIImage imageNamed:@"startR"] forState:UIControlStateNormal];

        [btn addTarget:self action:@selector(recordBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.audioBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //FIX ME: image
        [btn setBackgroundImage:[UIImage imageNamed:@"audio_s"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(audioBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.videoBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"video_s"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(videoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.screenCapBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //FIX ME: image
        [btn setBackgroundImage:[UIImage imageNamed:@"screenCap"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(screenCapBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.waterMarkBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //FIX ME: image
        [btn setBackgroundImage:[UIImage imageNamed:@"waterMark"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(waterMarkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [@[self.recordBtn, self.audioBtn, self.videoBtn, self.screenCapBtn, self.waterMarkBtn] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:btn];
    }];
}

- (void)setupConstraints {
    CGFloat left = UIScale(12);
    CGFloat right = UIScale(15);
    
    CGFloat bottom = UIScale(5);
    CGFloat buttonWidth = UIScale(32);
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(left);
        make.height.width.equalTo(@(buttonWidth));
        make.bottom.equalTo(self.mas_bottom).offset(-bottom);
    }];
    
    [self.waterMarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-right);
        make.width.height.equalTo(@(buttonWidth));
        make.bottom.equalTo(self.recordBtn.mas_bottom);
    }];
    
    [self.screenCapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.waterMarkBtn.mas_left).offset(-5);
        make.width.height.equalTo(@(buttonWidth));
        make.bottom.equalTo(self.recordBtn.mas_bottom);
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.screenCapBtn.mas_left).offset(-5);
        make.width.height.equalTo(@(buttonWidth));
        make.bottom.equalTo(self.recordBtn.mas_bottom);
    }];
    
    [self.audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoBtn.mas_left).offset(-5);
        make.width.height.equalTo(@(buttonWidth));
        make.bottom.equalTo(self.recordBtn.mas_bottom);
    }];
}

#pragma mark - view delegate

- (void)recordBtnTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"endR"] forState:UIControlStateSelected];
    }
    else {
        [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"startR"] forState:UIControlStateNormal];
    }
    if (self.functionViewDelegate && [self.functionViewDelegate respondsToSelector:@selector(recordBtnTapped:)]) {
        [self.functionViewDelegate recordBtnTapped:(UIButton *)sender];
    }
}

- (void)audioBtnTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioBtn setBackgroundImage:[UIImage imageNamed:@"audio_e"] forState:UIControlStateSelected];
    }
    else {
        [self.audioBtn setBackgroundImage:[UIImage imageNamed:@"audio_s"] forState:UIControlStateNormal];
    }
    if (self.functionViewDelegate && [self.functionViewDelegate respondsToSelector:@selector(audioBtnTapped:)]) {
        [self.functionViewDelegate audioBtnTapped:(UIButton *)sender];
    }
}

- (void)videoBtnTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.videoBtn setBackgroundImage:[UIImage imageNamed:@"video_e"] forState:UIControlStateSelected];
    }
    else {
        [self.videoBtn setBackgroundImage:[UIImage imageNamed:@"video_s"] forState:UIControlStateNormal];
    }
    if (self.functionViewDelegate && [self.functionViewDelegate respondsToSelector:@selector(videoBtnTapped:)]) {
        [self.functionViewDelegate videoBtnTapped:(UIButton *)sender];
    }
}

- (void)screenCapBtnTapped:(UIButton *)sender {
    if (self.functionViewDelegate && [self.functionViewDelegate respondsToSelector:@selector(screenCapBtnTapped)]) {
        [self.functionViewDelegate screenCapBtnTapped];
    }
}

- (void)waterMarkBtnTapped:(UIButton *)sender {
    if (self.functionViewDelegate && [self.functionViewDelegate respondsToSelector:@selector(waterMarkBtnTapped)]) {
        [self.functionViewDelegate waterMarkBtnTapped];
    }
}

@end
