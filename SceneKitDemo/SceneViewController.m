//
//  SceneViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/14.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "SceneViewController.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>


#define KRotateFactor  (100)

@interface SceneViewController ()


@property (nonatomic, strong) SCNView *scnView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) SCNNode *cameraNode;


/// 本次手机倾斜的角度
@property (nonatomic, assign) CGFloat currentMotionX;
@property (nonatomic, assign) CGFloat currentMotionY;



@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _scnView = [[SCNView alloc] initWithFrame:self.view.bounds];
    _scnView.allowsCameraControl = NO;
    _scnView.showsStatistics = YES;
    _scnView.autoenablesDefaultLighting = YES;
    [self.view addSubview:_scnView];
    
    /// 加载资源，如果是scn格式的，需要有对应的png图片
    if (self.pageType == GME_PageType_3D)
    {
//        _scnView.scene = [SCNScene sceneNamed:@"man.dae" inDirectory:nil options:nil];
        _scnView.scene = [SCNScene scene];
        
        SCNBox *box = [SCNBox boxWithWidth:10 height:10 length:10 chamferRadius:1];
        box.firstMaterial.diffuse.contents = [UIImage imageNamed:@"texture"];
        [_scnView.scene.rootNode addChildNode:[SCNNode nodeWithGeometry:box]];
        
//        _scnView.scene.rootNode.position = SCNVector3Make(0, 0, 0);
        _scnView.scene.rootNode.opacity = 1.0;
        
        // 光
        SCNNode *lightNode = [SCNNode node];
        lightNode.light = [SCNLight light];
        lightNode.light.type = SCNLightTypeAmbient;
        lightNode.light.color = [UIColor colorWithWhite:0.4 alpha:1.0];
        [_scnView.scene.rootNode addChildNode:lightNode];

        // 外围光
        SCNNode *ambientLightNode = [SCNNode node];
        ambientLightNode.light = [SCNLight light];
        ambientLightNode.light.type = SCNLightTypeOmni;
        ambientLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1.0];
        [_scnView.scene.rootNode addChildNode:ambientLightNode];

        // 添加一个观察视角
        _cameraNode = [SCNNode node];
        _cameraNode.camera = [SCNCamera camera];
        _cameraNode.position = SCNVector3Make(0, 0, 20);
        [_scnView.scene.rootNode addChildNode:_cameraNode];
        
//        SCNNode *node = [_scnView.scene.rootNode childNodeWithName:@"ship" recursively:NO];
//        SCNLookAtConstraint *lookAtConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_cameraNode];
//        lookAtConstraint.gimbalLockEnabled = YES;
//        
//        _cameraNode.constraints = @[lookAtConstraint];
        
    }
    else
    {
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
    }
    
    /// 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObject:panGesture];
    [gestureRecognizers addObjectsFromArray:_scnView.gestureRecognizers];
    _scnView.gestureRecognizers = gestureRecognizers;
    
//    for (UIGestureRecognizer *gesture in _scnView.gestureRecognizers)
//    {
//        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
//        {
//            [gesture removeTarget:nil action:nil];
//            [gesture addTarget:self action:@selector(handlePan:)];
//        }
//    }
//
    _motionManager = [[CMMotionManager alloc]init];
    if (_motionManager.deviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = 1.0/30;
        [self startDeviceMotionUpdates];
    }
}

- (void)startDeviceMotionUpdates
{
    
    return;
    _currentMotionY = CGFLOAT_MAX;
    _currentMotionX = CGFLOAT_MAX;
    
    __weak typeof(self) weakSelf = self;

    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
    
        CMAttitude *attitude = motion.attitude;
        
        float angleX = -attitude.pitch/M_PI*180/KRotateFactor;
        float angleY = attitude.roll/M_PI*180/KRotateFactor;
        // float angleZ = -attitude.yaw/M_PI*180;
        
        CGFloat absX = fabs(angleX);
        CGFloat absY = fabs(angleY);
        
        if (_currentMotionX == CGFLOAT_MAX && _currentMotionY == CGFLOAT_MAX)
        {
            _currentMotionX = angleX;
            _currentMotionY = angleY;
            return ;
        }
        
        if (absX > absY)
        {
            CGFloat newAngle = -(angleX - _currentMotionX);
            _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 1, 0, 0);
        }
        else
        {
            CGFloat newAngle = -(angleY - _currentMotionY);
            _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 0, 1, 0);
        }
        
        _currentMotionX = angleX;
        _currentMotionY = angleY;
    }];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // 获取点击的三维坐标系
    SCNVector3 projectedOrigin = [self.scnView projectPoint:SCNVector3Zero];
    CGPoint p = [gestureRecognize locationInView:_scnView];
    SCNVector3 vpWithZ = SCNVector3Make(p.x, p.y, projectedOrigin.z);
    SCNVector3 worldPoint = [self.scnView unprojectPoint:vpWithZ];
    NSLog(@"三维坐标x:----%f,y:----%f,z:----%f",worldPoint.x,worldPoint.y,worldPoint.z);
    
    /// 弹框提示
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"点击位置的三维坐标为x:%f,y:%f,z:%f",worldPoint.x,worldPoint.y,worldPoint.z] preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
//    return;
    [_motionManager stopDeviceMotionUpdates];
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (absX > absY)
    {
        CGFloat newAngle = (CGFloat)translation.x * (CGFloat)M_PI / 180.0 /KRotateFactor;
        _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 0, 1, 0);


        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    else
    {
        CGFloat newAngle = (CGFloat)translation.y * (CGFloat)M_PI / 180.0 /KRotateFactor;
        _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 1, 0, 0);

        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    
}

/**
 *   判断手势方向
 *
 *  @param translation translation description
 */
- (void)commitTranslation:(CGPoint)translation
{

    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    
    
    if (absX > absY )
    {
        
        if (translation.x<0)
        {
            //向左滑动
            /// 旋转
            SCNAction *rotation = [SCNAction rotateByAngle:1.0 aroundAxis:SCNVector3Make(0, 0, 1) duration:0.03];
            [_scnView.scene.rootNode runAction:[SCNAction repeatAction:rotation count:10]];
        }
        else
        {
            //向右滑动
            /// 旋转
            SCNAction *rotation = [SCNAction rotateByAngle:-1.0 aroundAxis:SCNVector3Make(0, 0, 1) duration:0.0];
            [_scnView.scene.rootNode runAction:[SCNAction repeatAction:rotation count:10]];
        }
        
    } else if (absY > absX)
    {
        if (translation.y<0)
        {
            
            //向上滑动
        }
        else
        {
            
            //向下滑动
        }
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
