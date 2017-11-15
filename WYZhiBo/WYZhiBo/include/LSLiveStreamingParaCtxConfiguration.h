//
//  LSLiveStreamingParaCtxConfiguration.h
//  LSMediaCapture
//
//  Created by taojinliang on 2017/7/7.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSAudioParaCtxConfiguration,LSVideoParaCtxConfiguration;

@interface LSLiveStreamingParaCtxConfiguration : NSObject

/**
 是否开启硬件编码类型，默认不开启
 */
@property(nonatomic, assign) LSHardWareEncEnable eHaraWareEncType;

/**
 推流类型：音视频，视频，音频，默认为音视频
 */
@property(nonatomic, assign) LSOutputStreamType eOutStreamType;

/**
 推流协议：RTMP,FLV.默认为RTMP
 */
@property(nonatomic, assign) LSOutputFormatType eOutFormatType;

/**
 推流视频相关参数.
 */
@property(nonatomic, strong) LSVideoParaCtxConfiguration* sLSVideoParaCtx;

/**
 推流音频相关参数.
 */
@property(nonatomic, strong) LSAudioParaCtxConfiguration* sLSAudioParaCtx;

/**
 是否上传sdk日志，默认开启
 */
@property(nonatomic, assign) BOOL uploadLog;

/**
 创建一个直播默认参数配置
 
 @return 直播默认参数配置
 */
+ (instancetype)defaultLiveStreamingConfiguration;
@end

