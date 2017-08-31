//
//  Show3DViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/14.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "Show3DViewController.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>


#define KRotateFactor  (100)

@interface Show3DViewController ()


@property (nonatomic, strong) SCNView *scnView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) SCNNode *cameraNode;

@end

@implementation Show3DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _scnView = [[SCNView alloc] initWithFrame:self.view.bounds];
    _scnView.allowsCameraControl = YES;
    _scnView.showsStatistics = YES;
    _scnView.autoenablesDefaultLighting = YES;
    [self.view addSubview:_scnView];
    
    
    /// 加载资源，如果是scn格式的，需要有对应的png图片
//        _scnView.scene = [SCNScene sceneNamed:@"Beijingxiao.scnassets/BeiJing_xiao.obj"];
//        SCNGeometry *geometry = [SCNGeometry geometry];
//        geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"BeiJingxiao.jpg"];
//        _scnView.scene.rootNode.geometry = geometry;
        _scnView.scene = [SCNScene scene];
        
        SCNBox *box = [SCNBox boxWithWidth:10 height:10 length:10 chamferRadius:1];
        SCNMaterial *redMaterial = [SCNMaterial new];
        redMaterial.diffuse.contents = [UIColor redColor];

        SCNMaterial *blueMaterial = [SCNMaterial new];
        blueMaterial.diffuse.contents = [UIColor blueColor];

        SCNMaterial *greenMaterial = [SCNMaterial new];
        greenMaterial.diffuse.contents = [UIColor greenColor];

        box.materials = @[redMaterial,blueMaterial,redMaterial,blueMaterial,greenMaterial,greenMaterial];

        [_scnView.scene.rootNode addChildNode:[SCNNode nodeWithGeometry:box]];
    
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
    
    /// 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:_scnView.gestureRecognizers];
    _scnView.gestureRecognizers = gestureRecognizers;
    
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
        _motionManager.deviceMotionUpdateInterval = 1.0/10;
        _motionManager.gyroUpdateInterval = 1.0/60;
        [self startDeviceMotionUpdates];
    }
}

- (void)startDeviceMotionUpdates
{
    __weak typeof(self) weakSelf = self;

    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        float rotX = gyroData.rotationRate.x/KRotateFactor;
        float rotY = gyroData.rotationRate.y/KRotateFactor;
    
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

- (void)handleTap:(UIGestureRecognizer*)gestureRecognize
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
    [_motionManager stopDeviceMotionUpdates];
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (absX > absY)
    {
        CGFloat newAngle = (CGFloat)translation.x * (CGFloat)M_PI / 180.0 / 80;
        _scnView.scene.rootNode.childNodes.firstObject.pivot = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.pivot,newAngle, 0, 1, 0);


        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    else
    {
        CGFloat newAngle = (CGFloat)translation.y * (CGFloat)M_PI / 180.0 / 80;
        _scnView.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(_scnView.scene.rootNode.childNodes.firstObject.transform,newAngle, 1, 0, 0);

        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
