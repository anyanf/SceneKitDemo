//
//  RootViewController.m
//  SceneKitDemo
//
//  Created by 张贝贝 on 2017/8/17.
//  Copyright © 2017年 张贝贝. All rights reserved.
//

#import "RootViewController.h"
#import "SceneViewController.h"
#import "ARViewController.h"

@interface RootViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *aryData;



@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ScenceKit";
    
    _aryData = @[@"全景图片展示",@"3D模型展示",@"ARKit"];
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
    if (indexPath.row == 2)
    {
        ARViewController *arVC = [[ARViewController alloc] init];
        [self.navigationController pushViewController:arVC animated:YES];
    }
    else
    {
        SceneViewController *sceneVC = [[SceneViewController alloc] init];
        sceneVC.pageType = indexPath.row;
        [self.navigationController pushViewController:sceneVC animated:YES];
    }
}

@end
