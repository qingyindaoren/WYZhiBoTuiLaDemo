//
//  NEMediaCaptureEntity.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/11/17.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEMediaCaptureEntity.h"

@implementation NEMediaCaptureEntity

+ (instancetype)sharedInstance {
    static NEMediaCaptureEntity *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
