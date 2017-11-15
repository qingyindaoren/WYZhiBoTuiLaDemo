//
//  NEStatisticalInformationView.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/9/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LiveStreaming.h"

@interface NEStatisticalInformationView : UIView
@property(nonatomic, strong) UILabel *videoFpsKey;//视频帧率
@property(nonatomic, strong) UILabel *videoFpsValue;
@property(nonatomic, strong) UILabel *videoBitrateKey;//视频码率
@property(nonatomic, strong) UILabel *videoBitrateValue;
@property(nonatomic, strong) UILabel *videoResolutionKey;//视频分辨率
@property(nonatomic, strong) UILabel *videoResolutionValue;
@property(nonatomic, strong) UILabel *audioBitrateKey;//音频码率
@property(nonatomic, strong) UILabel *audioBitrateValue;
@property(nonatomic, strong) UILabel *cpuKey;//cpu消耗
@property(nonatomic, strong) UILabel *cpuValue;
@property(nonatomic, strong) UILabel *networkKey;//网络状况
@property(nonatomic, strong) UILabel *networkValue;

-(void)dispalyInfo:(LSStatistics)pStatistic;
@end
