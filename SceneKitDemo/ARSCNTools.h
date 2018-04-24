//
//  ARSCNTools.h
//  SceneKitDemo
//
//  Created by 张贝贝 on 2018/4/24.
//  Copyright © 2018年 张贝贝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface ARSCNTools : NSObject

/// 为几何体添加材质，strSourcePath需要解析的数据文件路径
+ (void)addMaterialsForGeometry:(SCNGeometry *)geometry sourcePath:(NSString *)strSourcePath;

/// 为node上的材质贴图
+ (void)addMaterialsForNode:(SCNNode *)node sourcePath:(NSString *)strSourcePath;

@end
