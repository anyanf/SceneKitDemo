//
//  SCNView+Interactive.m
//  SceneKitDemo
//
//  Created by kang an on 2017/8/31.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "SCNView+Interactive.h"

#import <objc/runtime.h>

#import <CoreMotion/CoreMotion.h>

static NSString * const interactive_gestureRotateFactor_key = @"interactive_gestureRotateFactor_key";
static NSString * const interactive_motionRotateFactor_key = @"interactive_motionRotateFactor_key";
static NSString * const interactive_motionManager_key = @"interactive_motionManager_key";
static NSString * const interactive_aryNodes_key = @"interactive_aryNodes_key";


@implementation SCNView (Interactive)


- (void)startCustomInterActive
{
    
    /// 默认旋转系数
    if (!self.motionRotateFactor)
    {
        self.motionRotateFactor = @(0.01);
    }
    
    if (!self.gestureRotateFactor)
    {
        self.gestureRotateFactor = @(0.0125);
    }

    for (UIGestureRecognizer *gesture in self.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            [gesture removeTarget:nil action:nil];
            [gesture addTarget:self action:@selector(handlePan:)];
        }
        
    }
    
    CMMotionManager * motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable)
    {
        motionManager.deviceMotionUpdateInterval = 1.0/10;
        motionManager.gyroUpdateInterval = 1.0/60;
        [self startDeviceMotionUpdates];
    }
    
    [self setMotionManager:motionManager];
}



- (void)startDeviceMotionUpdates
{
    __weak typeof(self) weakSelf = self;
    
    [[self motionManager] startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error)
    {
        float rotX = gyroData.rotationRate.x * weakSelf.motionRotateFactor.floatValue;
        float rotY = gyroData.rotationRate.y * weakSelf.motionRotateFactor.floatValue;
        
        if (fabs(rotX) > fabs(rotY))
        {
            [self modifyingNodeTransform:rotX rotateX:1 rotateY:0 rotateZ:0];
        }
        else
        {
            [self modifyingNodeTransform:rotY rotateX:0 rotateY:1 rotateZ:0];
        }
    }];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
    CGPoint tapPoint = [gesture locationInView:self];
    
    NSArray  *result = [self hitTest:tapPoint options:nil];
    
    if ([result count] == 0) {
        return;
    }
    SCNHitTestResult *hitResult = [result firstObject];
    if (hitResult.node) {
        [[hitResult.node parentNode] removeFromParentNode];
    }
}

SCNVector3 oldPoint;
SCNVector3 oldPosition;
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture locationInView:self];
    
    
    if (gesture.numberOfTouches == 2)
    {
        [[self motionManager] stopDeviceMotionUpdates];

        CGPoint translation = [gesture locationInView:self];

        SCNVector3 projectedOrigin = [self projectPoint:SCNVector3Zero];
        SCNVector3 vpWithZ = SCNVector3Make(translation.x, translation.y, projectedOrigin.z);
        SCNVector3 worldPoint = [self unprojectPoint:vpWithZ];
        self.scene.rootNode.position = worldPoint;



        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            oldPoint = worldPoint;
            oldPosition = worldPoint;
        }
        else
        {
            SCNVector3 point = SCNVector3Make(worldPoint.x - oldPoint.x,
                                              worldPoint.y - oldPoint.y,
                                              worldPoint.z - oldPoint.z);

//            self.scene.rootNode.position = point;

//            SCNAction *action = [SCNAction moveTo:point duration:0.0];
//            [self.scene.rootNode runAction:action];
        }

    }
    else
    {
        [[self motionManager] stopDeviceMotionUpdates];

        CGPoint translation = [gesture translationInView:self];
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);

        if (absX > absY)
        {
            CGFloat newAngle = -(CGFloat)translation.x * (CGFloat)M_PI / 180.0 * self.gestureRotateFactor.floatValue;

            [self modifyingNodePivot:newAngle rotateX:0 rotateY:1 rotateZ:0];

            if (gesture.state == UIGestureRecognizerStateEnded)
            {
                [self startDeviceMotionUpdates];
            }
        }
        else
        {
            CGFloat newAngle = (CGFloat)translation.y * (CGFloat)M_PI / 180.0 * self.gestureRotateFactor.floatValue;

            [self modifyingNodeTransform:newAngle rotateX:1 rotateY:0 rotateZ:0];

            if (gesture.state == UIGestureRecognizerStateEnded)
            {
                [self startDeviceMotionUpdates];
            }
        }
    }

}

- (void)modifyingNodeTransform:(CGFloat)newAngle rotateX:(float)rotateX rotateY:(float)rotateY rotateZ:(float)rotateZ
{

    if (self.aryNodes)
    {
        for (SCNNode *node in self.aryNodes)
        {
            node.transform = SCNMatrix4Rotate(node.transform,
                                              newAngle,
                                              rotateX,
                                              rotateY,
                                              rotateZ);
        }
    }
    else
    {
        self.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(self.scene.rootNode.childNodes.firstObject.transform,
                                                                                newAngle,
                                                                                rotateX,
                                                                                rotateY,
                                                                                rotateZ);
    }
    
}

- (void)modifyingNodePivot:(CGFloat)newAngle rotateX:(float)rotateX rotateY:(float)rotateY rotateZ:(float)rotateZ
{
    if (self.aryNodes)
    {
        for (SCNNode *node in self.aryNodes)
        {
            node.pivot = SCNMatrix4Rotate(node.pivot,
                                          newAngle,
                                          rotateX,
                                          rotateY,
                                          rotateZ);
        }
    }
    else
    {
        self.scene.rootNode.childNodes.firstObject.pivot = SCNMatrix4Rotate(self.scene.rootNode.childNodes.firstObject.pivot,
                                                                            newAngle,
                                                                            rotateX,
                                                                            rotateY,
                                                                            rotateZ);
    }
}


#pragma mark - 各种属性的 set & get

- (NSNumber *)gestureRotateFactor
{
    return objc_getAssociatedObject(self, &interactive_gestureRotateFactor_key);
}
- (void)setGestureRotateFactor:(NSNumber *)gestureRotateFactor
{
    objc_setAssociatedObject(self, &interactive_gestureRotateFactor_key, gestureRotateFactor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)motionRotateFactor
{
    return objc_getAssociatedObject(self, &interactive_motionRotateFactor_key);
}
- (void)setMotionRotateFactor:(NSNumber *)motionRotateFactor
{
    objc_setAssociatedObject(self, &interactive_motionRotateFactor_key, motionRotateFactor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CMMotionManager *)motionManager
{
    return objc_getAssociatedObject(self, &interactive_motionManager_key);

}
- (void)setMotionManager:(CMMotionManager *)motionManager
{
    objc_setAssociatedObject(self, &interactive_motionManager_key, motionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)aryNodes
{
    return objc_getAssociatedObject(self, &interactive_aryNodes_key);
}
- (void)setAryNodes:(NSArray *)aryNodes
{
    objc_setAssociatedObject(self, &interactive_aryNodes_key, aryNodes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
