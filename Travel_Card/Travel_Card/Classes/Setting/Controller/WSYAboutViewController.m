//
//  WSYAboutViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/5.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYAboutViewController.h"
#import "WSYAboutHeadView.h"

@interface WSYAboutViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WSYAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"关于";
    
    WSYAboutHeadView *headVc = [[WSYAboutHeadView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 230)];
    self.tableView.tableHeaderView = headVc;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"给我们评分";
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (@available(ios 11.0,*)) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1426274239?mt=8&action=write-review"];
        [[UIApplication sharedApplication]openURL:url];
    } else {
        NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1426274239&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
        [[UIApplication sharedApplication]openURL:url];
    }
}

#pragma mark -
#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight} style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end
