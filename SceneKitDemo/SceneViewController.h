//
//  SceneViewController.h
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/14.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,GME_PageType)
{
    GME_PageType_Panorama = 0,
    GME_PageType_3D = 1
};

@interface SceneViewController : UIViewController

/// 是否展示3D模型
@property (nonatomic, assign) GME_PageType pageType;


@end

