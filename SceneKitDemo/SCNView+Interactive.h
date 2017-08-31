//
//  SCNView+Interactive.h
//  SceneKitDemo
//
//  Created by kang an on 2017/8/31.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import <SceneKit/SceneKit.h>


@interface SCNView (Interactive)

/// 手势旋转系数 默认 0.01
@property (nonatomic, strong) NSNumber *gestureRotateFactor;

/// 陀螺仪旋转系数 默认 0.0125
@property (nonatomic, strong) NSNumber *motionRotateFactor;





/// 开启自定义交互,一旦开启不可逆
- (void)startCustomInterActive;


@end
