//
//  ARSCNTools.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2018/4/24.
//  Copyright © 2018年 张贝贝. All rights reserved.
//

#import "ARSCNTools.h"

@implementation ARSCNTools

+ (void)addMaterialsForGeometry:(SCNGeometry *)geometry sourcePath:(NSString *)strSourcePath
{
    NSString *strBundle = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:strSourcePath];
    NSString *string = [NSString stringWithContentsOfFile:strBundle encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictData  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    /// 配置数据里取出所有材质数据
    NSArray *aryMaterialDatas = [dictData objectForKey:@"materials"];
    
    NSMutableArray *maryMaterials = [[NSMutableArray alloc] init];
    
    for (SCNMaterial *material in geometry.materials)
    {
        for (NSDictionary *dict in aryMaterialDatas)
        {
            /// 使用材质名称找到数据，取出需要的贴图
            if ([material.name isEqualToString:dict[@"mtlname"]])
            {
                NSString *strImgName = dict[@"albedo"];
                material.diffuse.contents = [UIImage imageNamed:[NSString stringWithFormat:@"DELL_bijiben_4669885.scnassets/%@",strImgName]];
                break;
            }
        }
        [maryMaterials addObject:material];
    }
    
    geometry.materials = maryMaterials;
}

+ (void)addMaterialsForNode:(SCNNode *)node sourcePath:(NSString *)strSourcePath
{
    /// 如果有子节点，就去遍历子节点，如果没有子节点，就为该node的几何体贴图
    if (node.childNodes.count > 0)
    {
        for (SCNNode *childNode in node.childNodes)
        {
            [ARSCNTools addMaterialsForNode:childNode sourcePath:strSourcePath];
        }
    }
    else
    {
        [ARSCNTools addMaterialsForGeometry:node.geometry sourcePath:strSourcePath];
    }
}

@end