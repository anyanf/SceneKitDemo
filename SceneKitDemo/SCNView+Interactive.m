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
        float rotY = gyroData.rotationRate.y/weakSelf.motionRotateFactor.floatValue;
        
        if (fabs(rotX) > fabs(rotY))
        {
            weakSelf.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(weakSelf.scene.rootNode.childNodes.firstObject.transform,rotX, 1, 0, 0);
            
        }
        else
        {
            weakSelf.scene.rootNode.childNodes.firstObject.pivot = SCNMatrix4Rotate(weakSelf.scene.rootNode.childNodes.firstObject.pivot,rotY, 0, 1, 0);
        }
    }];
}



- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    [[self motionManager] stopDeviceMotionUpdates];
    CGPoint translation = [gesture translationInView:self];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (absX > absY)
    {
        CGFloat newAngle = (CGFloat)translation.x * (CGFloat)M_PI / 180.0 * self.gestureRotateFactor.floatValue;
        self.scene.rootNode.childNodes.firstObject.pivot = SCNMatrix4Rotate(self.scene.rootNode.childNodes.firstObject.pivot,newAngle, 0, 1, 0);
        
        
        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
    }
    else
    {
        CGFloat newAngle = (CGFloat)translation.y * (CGFloat)M_PI / 180.0 * self.gestureRotateFactor.floatValue;
        self.scene.rootNode.childNodes.firstObject.transform = SCNMatrix4Rotate(self.scene.rootNode.childNodes.firstObject.transform,newAngle, 1, 0, 0);
        
        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            [self startDeviceMotionUpdates];
        }
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


@end
