//
//  NEMediaCaptureEntity.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/11/17.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveStreaming.h"

@interface NEMediaCaptureEntity : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, strong) LSVideoParaCtxConfiguration* videoParaCtx;
@property(nonatomic, assign) NSUInteger encodeType;

@end
