//
//  RootViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/17.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "RootViewController.h"
#import "Show3DViewController.h"
#import "ARViewController.h"

@interface RootViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *aryData;

@property (nonatomic, strong) NSArray *aryVCClasses;


@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ScenceKit";
    
    _aryData = @[@"全景图片展示",@"3D模型展示",@"AR"];
    _aryVCClasses = @[@"PanoramaViewController",@"Show3DViewController",@"ARViewController"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aryData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId];
    }
    cell.textLabel.text = _aryData[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = [_aryVCClasses objectAtIndex:indexPath.row];
    Class classVC = NSClassFromString(str);
    UIViewController *vc = [[classVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//支持旋转
-(BOOL)shouldAutorotate
{
    return YES;
}

//支持的方向 只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
