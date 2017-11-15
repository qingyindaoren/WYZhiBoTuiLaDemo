//
//  ViewController.m
//  WYZhiBo
//
//  Created by 美融城 on 2017/11/10.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "ViewController.h"
#import "NEMediaCaptureEntity.h"
#import "MediaCaptureViewController.h"
#import "NELivePlayerViewController.h"

@interface ViewController (){
    LSVideoParaCtxConfiguration* paraCtx;
 
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
 
    [self initData];
    
}
-(void)initData{
    //默认高清 以后可根据网络状况比如wifi或4G或3G来建议用户选择不同质量 可一行创建默认质量
    paraCtx =  [LSVideoParaCtxConfiguration defaultVideoConfiguration:LSVideoParamQuality_Super];
    paraCtx.bitrate = 800000;//码率
    
    paraCtx.isUseExternalCapture = NO;//是否使用外部视频采集,假设使用外部采集时，摄像头的采集帧率一定要于设置的paraCtx.fps一致，同时码率要调整为对应的码率,对应的分辨率也需要调整
    
    [NEMediaCaptureEntity sharedInstance].encodeType = 0; //软编码  2硬编码
    
    paraCtx.fps = 20;//帧率，建议在10~24之间
    
    paraCtx.isCameraZoomPinchGestureOn = YES; //开启变焦
    
    paraCtx.isVideoFilterOn = YES;//使用滤镜
    paraCtx.filterType = LS_GPUIMAGE_ZIRAN;//美白 自然
    
    paraCtx.isVideoWaterMarkEnabled = YES; //水印
    
    paraCtx.isQosOn = YES; //防阻塞
    
    paraCtx.isFrontCameraMirroredPreView = YES; //前置摄像头 cameraPosition
    
    paraCtx.videoRenderMode = LS_VIDEO_RENDER_MODE_SCALE_16x9; //无论采集多大分辨率，显示比例为16:9
    
    paraCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_PORTRAIT;//屏幕方向
    paraCtx.cameraPosition = LS_CAMERA_POSITION_FRONT;
    
    [self reloadData];
    
}
- (IBAction)zhibo:(id)sender {
    MediaCaptureViewController *mediaCaptureVC = [[MediaCaptureViewController alloc] initWithUrl:@"rtmp://pbd029ddb.live.126.net/live/3733b527628b45aaa52be32424a7c260?wsSecret=f5605c638b48193637d6f1b996dfe035&wsTime=1510279523" sLSctx:[NEMediaCaptureEntity sharedInstance].videoParaCtx];
    [self presentViewController:mediaCaptureVC animated:YES completion:nil];
}
- (IBAction)kanZhiBo:(id)sender {
    NSMutableArray *decodeParm = [[NSMutableArray alloc] init];
    [decodeParm addObject:@"software"];
    [decodeParm addObject:@"livestream"];
    
    NELivePlayerViewController *nelpViewController = [[NELivePlayerViewController alloc] initWithURL:[[NSURL alloc] initWithString:@"rtmp://vbd029ddb.live.126.net/live/3733b527628b45aaa52be32424a7c260"] andDecodeParm:decodeParm];
    [self presentViewController:nelpViewController animated:YES completion:nil];
}
#pragma mark - 画面旋转
-(BOOL)shouldAutorotate
{
    return YES;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)reloadData {
    
    [NEMediaCaptureEntity sharedInstance].videoParaCtx = paraCtx;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
       paraCtx = [NEMediaCaptureEntity sharedInstance].videoParaCtx;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
