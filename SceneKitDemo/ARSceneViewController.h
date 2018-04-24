//
//  ARSceneViewController.h
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/9/14.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ARType) {
    ARTypeNormal = 1, //点击添加虚拟物体
    ARTypePlane, //自动捕捉平地添加虚拟物体
    ARTypeMove, //虚拟物体跟随相机移动
    ARTypeRotation, //虚拟物体围绕相机旋转
};

@interface ARSceneViewController : UIViewController

@property(nonatomic,assign)ARType arType;

@end
