//
//  RootNavController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/31.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "RootNavController.h"

@interface RootNavController ()

@end

@implementation RootNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 //支持旋转
-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return [self.topViewController preferredInterfaceOrientationForPresentation];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
