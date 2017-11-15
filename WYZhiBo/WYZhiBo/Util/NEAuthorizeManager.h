//
//  NEAuthorizeManager.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEAuthorizeManager : NSObject

/**
 单例方法

 @return 实例
 */
+ (instancetype)sharedInstance;

/**
 应用程序需要事先申请视频使用权限

 @param handler 回调
 */
-(BOOL)requestVideoAccessCompletionHandler:(void(^)(BOOL,NSError *))handler;
/**
 应用程序需要事先申请音视频使用权限

 @param handler 回调

 @return bool
 */
- (BOOL)requestMediaCapturerAccessWithCompletionHandler:(void (^)(BOOL, NSError*))handler;

@end
