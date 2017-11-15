//
//  NETrackingSliderView.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/9/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NETrackingSliderView.h"


@interface NETrackingSliderView()
@property(nonatomic, copy) SliderTagBlock tagBlock;
@end

@implementation NETrackingSliderView

-(instancetype)initWithView:(LSVideoParaCtxConfiguration*)paraCtx tag:(SliderTagBlock)tagBlock{
    self = [super init];
    if (self) {
        self.tagBlock = tagBlock;
        
//        self.backgroundColor = [UIColor grayColor];
//        self.alpha = 0.5;
        
        self.zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
        self.zoomLabel.text = @"zoom伸缩:";
        self.zoomLabel.textColor = [UIColor blackColor];
        self.zoomLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.zoomLabel];
        
        self.filterContrastLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 40)];
        self.filterContrastLabel.text = @"磨皮强度:";
        self.filterContrastLabel.textColor = [UIColor blackColor];
        self.filterContrastLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.filterContrastLabel];
        
        self.filterWhiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 100, 40)];
        self.filterWhiteLabel.text = @"美白强度:";
        self.filterWhiteLabel.textColor = [UIColor blackColor];
        self.filterWhiteLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.filterWhiteLabel];
        
        self.filterExposureLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 100, 40)];
        self.filterExposureLabel.text = @"曝光强度:";
        self.filterExposureLabel.textColor = [UIColor blackColor];
        self.filterExposureLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.filterExposureLabel];
        
        
        self.slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 0, 200, 40)];
        self.slider.minimumValue = 1;
        self.slider.maximumValue = 20;
//        self.slider.maximumValue = _mediaCapture.maxZoomScale;
        self.slider.popUpViewCornerRadius = 0.0;
        [self.slider setMaxFractionDigitsDisplayed:0];
        self.slider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        self.slider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
        [self.slider setValue:1.0];
        self.slider.tag = 1;
        //滑动拖动后的事件
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        //如果打开拖拽
        if (paraCtx.isCameraZoomPinchGestureOn) {
            [self addSubview:self.slider];
        }
        
        //======================增加两种滤镜调节强度进度条=========================//
        self.filterContrastSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 30, 200, 40)];
        self.filterContrastSlider.maximumValue = 1.0;
        self.filterContrastSlider.minimumValue = 0.0;
        self.filterContrastSlider.popUpViewCornerRadius = 0.0;
        [self.filterContrastSlider setMaxFractionDigitsDisplayed:1];
        self.filterContrastSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        self.filterContrastSlider.textColor = [UIColor colorWithHue:0.65 saturation:1.0 brightness:0.5 alpha:1];
        [self.filterContrastSlider setValue:0.0];
        self.filterContrastSlider.tag = 2;
        if (paraCtx.isVideoFilterOn) {
            [self addSubview:self.filterContrastSlider];
        }
        //滑动拖动后的事件
        [self.filterContrastSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        self.filterWhiteSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 60, 200, 40)];
        self.filterWhiteSlider.maximumValue = 1.0;
        self.filterWhiteSlider.minimumValue = 0.0;
        self.filterWhiteSlider.popUpViewCornerRadius = 0.0;
        [self.filterWhiteSlider setMaxFractionDigitsDisplayed:1];
        self.filterWhiteSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        self.filterWhiteSlider.textColor = [UIColor colorWithHue:0.75 saturation:1.0 brightness:0.5 alpha:1];
        [self.filterWhiteSlider setValue:0.0];
        self.filterWhiteSlider.tag = 3;
        //滑动拖动后的事件
        [self.filterWhiteSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (paraCtx.isVideoFilterOn) {
            [self addSubview:self.filterWhiteSlider];
        }
        
        
        self.filterExposureSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 90, 200, 40)];
        self.filterExposureSlider.maximumValue = 10.0;
        self.filterExposureSlider.minimumValue = -10.0;
        self.filterExposureSlider.popUpViewCornerRadius = 0.0;
        [self.filterExposureSlider setMaxFractionDigitsDisplayed:1];
        self.filterExposureSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        self.filterExposureSlider.textColor = [UIColor colorWithHue:0.75 saturation:1.0 brightness:0.5 alpha:1];
        [self.filterExposureSlider setValue:0.0];
        self.filterExposureSlider.tag = 4;
        //滑动拖动后的事件
        [self.filterExposureSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (paraCtx.isVideoFilterOn) {
            [self addSubview:self.filterExposureSlider];
        }
    }
    return self;
}

-(void)sliderValueChanged:(id)sender{
    UISlider* control = (UISlider*)sender;
    float value = control.value;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [UIView animateWithDuration:0.5 animations:^{
            [control setValue:value animated:YES];
        }];
    }else {
        [control setValue:value animated:YES];
    }
    
    SliderTag tag;
    if (control.tag == 1) {
        tag = zoomTag;
    }else if (control.tag == 2){
        tag = ContrastTag;
    }else if (control.tag == 3){
        tag = WhiteTag;
    }else{
        tag = ExposureTag;
    }
    
    if (self.tagBlock) {
        self.tagBlock(tag,value);
    }
}
@end
