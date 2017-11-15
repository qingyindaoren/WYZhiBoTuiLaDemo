//
//  NEStatisticalInformationView.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/9/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEStatisticalInformationView.h"
#import "NEDeviceUtil.h"

#define kStartLeft 20
#define kWidth 80
#define kHeight 50

@implementation NEStatisticalInformationView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor grayColor];
//        self.alpha = 0.5;
        
        self.videoFpsKey = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft, 0, kWidth, kHeight)];
        self.videoFpsKey.text = @"视频帧率:";
        self.videoFpsKey.textColor = [UIColor blackColor];
        self.videoFpsKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoFpsKey];
        
        self.videoFpsValue = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft+kWidth, 0, kWidth, kHeight)];
        self.videoFpsValue.textColor = [UIColor redColor];
        self.videoFpsValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoFpsValue];
        
        self.videoBitrateKey = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft, kHeight, kWidth, kHeight)];
        self.videoBitrateKey.text = @"视频码率:";
        self.videoBitrateKey.textColor = [UIColor blackColor];
        self.videoBitrateKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoBitrateKey];
        
        self.videoBitrateValue = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft+kWidth, kHeight, kWidth, kHeight)];
        self.videoBitrateValue.textColor = [UIColor redColor];
        self.videoBitrateValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoBitrateValue];
        
        self.cpuKey = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft, 2*kHeight, kWidth, kHeight)];
        self.cpuKey.text = @"CPU使用:";
        self.cpuKey.textColor = [UIColor blackColor];
        self.cpuKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.cpuKey];
        
        self.cpuValue = [[UILabel alloc] initWithFrame:CGRectMake(kStartLeft+kWidth, 2*kHeight, kWidth, kHeight)];
        self.cpuValue.textColor = [UIColor redColor];
        self.cpuValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.cpuValue];
        
        
        self.videoResolutionKey = [[UILabel alloc] initWithFrame:CGRectMake(2*kWidth, 0, kWidth, kHeight)];
        self.videoResolutionKey.text = @"分辨率:";
        self.videoResolutionKey.textColor = [UIColor blackColor];
        self.videoResolutionKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoResolutionKey];
        
        self.videoResolutionValue = [[UILabel alloc] initWithFrame:CGRectMake(3*kWidth, 0, kWidth, kHeight)];
        self.videoResolutionValue.textColor = [UIColor redColor];
        self.videoResolutionValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.videoResolutionValue];
        
        self.audioBitrateKey = [[UILabel alloc] initWithFrame:CGRectMake(2*kWidth, kHeight, kWidth, kHeight)];
        self.audioBitrateKey.text = @"音频码率:";
        self.audioBitrateKey.textColor = [UIColor blackColor];
        self.audioBitrateKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.audioBitrateKey];
        
        self.audioBitrateValue = [[UILabel alloc] initWithFrame:CGRectMake(3*kWidth, kHeight, kWidth, kHeight)];
        self.audioBitrateValue.textColor = [UIColor redColor];
        self.audioBitrateValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.audioBitrateValue];
        
        
        self.networkKey = [[UILabel alloc] initWithFrame:CGRectMake(2*kWidth, 2*kHeight, kWidth, kHeight)];
        self.networkKey.text = @"网络状况:";
        self.networkKey.textColor = [UIColor blackColor];
        self.networkKey.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.networkKey];
        
        self.networkValue = [[UILabel alloc] initWithFrame:CGRectMake(3*kWidth, 2*kHeight, kWidth, kHeight)];
        self.networkValue.textColor = [UIColor redColor];
        self.networkValue.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.networkValue];
        
        self.videoFpsValue.text = [NSString stringWithFormat:@"%d",0];
        self.videoBitrateValue.text = [NSString stringWithFormat:@"%d",0];
        self.videoResolutionValue.text = [NSString stringWithFormat:@"%dx%d",0,0];
        self.audioBitrateValue.text = [NSString stringWithFormat:@"%d",0];
        self.cpuValue.text = [NSString stringWithFormat:@"%d%%",0];
        self.networkValue.text = @"";
    }
    return self;
}

-(void)dispalyInfo:(LSStatistics)pStatistic{
    self.videoFpsValue.text = [NSString stringWithFormat:@"%d",pStatistic.videoSendFrameRate];
    self.videoBitrateValue.text = [NSString stringWithFormat:@"%d",pStatistic.videoSendBitRate];
    self.videoResolutionValue.text = [NSString stringWithFormat:@"%dx%d",pStatistic.videoSendWidth,pStatistic.videoSendHeight];
    self.audioBitrateValue.text = [NSString stringWithFormat:@"%d",pStatistic.audioSendBitRate];
    self.cpuValue.text = [NSString stringWithFormat:@"%.2f%%",[NEDeviceUtil getAppCpuUsage]];
    NSString *networkText = @"";
    switch (pStatistic.type) {
        case LS_QOSLVL_HIGH:
            networkText = @"好";
            break;
        case LS_QOSLVL_MIDDLE:
            networkText = @"一般";
            break;
        case LS_QOSLVL_LOW:
            networkText = @"差";
            break;
        default:
            break;
    }
    self.networkValue.text = [NSString stringWithFormat:@"%@",networkText];
}
@end
