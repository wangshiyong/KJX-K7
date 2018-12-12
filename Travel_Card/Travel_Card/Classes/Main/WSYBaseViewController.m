//
//  WSYBaseViewController.m
//  YouBao
//
//  Created by 王世勇 on 2018/5/21.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYBaseViewController.h"

@interface WSYBaseViewController ()

@end

@implementation WSYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupNavBar {
    [self.view addSubview:self.customNavBar];
    
    // 设置自定义导航栏背景图片
//    self.customNavBar.barBackgroundImage = [UIImage imageNamed:@"millcolorGrad"];
//        self.customNavBar.barBackgroundColor = WSYTheme_Color;
    
    // 设置自定义导航栏标题颜色
    self.customNavBar.titleLabelColor = [UIColor blackColor];
//    [self.customNavBar wr_setBottomLineHidden:YES];
    if (self.navigationController.childViewControllers.count != 1) {
        [self.customNavBar wr_setLeftButtonWithImage:[UIImage imageNamed:@"N_back"]];
    }
}

- (WRCustomNavigationBar *)customNavBar {
    if (_customNavBar == nil) {
        _customNavBar = [WRCustomNavigationBar CustomNavigationBar];
    }
    return _customNavBar;
}

@end
