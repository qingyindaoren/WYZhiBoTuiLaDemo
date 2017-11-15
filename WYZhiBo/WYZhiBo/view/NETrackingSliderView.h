//
//  NETrackingSliderView.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/9/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"
#import "LiveStreaming.h"

typedef enum : NSUInteger {
    zoomTag,
    ContrastTag,
    WhiteTag,
    ExposureTag
} SliderTag;
typedef void(^SliderTagBlock)(SliderTag tag, CGFloat value);

@interface NETrackingSliderView : UIView
@property (nonatomic, strong) UILabel *zoomLabel;
@property (nonatomic, strong) UILabel *filterContrastLabel;
@property (nonatomic, strong) UILabel *filterWhiteLabel;
@property (nonatomic, strong) UILabel *filterExposureLabel;
@property (nonatomic, strong) ASValueTrackingSlider *slider;//添加zoom功能的slider
@property (nonatomic, strong) ASValueTrackingSlider *filterContrastSlider;//增加滤镜磨皮强度调节的slider
@property (nonatomic, strong) ASValueTrackingSlider *filterWhiteSlider;//增加滤镜美白强度调节的slider
@property (nonatomic, strong) ASValueTrackingSlider *filterExposureSlider;//增加滤镜曝光强度调节的slider

-(instancetype)initWithView:(LSVideoParaCtxConfiguration*)paraCtx tag:(SliderTagBlock)tagBlock;
@end
