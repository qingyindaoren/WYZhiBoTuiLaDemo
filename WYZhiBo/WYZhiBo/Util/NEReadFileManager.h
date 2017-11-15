//
//  NEReadFileManager.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/7/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>


//从文件读取数据时，需要确保对应的app中需要存放相应的yuv数据

@protocol NEReadFileManagerDelegate <NSObject>
-(void)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface NEReadFileManager : NSObject
@property(nonatomic, weak) id <NEReadFileManagerDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)startYuvFile;
- (void)stopYuvFile;
@end
