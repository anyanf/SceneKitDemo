//
//  ARSceneViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/9/14.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "ARSceneViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import "SCNView+Interactive.h"
#import "ARSCNTools.h"

@interface ARSceneViewController ()
<
ARSCNViewDelegate,
ARSessionDelegate
>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0

/// AR视图
@property (nonatomic, strong)ARSCNView *arSceneView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：负责追踪相机的运动
@property(nonatomic,strong)ARWorldTrackingConfiguration *arSessionConfiguration;

#endif


@property (nonatomic, strong)SCNNode *planeNode;

@property (nonatomic, strong)ARPlaneAnchor *planeAnchor;

@end

@implementation ARSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"正在识别平面...可移动屏幕";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Create a session configuration
    if (@available(iOS 11.0, *)) {
        [self.view addSubview:self.arSceneView];
        [self.arSceneView startCustomInterActive];
        
        // Run the view's session
        [self.arSceneView.session runWithConfiguration:self.arSessionConfiguration];
    }
    else
    {
        // Fallback on earlier versions
    }
    /// 添加拍照按钮
    [self addBtnPhoto];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.arSceneView.session pause];
    self.arSceneView.delegate = nil;
    self.arSession.delegate = nil;
}

- (void)addBtnPhoto
{
    /// 添加拍照按钮
    UIButton *btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPhoto.frame = CGRectMake(0, 0, 100, 40);
    btnPhoto.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height - 20);
    btnPhoto.backgroundColor = [UIColor redColor];
    [btnPhoto setTitle:@"拍照" forState:UIControlStateNormal];
    [btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPhoto];
}

- (void)btnPhotoClicked:(id)sender
{
    UIImage *image = [self.arSceneView snapshot];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(id)contextInfo
{
    if(!error)
    {
        NSLog(@"保存图片成功");
        /// 弹框提示
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存图片成功" preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
    else
    {
        NSLog(@"保存图片失败");
    }
}

#pragma mark - 点击事件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self addSceneNodeToNode:self.planeNode postion:SCNVector3Make(self.planeAnchor.center.x, 0, self.planeAnchor.center.z)];
    self.navigationItem.title = @"";
    
//    if (self.arType == ARTypePlane || self.planeNode)
//    {
//        return;
//    }
//
//    UITouch *touch = [[touches allObjects] firstObject];
//    CGPoint point = [touch locationInView:self.arSceneView];
//
//    //1.使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建，这里系统有一个默认的3D飞机）--------在右侧我添加了许多3D模型，只需要替换文件名即可
//    SCNScene *scene = [SCNScene sceneNamed:@"ship.scn"];
//    //2.获取飞机节点（一个场景会有多个节点，此处我们只写，飞机节点则默认是场景子节点的第一个）
//    //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
//    SCNNode *shipNode = scene.rootNode.childNodes[0];
//    //飞机比较大，释放缩放一下并且调整位置让其在屏幕中间
//    shipNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
//    shipNode.position = SCNVector3Make(0, 0,-10);
//    ;
//    //一个飞机的3D建模不是一气呵成的，可能会有很多个子节点拼接，所以里面的子节点也要一起改，否则上面的修改会无效
//    for (SCNNode *node in shipNode.childNodes) {
//        node.scale = SCNVector3Make(0.5, 0.5, 0.5);
//        node.position = SCNVector3Make(0,0,-10);
//    }
//
//    //3.将飞机节点添加到当前屏幕中
//    [self.arSceneView.scene.rootNode addChildNode:shipNode];
//    self.planeNode = shipNode;
//
//    /// 判断是否是绕相机移动
//    //旋转的话笔者选择的是一个台灯
//    if(self.arType == ARTypeRotation)
//    {
//        //3.绕相机旋转
//        //绕相机旋转的关键点在于：在相机的位置创建一个空节点，然后将台灯添加到这个空节点，最后让这个空节点自身旋转，就可以实现台灯围绕相机旋转
//        //1.为什么要在相机的位置创建一个空节点呢？因为你不可能让相机也旋转
//        //2.为什么不直接让台灯旋转呢？ 这样的话只能实现台灯的自转，而不能实现公转
//        SCNNode *node1 = [[SCNNode alloc] init];
//
//        //空节点位置与相机节点位置一致
//        node1.position = self.arSceneView.scene.rootNode.position;
//
//        //将空节点添加到相机的根节点
//        [self.arSceneView.scene.rootNode addChildNode:node1];
//
//        // !!!将台灯节点作为空节点的子节点，如果不这样，那么你将看到的是台灯自己在转，而不是围着你转
//        [node1 addChildNode:self.planeNode];
//
//        //旋转核心动画
//        CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
//
//        //旋转周期
//        moonRotationAnimation.duration = 30;
//
//        //围绕Y轴旋转360度
//        moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
//        //无限旋转  重复次数为无穷大
//        moonRotationAnimation.repeatCount = FLT_MAX;
//
//        //开始旋转
//        [node1 addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
//    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
#pragma mark - 懒加载

//懒加载会话追踪配置
- (ARWorldTrackingConfiguration *)arSessionConfiguration
{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    
    //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
    if (@available(iOS 11.0, *)) {
        _arSessionConfiguration = [[ARWorldTrackingConfiguration alloc] init];
        //2.设置追踪方向（追踪平面，后面会用到）
        _arSessionConfiguration.planeDetection = ARPlaneDetectionHorizontal;
        //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
        _arSessionConfiguration.lightEstimationEnabled = YES;
    }

    return _arSessionConfiguration;
    
}

//懒加载拍摄会话
- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    //1.创建会话
    if (@available(iOS 11.0, *)) {
        _arSession = [[ARSession alloc] init];
    }
    _arSession.delegate = self;
    //2返回会话
    return _arSession;
}

//创建AR视图
- (ARSCNView *)arSceneView
{

    if (_arSceneView != nil) {
        return _arSceneView;
    }
    //1.创建AR视图
    if (@available(iOS 11.0, *))
    {
        _arSceneView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    }
    
    //2.设置代理  捕捉到平地会在代理回调中返回
    _arSceneView.delegate = self;
    
    //2.设置视图会话
    _arSceneView.session = self.arSession;
    //3.自动刷新灯光（3D游戏用到，此处可忽略）
    _arSceneView.automaticallyUpdatesLighting = YES;
    
    //    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    [_arSceneView addGestureRecognizer:tapGes];
    
    return _arSceneView;
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{

}

- (void)addSceneNodeToNode:(SCNNode *)node postion:(SCNVector3)postion
{
    //1.创建一个场景
    SCNScene *scene = [SCNScene sceneNamed:@"DELL_bijiben_4669885.scnassets/DELL_bijiben_4669885.obj"];
    //2.获取节点 所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
    [ARSCNTools addMaterialsForNode:scene.rootNode
                         sourcePath:@"DELL_bijiben_4669885.scnassets/config.json"];
    //4.设置节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
    scene.rootNode.position = postion;
    
    //5.将节点添加到当前屏幕中
    //!!!此处一定要注意：节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
    [node addChildNode:scene.rootNode];
}

#pragma mark -- ARSCNViewDelegate

//添加节点时候调用（当开启平地捕捉模式之后，如果捕捉到平地，ARKit会自动添加一个平地节点）
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
    if(self.arType != ARTypePlane)
    {
        return;
    }
    
    if (@available(iOS 11.0, *)) {
        if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSLog(@"捕捉到平地");
                
                //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
                
                //1.获取捕捉到的平地锚点
                ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
                //2.创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，这里将其变成一个长方形，并且对平地做了一个缩放效果）
                //参数分别是长宽高和圆角
                SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x height:0 length:planeAnchor.extent.z chamferRadius:0];
                plane.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.5];
                
                //4.创建一个基于3D物体模型的节点
                SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
                //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
                planeNode.position =SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
                [node addChildNode:planeNode];

                self.planeNode = node;
                self.planeAnchor = planeAnchor;
                //2.当捕捉到平地时 提示点击屏幕可以添加物体
                self.navigationItem.title = @"点击屏幕可放置物体";
            });
        }
    }
}

//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点更新");
    
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点移除");
}

#pragma mark -ARSessionDelegate

//会话位置更新（监听相机的移动），此代理方法会调用非常频繁，只要相机移动就会调用，如果相机移动过快，会有一定的误差，具体的需要强大的算法去优化，笔者这里就不深入了
//- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
//{
//    NSLog(@"相机移动");
//    if (self.arType != ARTypeMove) {
//        return;
//    }
//    //移动飞机
//    if (self.planeNode) {
//
//        //捕捉相机的位置，让节点随着相机移动而移动
//        //根据官方文档记录，相机的位置参数在4X4矩阵的第三列
//        self.planeNode.position =SCNVector3Make(frame.camera.transform.columns[3].x,frame.camera.transform.columns[3].y,frame.camera.transform.columns[3].z);
//    }
//
//}
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"添加锚点");
    
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"刷新锚点");
    
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"移除锚点");
    
}

#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
