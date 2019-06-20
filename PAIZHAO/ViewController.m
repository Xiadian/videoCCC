//
//  ViewController.m
//  PAIZHAO
//
//  Created by Xuezhipeng on 2017/4/13.
//  Copyright © 2017年 Xuezhipeng. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<AVCaptureFileOutputRecordingDelegate,CAAnimationDelegate>
@property (strong, nonatomic) AVCaptureMovieFileOutput *output;
@property (strong, nonatomic) UIView *top;
@property (assign, nonatomic) NSInteger second;
@property (strong, nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong, nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@property (strong, nonatomic) UIImageView *imageView;//负责从AVCaptureDevice获得输入数据
@property (strong, nonatomic) UILabel *redView;//

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.redView = [[UILabel alloc] init];
    self.redView.backgroundColor = [UIColor redColor];
    self.redView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-10 , 0, 10, 10);
    self.redView.layer.cornerRadius=5;
    self.redView.clipsToBounds=YES;
}


//拍摄完成回调
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            // NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }else{
            
            //  NSLog(@"成功保存视频到相簿.");
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    self.second=0;
    self.navigationController.navigationBar.hidden=NO;
    [UIApplication sharedApplication].statusBarHidden=YES;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //2.初始化一个摄像头输入设备(first是后置摄像头，last是前置摄像头)
    AVCaptureDeviceInput *inputCamare = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    //3.创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //4.初始化麦克风输入设备
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    //　二，初始化视频文件输出
    //初始化设备输出对象，用于获得输出数据
    //    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    //    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    //    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //5.初始化一个movie的文件输出
    AVCaptureMovieFileOutput *output =[[AVCaptureMovieFileOutput alloc]init];
    self.output = output;
    AVCaptureSession *session =[[AVCaptureSession alloc]init];
    if ([session canAddInput:inputCamare]) {
        [session addInput:inputCamare];}
    if ([session canAddInput:inputAudio]) {
        [session addInput:inputAudio];}
    if ([session canAddOutput:output])
    {[session addOutput:output];}
    //    if ([session canAddOutput:_captureStillImageOutput]) {
    //        [session addOutput:_captureStillImageOutput];
    //    }
    self.captureSession=session;
    //摄像view
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preLayer.frame =CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    preLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preLayer];
    UIImageView *vv=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [vv addGestureRecognizer:tap];
    vv.userInteractionEnabled=YES;
    vv.image=[UIImage imageNamed:@"book.png"];
    self.imageView=vv;
    [self.view addSubview:vv];
}
-(void)tap{
    self.second+=1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    if ([self.output isRecording]) {
        [self.redView removeFromSuperview];
        [self.output stopRecording];
        return;
    }
    [self.view addSubview:self.redView];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVidio.mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.output startRecordingToOutputFileURL:url recordingDelegate:self];
    
    if (self.second<6) {
        CATransition *ca=[[CATransition alloc]init];
        ca.duration=1;
        ca.subtype = kCATransitionFromBottom;
        ca.type=@"pageCurl";
        [self.imageView.layer addAnimation:ca forKey:nil];
        self.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%zd.png",self.second]];
    }
    else{
        self.second=1;
        CATransition *ca=[[CATransition alloc]init];
        ca.duration=1;
        ca.subtype = kCATransitionFromBottom;
        ca.type=@"pageCurl";
        [self.imageView.layer addAnimation:ca forKey:nil];
        self.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%zd.png",self.second]];
    }
}
-(void)getBTN{
    NSMutableArray *pathArr=[NSMutableArray new];
    for (int i=0; i<10; i++) {
        CGPoint pastLocation =CGPointMake(arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.width), arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.height*3/4));
        NSValue *pastpoint=[NSValue valueWithCGPoint:pastLocation];
        [pathArr addObject:pastpoint];
    }
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor=[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    btn.frame=CGRectMake(arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.width), arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.height), 30, 30);
    btn.layer.cornerRadius=15;
    btn.clipsToBounds=YES;
    [self.view addSubview:btn];
    CAKeyframeAnimation *an=[CAKeyframeAnimation animation];
    an.keyPath=@"position";
    an.values=pathArr;
    an.duration=10;
    an.delegate=self;
    an.removedOnCompletion=NO;
    an.fillMode=kCAFillModeForwards;
    [btn.layer addAnimation:an forKey:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end

