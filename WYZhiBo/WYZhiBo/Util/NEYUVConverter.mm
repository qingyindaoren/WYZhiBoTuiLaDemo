//
//  NEYUVConverter.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/7/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEYUVConverter.h"
#import "libyuv.h"
#import "NEInternalMacro.h"

@implementation NEYUVConverter

+ (CVPixelBufferRef)i420FrameToPixelBuffer:(NSData *)i420Frame width:(int)frameWidth height:(int)frameHeight
{
    
    
    int width = frameWidth;
    int height = frameHeight;
    
    if (i420Frame == nil) {
        return NULL;
    }
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    
    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey,
                                           nil];
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &pixelBuffer);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Failed to create pixel buffer: %d", result);
        return NULL;
    }
    
    
    
    result = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        CFRelease(pixelBuffer);
        NSLog(@"Failed to lock base address: %d", result);
        return NULL;
    }
    
    
    uint8 *dstY = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int dstStrideY = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    uint8* dstUV = (uint8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int dstStrideUV = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    
    UInt8 *_planeData[3];
    NSUInteger _stride[3];
    
    CFDataRef dataref = (__bridge CFDataRef)i420Frame;
    uint8 * _data = (UInt8 *) CFDataGetBytePtr(dataref);
    
    _planeData[NEI420FramePlaneY] = _data;
    _planeData[NEI420FramePlaneU] = _planeData[NEI420FramePlaneY] + width * height;
    _planeData[NEI420FramePlaneV] = _planeData[NEI420FramePlaneU] + width * height / 4;
    
    _stride[NEI420FramePlaneY] = width;
    _stride[NEI420FramePlaneU] = width >> 1;
    _stride[NEI420FramePlaneV] = width >> 1;
    
#ifdef KLSMediaCaptureDemolibyuvCondense
    int ret = libyuv::I420ToNV12(_planeData[NEI420FramePlaneY], (int)_stride[NEI420FramePlaneY],
                                     _planeData[NEI420FramePlaneU], (int)_stride[NEI420FramePlaneU],
                                     _planeData[NEI420FramePlaneV], (int)_stride[NEI420FramePlaneV],
                                     dstY, dstStrideY, dstUV, dstStrideUV,
                                     width, height);
#endif
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
#ifdef KLSMediaCaptureDemolibyuvCondense
    if (ret) {
        NSLog(@"Error converting I420 VideoFrame to NV12: %d", result);
        CFRelease(pixelBuffer);
        return NULL;
    }
#endif
    
    return pixelBuffer;
}


+ (CMSampleBufferRef)pixelBufferToSampleBuffer:(CVPixelBufferRef)pixelBuffer
{
    CMSampleBufferRef sampleBuffer;
    CMTime frameTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000000000);
    CMSampleTimingInfo timing = {frameTime, frameTime, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    
    OSStatus status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create sample buffer with error %zd.", status);
    }
    
    CVPixelBufferRelease(pixelBuffer);
    if(videoInfo)
        CFRelease(videoInfo);
    
    return sampleBuffer;
}

@end
