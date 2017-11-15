//
//  NEReadFileManager.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/7/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEReadFileManager.h"
#import "NEYUVConverter.h"

#define defaultFps 20

@interface NEReadFileManager()
{
    FILE *yuvFile;
    int yuvWidth;
    int yuvHeight;
}
@property(nonatomic, strong) NSMutableArray *fileList;
@property (strong, nonatomic) NSString * path;
@property (strong, nonatomic) NSString * fileName;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) CMSampleBufferRef last_sampleBuffer;
@end

@implementation NEReadFileManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEReadFileManager *ne_authorizeManager = nil;
    dispatch_once(&onceToken, ^{
        ne_authorizeManager = [[NEReadFileManager alloc] init];
    });
    return ne_authorizeManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initFileList];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *yuvPath = [docPath stringByAppendingPathComponent:@"YUVFile"];
        if ([self.fileList count] > 0) {
            self.fileName = self.fileList[0];
        }
        self.path =  [NSString stringWithFormat:@"%@/%@", yuvPath, self.fileName];
    }
    return self;
}

-(void)initFileList
{
    self.fileList = [[NSMutableArray alloc] init];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *yuvPath = [docPath stringByAppendingPathComponent:@"YUVFile"];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:yuvPath];
    
    NSString *path;
    while((path = [enumerator nextObject]) != nil) {
        BOOL isDirectory = YES;
        
        [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", yuvPath, path] isDirectory:&isDirectory];
        
        if (!isDirectory && ![path containsString:@".DS_Store"] && ![path containsString:@".log"]) {
            [self.fileList addObject:path];
        }
    }
    
}

- (void)startYuvFile
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (yuvFile) {
        fclose(yuvFile);
        yuvFile = NULL;
    }
    
    if (self.fileName == nil || [self.fileName length] == 0) {
        return;
    }
    
    [self setYuvDimensFromFileName:self.fileName];
    
    if ([self openFile:self.path]) {
        NSTimeInterval interval = (float) 1 / defaultFps;
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(readYUVFile) userInfo:nil repeats:YES];
    }
}

- (void)stopYuvFile{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (yuvFile) {
        fclose(yuvFile);
        yuvFile = NULL;
    }
}

- (BOOL)openFile:(NSString *)url
{
    const char * filePathChar = [url UTF8String];
    
    yuvFile = fopen(filePathChar, "r");
    
    if (!yuvFile) {
        NSLog(@"open yuvfile failed");
        return NO;
    }
    else
    {
        NSLog(@"open yuvfile success");
        return YES;
    }
}

- (void)readYUVFile
{
    NSLog(@"read yuvfile");
    
    int len = yuvWidth * yuvHeight * 3 / 2;
    
    Byte buf[len];
    
    long num = fread(buf,1,len,yuvFile);
    
    if (num == 0) {
        NSLog(@"read stop , send last frame!");
        
        //发送
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendVideoSampleBuffer:)]) {
            [self.delegate sendVideoSampleBuffer:_last_sampleBuffer];
        }
        
//        [_timer invalidate];
//        _timer = nil;
//
//        fclose(yuvFile);
//        yuvFile = NULL;
        
        return;
    }
    
    //Byte[] —> NSData
    NSData * data = [[NSData alloc] initWithBytes:buf length:len];
    
    // NSData-> CVPixelBufferRef
    CVPixelBufferRef pixelBuffer = [NEYUVConverter i420FrameToPixelBuffer:data width:yuvWidth height:yuvHeight];
    
    // CVPixelBufferRef -> CMSampleBufferRef
    CMSampleBufferRef sampleBuffer = [NEYUVConverter pixelBufferToSampleBuffer:pixelBuffer];
    _last_sampleBuffer = sampleBuffer;
    
    //发送
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVideoSampleBuffer:)]) {
        [self.delegate sendVideoSampleBuffer:sampleBuffer];
    }
    
}

- (void)setYuvDimensFromFileName:(NSString *)fileName
{
    //因为无法从yuv文件信息中获取yuv视频的宽高 所以必须提前知道该视频的宽高 暂定直接把宽高写在文件名中
    //yuv文件名在该demo中的命名规则 name_width_height.yuv 例如：功夫熊猫_352_288.yuv 获取文件名中的 width height 作为yuv视频的宽高。
    
    //默认宽 高
    yuvWidth = 352;
    
    yuvHeight = 288;
    
    if (!fileName) {
        return;
    }
    NSArray *prefixArray = [fileName componentsSeparatedByString:@".yuv"];
    
    NSString *prefixFileName = prefixArray[0];
    
    NSArray *dimensArray = [prefixFileName componentsSeparatedByString:@"_"];
    
    if (dimensArray.count > 2) {
        yuvWidth = [dimensArray[1] intValue];
        yuvHeight = [dimensArray[2] intValue];
    }
}
@end
