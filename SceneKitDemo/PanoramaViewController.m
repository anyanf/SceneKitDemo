//
//  PanoramaViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/31.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "PanoramaViewController.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>

@interface PanoramaViewController ()

@property (nonatomic, strong) SCNView *scnView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) SCNNode *cameraNode;

@end

@implementation PanoramaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _scnView = [[SCNView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    _scnView.allowsCameraControl = YES;
    _scnView.showsStatistics = YES;
    _scnView.autoenablesDefaultLighting = YES;
    [self.view addSubview:_scnView];
    
    _scnView.scene = [[SCNScene alloc]init];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"house" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    /// 球体
    SCNSphere *sphere = [SCNSphere sphereWithRadius:10.0];
    sphere.firstMaterial.doubleSided = YES;
    sphere.firstMaterial.diffuse.contents = image;
    
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    sphereNode.position = SCNVector3Make(0,0,0);
    [_scnView.scene.rootNode addChildNode:sphereNode];
    
    // 添加一个观察视角
    _cameraNode = [SCNNode node];
    _cameraNode.camera = [SCNCamera camera];
    _cameraNode.position = SCNVector3Make(0, 0, 0);
    [_scnView.scene.rootNode addChildNode:_cameraNode];
    
    for (UIGestureRecognizer *gesture in _scnView.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            [gesture removeTarget:nil action:nil];
            [gesture addTarget:self action:@selector(handlePan:)];
        }
    }
    
    _motionManager = [[CMMotionManager alloc]init];
    if (_motionManager.deviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = 1.0/60;
        [self startDeviceMotionUpdates];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)]) {
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = UIInterfaceOrientationLandscapeLeft;//横屏
        
        [invocation setArgument:&val atIndex:2];
        
        [invocation invoke];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)startDeviceMotionUpdates
{
    __weak typeof(self) weakSelf = self;
    
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error)
     {
         CMAttitude *attitude = motion.attitude;
         weakSelf.cameraNode.eulerAngles = SCNVector3Make(attitude.yaw - M_PI/2.0, attitude.roll, 0);
    }];
}
*/
- (void)startDeviceMotionUpdates
{
    __weak typeof(self) weakSelf = self;
    
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        float rotX = gyroData.rotationRate.x/100;
        float rotY = gyroData.rotationRate.y/100;
        
        if (fabs(rotX) > fabs(rotY))
        {
            weakSelf.scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(weakSelf.scnView.scene.rootNode.childNodes.firstObject.transform,rotX, 1, 0, 0);
            
        }
        else
        {
            weakSelf.scnView.scene.rootNode.childNodes.firstObject.pivot = SCNMatrix4Rotate(weakSelf.scnView.scene.rootNode.childNodes.firstObject.pivot,rotY, 0, 1, 0);
        }
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    [_motionManager stopDeviceMotionUpdates];
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (absX > absY)
    {
        CGFloat newAngle = (CGFloat)translation.x * (CGFloat)M_PI / 180.0 / 50;
        _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 0, 1, 0);
        
        
        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    else
    {
        CGFloat newAngle = (CGFloat)translation.y * (CGFloat)M_PI / 180.0 / 50;
        _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 1, 0, 0);
        
        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
