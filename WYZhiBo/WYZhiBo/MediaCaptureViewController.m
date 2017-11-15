//
//  MediaCaptureViewController.m
//  lsMediaCapture
//
//  Created by zhuling on 15/7/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "MediaCaptureViewController.h"
#import "NELogoView.h"
#import "NEInternalMacro.h"
#import "NESelectionView.h"
#import "NEMenuCollectionView.h"
#import "NEFunctionView.h"
#import "NEReachability.h"
#import "UIAlertView+NE.h"
#import "NEAuthorizeManager.h"
#import "NEMediaCaptureEntity.h"

#import "NEStatisticalInformationView.h"
#import "NETrackingSliderView.h"

#import "NECamera.h"
#import "NEReadFileManager.h"






#define kFilterTableViewAnimationTime 0.2f

//UI
#define kFilterHeight   30



@interface MediaCaptureViewController () <BackDelegate, SelectDelegate, DidSelectItemAtIndexPathDelegate, FunctionViewDelegate,NECameraDelegate,NEReadFileManagerDelegate

>

//头部：查看统计信息，闪光灯，关闭
@property (nonatomic, strong) NELogoView *logoView;
//底部：选择菜单（开始／暂停  切换前后摄像头  滤镜  伴奏  趣味人脸）
@property (nonatomic, strong) NESelectionView *selectView;
//底部偏上：录制过程的：录制、音频、视频开启／暂停，截屏，添加水印
@property (nonatomic, strong) NEFunctionView *funcitonView;
//底部：弹出菜单选择
@property (nonatomic, strong) NEMenuCollectionView *menuAudioView;//伴奏
@property (nonatomic, strong) NEMenuCollectionView *menuFilterView;//滤镜
@property (nonatomic, strong) NEMenuCollectionView *menuWaterMarkView;//水印
@property (nonatomic, strong) UIAlertView *errorInfoView;//错误信息动态显示试图
@property (nonatomic, strong) UIAlertView *alert;//提醒用户当前正在直播
@property (nonatomic, strong) UIView *localPreview;//相机预览视图

@property(nonatomic, strong) UIView *allView;
@property(nonatomic, strong) UISegmentedControl *allSegment;
@property(nonatomic, strong) NEStatisticalInformationView* staticInfoView;//统计信息
@property(nonatomic, strong) NETrackingSliderView *trackSliderView;//slider
@property (nonatomic, strong) UISegmentedControl *previewMirrorSegment;//镜像
@property (nonatomic, strong) UISegmentedControl *codeMirrorSegment;
@property (nonatomic, strong) UISegmentedControl *changeQuailtySegment;//分辨率


/**
 作为外部摄像头
 */
@property (nonatomic, strong) NECamera *camera;
//直播SDK API
@property (nonatomic,strong) LSMediaCapture *mediaCapture;

@end

@implementation MediaCaptureViewController{
    NSString* _streamUrl;//推流地址
    LSVideoParaCtxConfiguration* paraCtx;//推流视频参数设置
    BOOL _isLiving;//是否正在直播
    BOOL _needStartLive;//是否需要开启直播
    LSCameraPosition _isBackCameraPosition;//前置或后置摄像头
    LSCameraOrientation _interfaceOrientation;//摄像头采集方向
    BOOL _isRecording;//是否正在录制
    
    BOOL _isAccess;
    

}

@synthesize localPreview;
- (instancetype)initWithUrl:(NSString*)url sLSctx:(LSVideoParaCtxConfiguration *)sLSctx
{
    self = [self init];
    if(self) {
        _streamUrl = url;
        paraCtx = sLSctx;
        [NEMediaCaptureEntity sharedInstance].videoParaCtx = sLSctx;
        _needStartLive = NO;
        _isLiving = NO;
        _isBackCameraPosition = LS_CAMERA_POSITION_FRONT;
        _isAccess = YES;
        _isRecording = NO;
        
    }
    return self;
}

#pragma mark - UI Setup
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    paraCtx = [NEMediaCaptureEntity sharedInstance].videoParaCtx;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NEMediaCaptureEntity sharedInstance].videoParaCtx = paraCtx;
}

//===================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置常亮不锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    

    
    [self setupSubviews];
    
    
    //初始化直播参数，并创建音视频直播
    LSLiveStreamingParaCtxConfiguration *streamparaCtx = [LSLiveStreamingParaCtxConfiguration defaultLiveStreamingConfiguration];;
    NSUInteger encodeType = [NEMediaCaptureEntity sharedInstance].encodeType;
    switch (encodeType) {
        case 0:
            streamparaCtx.eHaraWareEncType = LS_HRD_NO;
            break;
        case 2:
            streamparaCtx.eHaraWareEncType = LS_HRD_AV;
            break;
        default:
            streamparaCtx.eHaraWareEncType = LS_HRD_NO;
            break;
    }
    streamparaCtx.eOutFormatType               = LS_OUT_FMT_RTMP;
    streamparaCtx.eOutStreamType               = LS_HAVE_AV; //这里可以设置推音视频流／音频流／视频流，如果只推送视频流，则不支持伴奏播放音乐
    streamparaCtx.uploadLog                    = YES;//是否上传sdk日志
    streamparaCtx.sLSVideoParaCtx = paraCtx;
    
    
    //是否使用外部视频采集
    if (streamparaCtx.sLSVideoParaCtx.isUseExternalCapture) {
        if (/* DISABLES CODE */ (1)) {
            //1.从外部摄像头获取数据
            _camera = [[NECamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront captureFormat:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
            _camera.delegate = self;
            [_camera startCapture];
        }else{
            //2.从yuv文件获取数据
            [NEReadFileManager sharedInstance].delegate = self;
            [[NEReadFileManager sharedInstance] startYuvFile];
        }
    }

    _mediaCapture = [[LSMediaCapture alloc]initLiveStream:_streamUrl withLivestreamParaCtxConfiguration:streamparaCtx];
    if (_mediaCapture == nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"初始化失败" forKey:NSLocalizedDescriptionKey];
        [self showErrorInfo:[NSError errorWithDomain:@"LSMediaCaptureErrorDomain" code:0 userInfo:userInfo]];
    }
    
    //请注意：监听对象已修改，不再是_mediaCapture，同时去除原先的SDK_dellloc通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onStartLiveStream:) name:LS_LiveStreaming_Started object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onFinishedLiveStream:) name:LS_LiveStreaming_Finished object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBadNetworking:) name:LS_LiveStreaming_Bad object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSpeedStartLiveStream:) name:LS_LiveStreaming_SpeedStart object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSpeedStopLiveStream:) name:LS_LiveStreaming_SpeedStop object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(backgroundStopLiveStream:)
//                                             name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(callEnterForeground:)
//                                             name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNetworkConnectChanged:) name:ne_kReachabilityChangedNotification object:nil];
    
    
    //对外发布时，建议屏蔽该2行
    // 设置sdk详细打印的接口
//    [_mediaCapture setTraceLevel:LS_LOG_QUIET];

    
    BOOL success = YES;
    success = [[NEAuthorizeManager sharedInstance] requestMediaCapturerAccessWithCompletionHandler:^(BOOL value, NSError* error){
        if (error) {
            [self showErrorInfo:error];
        }
    }];
    if (success == NO ) {
        self.selectView.startBtn.enabled = NO;
        _isAccess = NO;
        return;
    }else{
        self.selectView.startBtn.enabled = YES;
    }
    
    __weak MediaCaptureViewController *weakSelf = self;
    
    // 当用户想拿到摄像头的数据自己做一些处理，再经过网易视频云推送出去,请实现下列接口,在打开preview之前使用，preview看到的将是没有做过任何处理的图像
    _mediaCapture.externalCaptureSampleBufferCallback = ^(CMSampleBufferRef sampleBuffer)
    {
//        NSLog(@"做一些视频前处理操作");

        //然后塞给 推流sdk
        [weakSelf.mediaCapture externalInputSampleBuffer:sampleBuffer];
    };
    
//    _mediaCapture.externalCaptureAudioRawData = ^(unsigned char *rawData, unsigned int rawDataSize) {
//        NSLog(@"做一些音频前处理操作");
//        //然后塞给 推流sdk
//        [weakSelf.mediaCapture externalInputAudioRawData:rawData dataSize:rawDataSize];
//    };
    
    
    if (paraCtx.isVideoWaterMarkEnabled) {
        [self addWaterMarkLayer:paraCtx.videoStreamingQuality];
        [self addDynamicWaterMark:paraCtx.videoStreamingQuality];
    }
    
    if (streamparaCtx.eOutStreamType != LS_HAVE_AUDIO) {
        //打开摄像头预览
        [_mediaCapture startVideoPreview:self.localPreview];
        
//        self.localPreview.frame = CGRectMake(self.localPreview.frame.origin.x, self.localPreview.frame.origin.y, self.localPreview.frame.size.width/2, self.localPreview.frame.size.height/2);
//        [self.localPreview setNeedsDisplay];
    } 
    
    
    [_mediaCapture getSDKVersionID];
    
}

//外部采集摄像头的数据塞回来给SDK推流
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    //然后塞给 推流sdk
    [self.mediaCapture externalInputSampleBuffer:sampleBuffer];
}

//文件读取的数据塞回来给SDK推流
-(void)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    //然后塞给 推流sdk
    [self.mediaCapture externalInputSampleBuffer:sampleBuffer];
}

- (void)setupSubviews {
    paraCtx = [NEMediaCaptureEntity sharedInstance].videoParaCtx;
    _interfaceOrientation = paraCtx.interfaceOrientation;

    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    NSInteger width = 0, height = 0, statusBarheight = 0, sliderHeight = 0;
    if (_interfaceOrientation == LS_CAMERA_ORIENTATION_PORTRAIT || _interfaceOrientation == LS_CAMERA_ORIENTATION_UPDOWN) {
        width = self.view.bounds.size.width;
        height = self.view.bounds.size.height;
        sliderHeight = UIScale(50);
    }else{
        width = self.view.bounds.size.height;
        height = self.view.bounds.size.width;
        statusBarheight = 20;
        sliderHeight = UIScale(40);
    }
    
    //====================头部：查看统计信息，闪光灯，关闭====================//
    self.logoView = [[NELogoView alloc] initWithFrame:CGRectMake(0, 0-statusBarheight, width, UIScale(50))];
    self.logoView.backDeleagte = self;
    [self.view addSubview:self.logoView];
    
    //==========底部：选择菜单（开始／暂停  切换前后摄像头  滤镜  伴奏  趣味人脸  水印）==========//
    self.selectView = [[NESelectionView alloc] initWithFrame:CGRectMake(0, height-UIScale(77), width, UIScale(77))];
    self.selectView.selectDelegate = self;
    [self.selectView selectionFilter:paraCtx.isVideoFilterOn];
    [self.view addSubview:self.selectView];
    
    self.menuAudioView = [[NEMenuCollectionView alloc] initWithFrame:CGRectMake(0, height-UIScale(77), width, UIScale(77))];
    self.menuAudioView.hidden = YES;
    self.menuAudioView.didSelDelegate = self;
    [self.menuAudioView reloadData:ModelBtnTypeAudio];
    [self.view addSubview:self.menuAudioView];
    
    self.menuFilterView = [[NEMenuCollectionView alloc] initWithFrame:CGRectMake(0, height-UIScale(77), width, UIScale(77))];
    self.menuFilterView.hidden = YES;
    self.menuFilterView.didSelDelegate = self;
    [self.menuFilterView reloadData:ModelBtnTypeFilter];
    [self.view addSubview:self.menuFilterView];
    
    
    self.menuWaterMarkView = [[NEMenuCollectionView alloc] initWithFrame:CGRectMake(0, height-UIScale(77), width, UIScale(77))];
    self.menuWaterMarkView.hidden = YES;
    self.menuWaterMarkView.didSelDelegate = self;
    [self.menuWaterMarkView reloadData:ModelBtnTypeWaterMark];
    [self.view addSubview:self.menuWaterMarkView];
    
    //==========录制过程的：录制、音频、视频开启／暂停，截屏，添加水印===================//
    self.funcitonView = [[NEFunctionView alloc] initWithFrame:CGRectMake(0, height-UIScale(154), width, UIScale(77))];
    self.funcitonView.functionViewDelegate = self;
    [self.view addSubview:self.funcitonView];
    self.funcitonView.hidden = YES;
    
    //====================视频预览====================//
    self.localPreview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width,  height)];
    self.localPreview.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//    tap.numberOfTapsRequired = 2;
    [tap addTarget:self action:@selector(touchBtnPressed)];
    [self.localPreview addGestureRecognizer:tap];
    
    //====================动态统计信息显示视图====================//
    self.errorInfoView = [[UIAlertView alloc]initWithTitle:@"错误信息" message:@"直播出现错误则会抛出" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    
    self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前正在直播，是否确定退出" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    
    
    [self.view insertSubview:localPreview atIndex:0];
    
    //总的view
    self.allView = [[UIView alloc] initWithFrame:CGRectMake(0, UIScale(60), width, UIScale(200))];
    self.allView.alpha = 0.5;
    self.allView.backgroundColor = [UIColor grayColor];
    self.allView.hidden = YES;
    [self.view addSubview:self.allView];
    
    //总的开关
    self.allSegment = [[UISegmentedControl alloc] initWithItems:@[@"统计信息",@"滚动条",@"镜像",@"分辨率"]];
    [self.allSegment addTarget:self action:@selector(onActionAllSegment:) forControlEvents:UIControlEventValueChanged];
    self.allSegment.selectedSegmentIndex = 0;
    self.allSegment.frame = CGRectMake(UIScale(20), UIScale(10), UIScale(280), UIScale(30));
    [self.allView addSubview:self.allSegment];
    
    //统计信息
    self.staticInfoView = [[NEStatisticalInformationView alloc] initWithFrame:CGRectMake(0, UIScale(40), width, UIScale(160))];
    self.staticInfoView.hidden = NO;
    [self.allView addSubview:self.staticInfoView];
    
    //滚动条
    self.trackSliderView = [[NETrackingSliderView alloc] initWithView:paraCtx tag:^(SliderTag tag,CGFloat value) {
        if (tag == zoomTag) {
            _mediaCapture.zoomScale = value;
        }else if (tag == ContrastTag){
            [_mediaCapture setSmoothFilterIntensity:value];
        }else if (tag == WhiteTag){
            [_mediaCapture setWhiteningFilterIntensity:value];
        }else{
            [_mediaCapture adjustExposure:value];
        }
    }];
    self.trackSliderView.frame = CGRectMake(0, UIScale(40), width, UIScale(160));
    self.trackSliderView.hidden = YES;
    [self.allView addSubview:self.trackSliderView];
    
    //镜像开关
    self.previewMirrorSegment = [[UISegmentedControl alloc] initWithItems:@[@"预览镜像",@"不镜像"]];
    [self.previewMirrorSegment addTarget:self action:@selector(onActionPreviewMirror:) forControlEvents:UIControlEventValueChanged];
    if (paraCtx.isFrontCameraMirroredPreView) {
        self.previewMirrorSegment.selectedSegmentIndex = 0;
    }else{
        self.previewMirrorSegment.selectedSegmentIndex = 1;
    }
    self.previewMirrorSegment.frame = CGRectMake(UIScale(20), UIScale(60), UIScale(140), UIScale(30));
    [self.allView addSubview:self.previewMirrorSegment];
    self.previewMirrorSegment.hidden = YES;
    
    self.codeMirrorSegment = [[UISegmentedControl alloc] initWithItems:@[@"编码镜像",@"不镜像"]];
    [self.codeMirrorSegment addTarget:self action:@selector(onActionCodeMirror:) forControlEvents:UIControlEventValueChanged];
    if (paraCtx.isFrontCameraMirroredCode) {
        self.codeMirrorSegment.selectedSegmentIndex = 0;
    }else{
        self.codeMirrorSegment.selectedSegmentIndex = 1;
    }
    self.codeMirrorSegment.frame = CGRectMake(UIScale(170), UIScale(60), UIScale(140), UIScale(30));
    [self.allView addSubview:self.codeMirrorSegment];
    self.codeMirrorSegment.hidden = YES;
    
    //分辨率
    self.changeQuailtySegment = [[UISegmentedControl alloc] initWithItems:@[@"低清",@"标清",@"高清",@"超清",@"超高清"]];
    [self.changeQuailtySegment addTarget:self action:@selector(onActionChangeQuailty:) forControlEvents:UIControlEventValueChanged];
    switch (paraCtx.videoStreamingQuality) {
        case LS_VIDEO_QUALITY_LOW:
            self.changeQuailtySegment.selectedSegmentIndex = 0;
            break;
        case LS_VIDEO_QUALITY_MEDIUM:
            self.changeQuailtySegment.selectedSegmentIndex = 1;
            break;
        case LS_VIDEO_QUALITY_HIGH:
            self.changeQuailtySegment.selectedSegmentIndex = 2;
            break;
        case LS_VIDEO_QUALITY_SUPER:
            self.changeQuailtySegment.selectedSegmentIndex = 3;
            break;
        case LS_VIDEO_QUALITY_SUPER_HIGH:
            self.changeQuailtySegment.selectedSegmentIndex = 4;
            break;
        default:
            break;
    }
    self.changeQuailtySegment.frame = CGRectMake(UIScale(20), UIScale(60), UIScale(280), UIScale(30));
    [self.allView addSubview:self.changeQuailtySegment];
    self.changeQuailtySegment.hidden = YES;
    
    

}

-(void)onActionAllSegment:(id)sender{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            self.staticInfoView.hidden = NO;
            self.trackSliderView.hidden = YES;
            self.previewMirrorSegment.hidden = YES;
            self.codeMirrorSegment.hidden = YES;
            self.changeQuailtySegment.hidden = YES;

        }
            break;
        case 1:
        {
            self.staticInfoView.hidden = YES;
            self.trackSliderView.hidden = NO;
            self.previewMirrorSegment.hidden = YES;
            self.codeMirrorSegment.hidden = YES;
            self.changeQuailtySegment.hidden = YES;

        }
            break;
        case 2:
        {
            self.staticInfoView.hidden = YES;
            self.trackSliderView.hidden = YES;
            self.previewMirrorSegment.hidden = NO;
            self.codeMirrorSegment.hidden = NO;
            self.changeQuailtySegment.hidden = YES;

        }
            break;
        case 3:
        {
            self.staticInfoView.hidden = YES;
            self.trackSliderView.hidden = YES;
            self.previewMirrorSegment.hidden = YES;
            self.codeMirrorSegment.hidden = YES;
            self.changeQuailtySegment.hidden = NO;

        }
            break;
        default:
            break;
    }
}

-(void)onActionPreviewMirror:(id)sender{
    [_mediaCapture changeIsFrontPreViewMirrored];
}

-(void)onActionCodeMirror:(id)sender{
    [_mediaCapture changeIsFrontCodeMirrored];
}


-(void)onActionChangeQuailty:(id)sender{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    LSVideoStreamingQuality quality = paraCtx.videoStreamingQuality;
    switch (control.selectedSegmentIndex) {
        case 0:
            quality = LS_VIDEO_QUALITY_LOW;
            break;
        case 1:
            quality = LS_VIDEO_QUALITY_MEDIUM;
            break;
        case 2:
            quality = LS_VIDEO_QUALITY_HIGH;
            break;
        case 3:
            quality = LS_VIDEO_QUALITY_SUPER;
            break;
        case 4:
            quality = LS_VIDEO_QUALITY_SUPER_HIGH;
            break;
        default:
            break;
    }
    paraCtx.videoStreamingQuality = quality;
    //切换分辨率，支持直播过程中切换分辨率，切换分辨率，水印将自动清除，需要外部根据分辨率，再次设置水印大小
    [_mediaCapture switchVideoStreamingQuality:quality block:^(LSVideoStreamingQuality quality1) {
        [self addWaterMarkLayer:quality1];
        [self addDynamicWaterMark:quality1];
    }];
}



#pragma mark -网络监听通知
- (void)didNetworkConnectChanged:(NSNotification *)notify{
    NEReachability *reachability = notify.object;
    NENetworkStatus status = [reachability ne_currentReachabilityStatus];
    
    if (status == ReachableViaWiFi) {
        NSLog(@"切换为WiFi网络");
        //开始直播
        __weak typeof(self) weakSelf = self;
        [_mediaCapture startLiveStream:^(NSError *error) {
            if (error != nil) {
                [weakSelf showErrorInfo:error ];
            }
        }];
    }else if (status == ReachableViaWWAN) {
        NSLog(@"切换为移动网络");
        //提醒用户当前网络为移动网络，是否开启直播
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络为移动网络，是否开启直播" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert showAlertWithCompletionHandler:^(NSInteger i) {
            if (i == 0) {
                //开始直播
                __weak typeof(self) weakSelf = self;
                [_mediaCapture startLiveStream:^(NSError *error) {
                    if (error != nil) {
                        [weakSelf showErrorInfo:error ];
                    }
                }];
            }
        }];
    }else if(status == NotReachable) {
        NSLog(@"网络已断开");
        //释放资源
        if (_isLiving) {
            __weak NESelectionView *weakSelectView = self.selectView;
            [_mediaCapture stopLiveStream:^(NSError *error) {
                if(error == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        _isLiving = NO;
                        [weakSelectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
                    });
                }
            }];
        }
    }
}

-(void)callEnterForeground:(NSNotification*)NSNotification
{
    __weak typeof(self) weakSelf = self;
    //回到前台的时候，如果需要开启直播则打开直播
    if (_isLiving ==NO  && _needStartLive){
        [_mediaCapture startLiveStream:^(NSError *error) {
            if (error != nil) {
                [weakSelf showErrorInfo:error ];
            }
        }];
    }
}

//切到后台，默认是已经打开了直播，也就是onlivestreamstart消息已经收到的情况，如果正在打开直播，而用户就要切到后台，也没关系吧，
-(void)backgroundStopLiveStream:(NSNotification*)notification
{
    UIApplication *app = [UIApplication sharedApplication];
    // 定义一个UIBackgroundTaskIdentifier类型(本质就是NSUInteger)的变量
    // 该变量将作为后台任务的标识符
    __block UIBackgroundTaskIdentifier backTaskId;
    backTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"===在额外申请的10分钟内依然没有完成任务===");
        // 结束后台任务
        [app endBackgroundTask:backTaskId];
    }];
    if(backTaskId == UIBackgroundTaskInvalid){
        NSLog(@"===iOS版本不支持后台运行,后台任务启动失败===");
        return;
    }
    
    // 将代码块以异步方式提交给系统的全局并发队列
    __weak NESelectionView *weakSelectView = self.selectView;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"===额外申请的后台任务时间为: %f===",app.backgroundTimeRemaining);
        if(_isLiving){
            // 其他内存清理的代码也可以在此处完成
            [_mediaCapture stopLiveStream:^(NSError *error) {
                if (error == nil) {
                    NSLog(@"退到后台的直播结束了");
                    _isLiving = NO;
                    [weakSelectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
                    _needStartLive = YES;
                    [app endBackgroundTask:backTaskId];
                }
                else{
                    NSLog(@"退到后台的结束直播发生错误");
                    [app endBackgroundTask:backTaskId];
                }
            }];
        }
        //正在录制，就暂停录制
        if (_isRecording) {
            _funcitonView.recordBtn.selected = NO;
            [self recordBtnTapped:_funcitonView.recordBtn];
        }
        
    });
}

//网络不好的情况下，连续一段时间收到这种错误，可以提醒应用层降低分辨率
-(void)onBadNetworking:(NSNotification*)notification
{
     NSLog(@"live streaming on bad networking");
}

-(void)onSpeedStartLiveStream:(NSNotification*)notification{
    NSLog(@"live streaming speed start");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"live streaming speed start");
    });
}

-(void)onSpeedStopLiveStream:(NSNotification*)notification{
    NSLog(@"live streaming speed stop");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"live streaming speed stop");
    });
}

//收到此消息，说明直播真的开始了
-(void)onStartLiveStream:(NSNotification*)notification
{
    NSLog(@"on start live stream");//只有收到直播开始的 信号，才可以关闭直播
    
    __weak NESelectionView *weakSelectView = self.selectView;
    __weak NEFunctionView *weakFunctionView = self.funcitonView;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _isLiving = YES;
        
        weakFunctionView.audioBtn.enabled = YES;
        weakFunctionView.screenCapBtn.enabled = YES;
        
        [weakSelectView.startBtn setBackgroundImage:[UIImage imageNamed:@"stop"]  forState:UIControlStateNormal];
//        [self startButtonPressed:_selectView.startBtn];
//        [self back];

        
        //当直播开始时，获取当前最新的一张图片，用户可以自由选择是否截图
        //        __weak MediaCaptureViewController *weakSelf = self;
        //        [weakSelf.mediaCapture snapShotWithCompletionBlock:^(UIImage *latestFrameImage) {
        //
        //            UIImageWriteToSavedPhotosAlbum(latestFrameImage, weakSelf, nil, nil);
        //
        //        }];
        //
    });
}
//直播结束的通知消息
-(void)onFinishedLiveStream:(NSNotification*)notification
{
    NSLog(@"on finished live stream");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _isLiving = NO;
//        [self startButtonPressed:_selectView.startBtn];
    });
}

-(void)dealloc
{
    if (self.errorInfoView) {
        self.errorInfoView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 头部按钮委托代理
-(void)back{
    __weak MediaCaptureViewController *weakSelf = self;
    __weak NESelectionView *weakSelectView = self.selectView;
    if (_isLiving) {
        //提醒用户当前正在直播
        [self.alert showAlertWithCompletionHandler:^(NSInteger i) {
            if (i == 0) {
                [_mediaCapture stopLiveStream:^(NSError *error) {
                    if(error == nil)
                    {
                        _isLiving = NO;
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [weakSelectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
                            
                            [weakSelf dismissViewControllerAnimated:YES completion:^{
                                //释放占有的系统资源
                                [_mediaCapture unInitLiveStream];
                                _mediaCapture = nil;
                                [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];

                            }];
                        });
                    }else {
                        [self showErrorInfo:error];
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            //释放占有的系统资源
                            [_mediaCapture unInitLiveStream];
                            _mediaCapture = nil;
                            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];

                        }];
                    }
                }];
            }
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            //释放占有的系统资源
            [_mediaCapture unInitLiveStream];
            _mediaCapture = nil;
        }];
    }
}

-(void)flash:(BOOL)isOn;
{
    //前后摄像头切换按钮可用  且  当前为后摄像头
    if (_isBackCameraPosition == LS_CAMERA_POSITION_BACK) {
        if (isOn == YES) {
            _mediaCapture.flash = YES;
            [self.logoView.flashButton setBackgroundImage:[UIImage imageNamed:@"flashstop"] forState:UIControlStateNormal];
        }
        else {
            _mediaCapture.flash = NO;
            [self.logoView.flashButton setBackgroundImage:[UIImage imageNamed:@"flashstart"] forState:UIControlStateNormal];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"前置摄像头不支持闪光灯" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 0) {
                NSLog(@"前置摄像头不支持闪光灯");
            }
        }];
    }
}

-(void)info
{
    if (self.allView.hidden == YES) {
        self.allView.hidden = NO;
    }else{
        self.allView.hidden = YES;
    }
}

- (void)showStatInfo:(LSStatistics)pStatistic
{
    [self.staticInfoView dispalyInfo:pStatistic];
}

//显示错误消息
-(void)showErrorInfo:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errMsg = @"";
        if(error == nil){
            errMsg = @"推流过程中发生错误，请尝试重新开启";

        }else if([error class] == [NSError class]){
            errMsg = [error localizedDescription];
        }else{
            NSLog(@"error = %@", error);
        }
        self.errorInfoView.message = errMsg;
        
        [self.errorInfoView show];
        self.selectView.startBtn.enabled = YES;
        
        _isLiving = NO;
        
        [self.selectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
    });
}

#pragma mark -底部按钮委托代理
-(void)startButtonPressed:(UIButton *)sender
{
    if (_isAccess) {
        sender.selected = !sender.isSelected;
        if(!_isLiving)
        {
            //直播开始之前，需要设置直播出错反馈回调，当然也可以不设置
            __weak MediaCaptureViewController *weakSelf = self;
            _mediaCapture.onLiveStreamError = ^(NSError* error){
                if (error != nil) {
                    [weakSelf LiveStreamErrorInterrup];
                }
                [weakSelf.selectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
            };
            //调用统计数据回调
            _mediaCapture.onStatisticInfoGot = ^(LSStatistics* statistics){
                if (statistics != nil) {
                    LSStatistics statis;
                    memcpy(&statis, statistics, sizeof(LSStatistics));
                    dispatch_async(dispatch_get_main_queue(),^(void){[weakSelf showStatInfo:statis];});
                }
            };
            //开始直播
            
            //出现开始录制，截屏等按钮的view,添加水印
            self.funcitonView.hidden = NO;
            [_mediaCapture startLiveStream:^(NSError *error) {
                if (error != nil) {
                    [weakSelf showErrorInfo:error ];
                    weakSelf.funcitonView.hidden = YES;
                }
            }];
        }else{
            __weak NESelectionView *weakSelectView = self.selectView;
            //直播过程中按钮隐藏
            self.funcitonView.hidden = YES;
            
            [_mediaCapture stopLiveStream:^(NSError *error) {
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        _isLiving = NO;
                        [weakSelectView.startBtn setBackgroundImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
                        //  [_mediaCapture setVideoParameters:LS_VIDEO_QUALITY_LOW bitrate:150000 fps:30 cameraOrientation:LS_CAMERA_ORIENTATION_PORTRAIT];
                        //如果摄像头方向发生变化了，想要camera的预览画面跟着旋转，则在调用一次开启预览
                        //                     [_mediaCapture startVideoPreview:self.localPreview];
                    });
                }
            }];
        }
    }
}

-(void)interestButtonPressed
{
}

-(void)switchButtonPressed
{
    if (self.logoView.flashButton.selected == YES) {
        self.logoView.flashButton.selected = NO;
        [self.logoView.flashButton setBackgroundImage:[UIImage imageNamed:@"flashstart"] forState:UIControlStateNormal];
    }
    _isBackCameraPosition = [_mediaCapture switchCamera:^{
        NSLog(@"切换摄像头");
    }];

}

-(void)mainFilterBtnPressed
{
    self.menuFilterView.hidden = NO;
}

-(void)musicButtonPressed
{
    self.menuAudioView.hidden = NO;
}

-(void)didSelectItem:(ModelBtnType)modelBtnType itemAtIndexPath:(NSInteger)item type:(NSInteger)type
{
    switch (modelBtnType) {
        case ModelBtnTypeAudio:
        {
            switch (item) {
                case 0://无伴音
                {
                    [_mediaCapture stopPlayMusic];//关闭音效
                }
                    break;
                case 1://伴音1
                {
                    NSString* musicFileURL = [[NSBundle mainBundle]pathForResource:@"love" ofType:@"mp3"];
                    if (musicFileURL == nil) {
                        NSLog(@"have not found music file");
                        return;
                    }
                    if (![_mediaCapture startPlayMusic:musicFileURL withEnableSignleFileLooped:YES]) {
                        NSLog(@"播放音乐文件失败");
                        return;
                    };
                }
                    break;
                case 2://伴音2
                {
                    NSString* musicFileURL = [[NSBundle mainBundle]pathForResource:@"lovest" ofType:@"wav"];
                    if (musicFileURL == nil) {
                        NSLog(@"have not found music file");
                        return;
                    }
                    if (![_mediaCapture startPlayMusic:musicFileURL withEnableSignleFileLooped:YES]) {
                        NSLog(@"播放音乐文件失败");
                        return;
                    };
                }
                    break;
                default:
                    [_mediaCapture stopPlayMusic];//关闭音效
                    break;
            }
        }
            break;
        case ModelBtnTypeFilter:
        {
            if ((LSGpuImageFilterType)type == LS_GPUIMAGE_NORMAL) {
                paraCtx.isVideoFilterOn = NO;
                paraCtx.filterType = LS_GPUIMAGE_NORMAL;
            }
            else {
                paraCtx.isVideoFilterOn = YES;
                paraCtx.filterType = (LSGpuImageFilterType)type;
            }
            [_mediaCapture setFilterType:(LSGpuImageFilterType)type];
        }
            break;
        case ModelBtnTypeInterest:
            break;
        case ModelBtnTypeWaterMark:
        {
            switch (item) {
                case 0://无水印
                    paraCtx.isVideoWaterMarkEnabled = NO;
                    [_mediaCapture cleanWaterMark];
                    break;
                case 1://静态水印
                {
                    paraCtx.isVideoWaterMarkEnabled = YES;
                    [_mediaCapture cleanWaterMark];
                    [self addWaterMarkLayer:paraCtx.videoStreamingQuality];
                }
                    break;
                case 2:
                {
                    paraCtx.isVideoWaterMarkEnabled = YES;
                    [_mediaCapture cleanWaterMark];
                    [self addDynamicWaterMark:paraCtx.videoStreamingQuality];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (void)addWaterMarkLayer:(LSVideoStreamingQuality)quality {
    CGRect rect = CGRectZero;
    //自行根据产品定水印在不同分辨率下的大小
    switch (quality) {
        case LS_VIDEO_QUALITY_LOW:
            rect = CGRectMake(10, 10, 100*0.7*0.7*0.7, 54*0.7*0.7*0.7);
            break;
        case LS_VIDEO_QUALITY_MEDIUM:
            rect = CGRectMake(10, 10, 100*0.7*0.7, 54*0.7*0.7);
            break;
        case LS_VIDEO_QUALITY_HIGH:
            rect = CGRectMake(10, 10, 100*0.7, 54*0.7);
            break;
        case LS_VIDEO_QUALITY_SUPER:
            rect = CGRectMake(10, 10, 100, 54);
            break;
        default:
            rect = CGRectMake(10, 10, 100, 54);
            break;
    }
    //添加静态水印
    UIImage* image = [UIImage imageNamed:[[[NSBundle mainBundle] bundlePath]stringByAppendingPathComponent:@"logo.png"]];
    [_mediaCapture addWaterMark:image rect:rect location:LS_WATERMARK_LOCATION_RIGHTUP];
}

- (void)addDynamicWaterMark:(LSVideoStreamingQuality)quality {
    CGRect rect = CGRectZero;
    //自行根据产品定水印在不同分辨率下的大小
    switch (quality) {
        case LS_VIDEO_QUALITY_LOW:
            rect = CGRectMake(10, 10, 220*0.7*0.7*0.7, 80*0.7*0.7*0.7);
            break;
        case LS_VIDEO_QUALITY_MEDIUM:
            rect = CGRectMake(10, 10, 220*0.7*0.7, 80*0.7*0.7);
            break;
        case LS_VIDEO_QUALITY_HIGH:
            rect = CGRectMake(10, 10, 220*0.7, 80*0.7);
            break;
        case LS_VIDEO_QUALITY_SUPER:
            rect = CGRectMake(10, 10, 220, 80);
            break;
        default:
            rect = CGRectMake(10, 10, 220, 80);
            break;
    }
    
    //屏蔽动态水印oppo广告
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 23; i++) {
        NSString *str = [NSString stringWithFormat:@"water%@.png",[NSString stringWithFormat:@"%ld",(long)i]];
        UIImage* image = [UIImage imageNamed:[[[NSBundle mainBundle] bundlePath]stringByAppendingPathComponent:str]];
        [array addObject:image];
    }
    
    //图片数量少时，建议2帧一次显示，图片多时，建议1帧一次显示
    [_mediaCapture addDynamicWaterMarks:array
                               fpsCount:2
                                   loop:YES
                                   rect:rect
                               location:LS_WATERMARK_LOCATION_RIGHTDOWN];
    
}

#pragma mark - 录制等按钮委托代理
//说明：这里需要开发者自己指定存储路径，存储名称以及格式(目前指定为flv)
- (void)recordBtnTapped:(UIButton *)sender {
    if (sender.isSelected) {
        //以开始录制的时间作为时间戳,作为文件名后缀
        NSString *fileName = @"/vcloud_";
        NSDate *date = [NSDate date];
        NSTimeInterval sec = [date timeIntervalSinceNow];
        NSDate *currDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
        
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dfStr = [df stringFromDate:currDate];
        fileName = [fileName stringByAppendingString:dfStr];
        fileName = [fileName stringByAppendingString:@".mp4"];
        
        //存储在Documents路径里
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = arr[0];
        
        NSString *savePath = [documentsPath stringByAppendingString:fileName];
        
        BOOL isStrated = [_mediaCapture startRecord:savePath];
        if (isStrated) {
            _isRecording = YES;
        }
    }else {
        BOOL isStoped = [_mediaCapture stopRecord];
        if (isStoped) {
            _isRecording = NO;
        }
    }
}

- (void)audioBtnTapped:(UIButton *)sender {
    if (sender.isSelected) {
        [_mediaCapture pauseAudioLiveStream];
    }else {
        [_mediaCapture resumeAudioLiveStream];
    }
}

- (void)videoBtnTapped:(UIButton *)sender {
    if (sender.isSelected) {
        [_mediaCapture pauseVideoLiveStream];
    }else {
        [_mediaCapture resumeVideoLiveStream];
    }
}

- (void)screenCapBtnTapped {
    __weak MediaCaptureViewController *weakSelf = self;
    [weakSelf.mediaCapture snapShotWithCompletionBlock:^(UIImage *latestFrameImage) {
         UIImageWriteToSavedPhotosAlbum(latestFrameImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);}];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"截屏保存到本地相册失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 0) {
                NSLog(@"截屏保存到本地相册失败");
            }
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"截屏保存到本地相册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 0) {
                NSLog(@"截屏保存到本地相册成功");
            }
        }];
    }
}

- (void)waterMarkBtnTapped {
    self.menuWaterMarkView.hidden = NO;
}

#pragma mark - touchBtnPressed
- (void)touchBtnPressed{
    self.menuAudioView.hidden = YES;
    self.menuFilterView.hidden = YES;
    self.menuWaterMarkView.hidden = YES;
}

//====================直播操作
-(void)LiveStreamErrorInterrup{
    [_mediaCapture stopLiveStream:^(NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void){[self showErrorInfo:error];});
        }
    }];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 预览画面旋转
-(BOOL)shouldAutorotate
{
    return NO;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    switch (_interfaceOrientation) {
        case LS_CAMERA_ORIENTATION_PORTRAIT:
        {
            return UIInterfaceOrientationMaskPortrait;
            break;
        }
        case LS_CAMERA_ORIENTATION_RIGHT:
        {
            return UIInterfaceOrientationMaskLandscapeRight;
            break;
        }
        case LS_CAMERA_ORIENTATION_LEFT:
        {
            return UIInterfaceOrientationMaskLandscapeLeft;
            break;
        }
        default:{
            return UIInterfaceOrientationMaskPortrait;
            break;
        }
    }
}


@end
