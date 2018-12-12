//
//  WSYLoginViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYLoginViewController.h"

// Controllers

// Models
#import "WSYTabBarControllerConfig.h"
#import "WSYLoginViewModel.h"
// Views
#import "WSYPlusButtonSubclass.h"
// Vendors

// Categories

// Others

static NSString *const kRemember = @"Remember";

@interface WSYLoginViewController () <UITabBarControllerDelegate, CYLTabBarControllerDelegate>

@property (nonatomic, strong) WSYLoginViewModel *loginModel;

@property (nonatomic, strong) UIImageView *logo;

@property (nonatomic, strong) UITextField *useName;
@property (nonatomic, strong) UITextField *pwd;

@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *checkBtn;

@property (nonatomic, strong) UILabel *companyStr;
@property (nonatomic, strong) UILabel *remeberStr;

@end

@implementation WSYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    [self setUpUI];
    [self bindUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法

- (void)setUpUI {
    [self.view addSubview:self.logo];
    [_logo mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view).offset(60);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo((CGSize){130,120});
    }];
    [_logo wsy_rectWithColor:[UIColor whiteColor]];
    _logo.image = [UIImage imageNamed:@"L_headLogo"];

    [self.view addSubview:self.useName];
    [_useName mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.logo.mas_bottom).offset(60);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.mas_equalTo(36);
    }];
    
    [self.view addSubview:self.pwd];
    [_pwd mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.useName.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.mas_equalTo(36);
    }];
    
    [self.view addSubview:self.checkBtn];
    [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.pwd.mas_bottom).offset(10);
        make.right.equalTo(self.view).offset(-107);
        make.size.mas_equalTo((CGSize){25, 25});
    }];
    
    [self.view addSubview:self.remeberStr];
    [_remeberStr mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.checkBtn);
        make.left.equalTo(self.checkBtn.mas_right).offset(3);
    }];

    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.checkBtn.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.mas_equalTo(36);
    }];
}

- (void)bindUI {
    self.loginModel = [[WSYLoginViewModel alloc]init];
    RAC(self.loginModel, userName) = self.useName.rac_textSignal;
    RAC(self.loginModel, pwd) = self.pwd.rac_textSignal;
    RAC(self.loginBtn, enabled) = [self.loginModel validSignal];
    RAC(self.loginBtn, alpha) = [[self.loginModel validSignal] map:^(NSNumber *b){
        return b.boolValue ? @1: @0.4;
    }];
    
    @weakify(self);
    [self.loginModel.successSubject subscribeNext:^(NSString *str){
        @strongify(self);
        [self hideLoadHUD];
        if ([[WSYUserDataTool getUserData:kRemember] integerValue] != 1) {
            self.pwd.text = @"";
        }
        [self showSuccessHUDWindow:str];
        [self showTabBar];
    }];
    
    [self.loginModel.failureSubject subscribeNext:^(NSString *str){
        @strongify(self);
        [self hideLoadHUD];
        [self showErrorHUDView:str];
    }];
    
    [self.loginModel.errorSubject subscribeNext:^(NSString *str){
        @strongify(self);
        [self hideLoadHUD];
        [self showErrorHUDView:str];
    }];
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self showLoadHUD:@"登录中..."];
        [self.loginModel loginBtn];
    }];
    
    [[self.checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(UIButton *btn){
        btn.selected = !btn.selected;
        if (btn.selected == YES) {
            [WSYUserDataTool setUserData:@1 forKey:kRemember];
        } else {
            [WSYUserDataTool removeUserData:kRemember];
        }
    }];
}

- (void)loadData {
    NSArray *accountAndPassword = [WSYUserDataTool getkAccountAndPassword:USER_ACCOUNT];
    self.useName.text = accountAndPassword? accountAndPassword[0] : @"";
    if ([[WSYUserDataTool getUserData:kRemember] integerValue] == 1) {
        self.checkBtn.selected = YES;
        self.pwd.text = accountAndPassword? accountAndPassword[1] : @"";
    } else {
        self.pwd.text = @"";
    }
}

- (void)showTabBar {
    if ([[WSYUserDataTool getUserData:ROOT_START]integerValue] == 1) {
        [WSYPlusButtonSubclass registerPlusButton];
        WSYTabBarControllerConfig *tabBarControllerConfig = [[WSYTabBarControllerConfig alloc] init];
        CYLTabBarController *tabBarController = tabBarControllerConfig.tabBarController;
        tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:tabBarController animated:NO completion:^{
            [UIApplication sharedApplication].keyWindow.rootViewController = tabBarController;
        }];
        tabBarController.delegate = self;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - TabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [[self cyl_tabBarController] updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control {
    UIView *animationView;
    
    if ([control cyl_isTabButton]) { 
        animationView = [control cyl_tabImageView];
    }
    
    // 即使 PlusButton 也添加了点击事件，点击 PlusButton 后也会触发该代理方法。
    if ([control cyl_isPlusButton]) {
        UIButton *button = CYLExternPlusButton;
        animationView = button.imageView;
    }
    [self addScaleAnimationOnView:animationView repeatCount:1];
}

//缩放动画
- (void)addScaleAnimationOnView:(UIView *)animationView repeatCount:(float)repeatCount {
    //需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.repeatCount = repeatCount;
    animation.calculationMode = kCAAnimationCubic;
    [animationView.layer addAnimation:animation forKey:nil];
}

#pragma mark -
#pragma mark - 懒加载

- (UIImageView *)logo {
    if (!_logo) {
        _logo = [UIImageView new];
    }
    return _logo;
}

- (UITextField *)useName {
    if (!_useName) {
        _useName = [UITextField new];
        _useName.placeholder = @"请输入账号";
        _useName.layer.cornerRadius = 5.0f;
        _useName.layer.borderWidth = 1.0f;
        _useName.layer.borderColor = kThemeColor.CGColor;
        UIImageView *userImage = [[UIImageView alloc]initWithFrame:(CGRect){0, 0, 36, 36}];
        [userImage wsy_rectWithColor:[UIColor whiteColor]];
        userImage.image = [UIImage imageNamed:@"L_userName"];
        _useName.leftView = userImage;
        _useName.leftViewMode = UITextFieldViewModeAlways;
        _useName.clearButtonMode = UITextFieldViewModeWhileEditing;
        _useName.font = WSYFont(14);
    }
    return _useName;
}

- (UITextField *)pwd {
    if (!_pwd) {
        _pwd = [UITextField new];
        _pwd.placeholder = @"请输入密码";
        _pwd.layer.cornerRadius = 5.0f;
        _pwd.layer.borderWidth = 1.0f;
        _pwd.layer.borderColor = kThemeColor.CGColor;
        UIImageView *userImage = [[UIImageView alloc]initWithFrame:(CGRect){0, 0, 36, 36}];
        [userImage wsy_rectWithColor:[UIColor whiteColor]];
        userImage.image = [UIImage imageNamed:@"L_pwd"];
        _pwd.leftView = userImage;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.secureTextEntry = YES;
        _pwd.font = WSYFont(14);
    }
    return _pwd;
}

- (UIButton *)checkBtn {
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:[UIImage imageNamed:@"L_check1"] forState:UIControlStateNormal];
        [_checkBtn setImage:[UIImage imageNamed:@"L_check2"] forState:UIControlStateSelected];
    }
    return _checkBtn;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        _loginBtn.layer.cornerRadius = 5;
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"L_buttonBG"] forState:UIControlStateNormal];
    }
    return _loginBtn;
}

- (UILabel *)remeberStr {
    if (!_remeberStr) {
        _remeberStr = [UILabel new];
        _remeberStr.text = @"记住密码";
        _remeberStr.textColor = kThemeColor;
        _remeberStr.font = WSYFont(13);
    }
    return _remeberStr;
}

@end
