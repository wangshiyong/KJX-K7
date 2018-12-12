//
//  WSYModifyPasswordViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/28.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYModifyPasswordViewController.h"
#import "WSYLoginViewController.h"
#import <MaterialControls/MaterialControls.h>
#import "JPUSHService.h"

@interface WSYModifyPasswordViewController () <MDTextFieldDelegate>

@property (nonatomic, strong) MDTextField *oldPwd;
@property (nonatomic, strong) MDTextField *pwd;
@property (nonatomic, strong) MDTextField *repeatPwd;

@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, copy) NSString *password;

@end

@implementation WSYModifyPasswordViewController

static NSInteger seq = 0;

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _oldPwd = nil;
    _pwd = nil;
    _repeatPwd = nil;
    _repeatPwd.delegate = nil;
    _pwd.delegate = nil;
    _oldPwd.delegate = nil;
    [_oldPwd removeFromSuperview];
    [_pwd removeFromSuperview];
    [_repeatPwd removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"修改密码";
    self.view.backgroundColor = [UIColor whiteColor];

    self.saveBtn.enabled    = NO;
    self.saveBtn.alpha      = 0.4;

    [self.view addSubview:self.oldPwd];
    [self.view addSubview:self.pwd];
    [self.view addSubview:self.repeatPwd];
    [self.view addSubview:self.saveBtn];
    @weakify(self);
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.repeatPwd.mas_top).offset(120);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    [self.oldPwd becomeFirstResponder];
    self.password = [WSYUserDataTool getkAccountAndPassword:USER_ACCOUNT][1];
    
    [[self.saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self);
        if ([self.password isEqualToString:self.pwd.text]) {
            [self showErrorHUDView:@"新旧密码不能相同"];
            return ;
        }
        [self showLoadHUD:@"更新中..."];
        
        NSDictionary *parameters = @{@"TravelAgencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Account":[WSYUserDataTool getkAccountAndPassword:USER_ACCOUNT][0],@"Password":self.pwd.text};
        [WSYNetworking updatePwdWithParameters:parameters success:^(id response){
            @strongify(self);
            [self hideLoadHUD];
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            alert.customViewColor = [UIColor redColor];
            NSString *codeStr = [NSString stringWithFormat:@"%@",response[@"Code"]];
            if ([codeStr isEqualToString:@"0"]) {
                [alert addButton:@"确定" actionBlock:^(void) {
                    @strongify(self);
                    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        NSLog(@"%ld====%@=====%ld",(long)iResCode,iAlias,(long)seq);
                    } seq:[self seq]];
                    if ([[WSYUserDataTool getUserData:ROOT_START]integerValue] == 1) {
                        [WSYUserDataTool removeUserData:USER_LOGIN];
                        [self dismissViewControllerAnimated:YES completion:^{
                            [UIApplication sharedApplication].keyWindow.rootViewController = [WSYLoginViewController new];
                        }];
                    } else {
                        self.tabBarController.selectedIndex = 0;
                        [WSYNetworking cancelRequestWithURL:[NSString stringWithFormat:@"%@%@",kApiPrefix,kTeamLocation]];
                        [WSYUserDataTool removeUserData:USER_LOGIN];
                        WSYLoginViewController *vc = [WSYLoginViewController new];
                        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [self presentViewController:vc animated:YES completion:nil];
                    }
                }];
                [alert showSuccess:@"安全提示" subTitle:@"密码更新成功，请重新登录！" closeButtonTitle:nil duration:0.0f];
            }else{
                [alert showError:@"更新失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
            }
        } failure:^(NSError *error){
            @strongify(self);
            [self hideLoadHUD];
        }];
        
        NSDictionary *parameterss = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID]};
        [WSYNetworking logoutWithParameters:parameterss success:^(id response){
            
        } failure:^(NSError *error){

        }];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)seq {
    return ++ seq;
}

#pragma mark ============懒加载============

- (MDTextField *)oldPwd{
    if (!_oldPwd) {
        _oldPwd = ({
            MDTextField *oldPwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 80, kScreenWidth - 40, 80};
                frame;
            })];
            oldPwd.label = @"请输入当前密码";
            oldPwd.floatingLabel = YES;
            oldPwd.highlightLabel = YES;
            oldPwd.maxCharacterCount = 10;
            oldPwd.singleLine = YES;
            oldPwd.secureTextEntry = YES;
            oldPwd.highlightColor = kThemeColor;
            oldPwd.errorColor = [UIColor redColor];
            oldPwd.delegate = self;
            oldPwd;
        });
    }
    return _oldPwd;
}

- (MDTextField *)pwd{
    if (!_pwd) {
        _pwd = ({
            MDTextField *pwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 160, kScreenWidth - 40, 80};
                frame;
            })];
            pwd.label = @"请输入新密码";
            pwd.floatingLabel = YES;
            pwd.highlightLabel = YES;
            pwd.maxCharacterCount = 10;
            pwd.singleLine = YES;
            pwd.secureTextEntry = YES;
            pwd.highlightColor = kThemeColor;
            pwd.errorColor = [UIColor redColor];
            pwd.delegate = self;
            pwd;
        });
    }
    return _pwd;
}

- (MDTextField *)repeatPwd{
    if (!_repeatPwd) {
        _repeatPwd = ({
            MDTextField *repeatPwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 245, kScreenWidth - 40, 80};
                frame;
            })];
            repeatPwd.label = @"请确认新密码";
            repeatPwd.floatingLabel = YES;
            repeatPwd.highlightLabel = YES;
            repeatPwd.maxCharacterCount = 10;
            repeatPwd.singleLine = YES;
            repeatPwd.secureTextEntry = YES;
            repeatPwd.highlightColor = kThemeColor;
            repeatPwd.errorColor = [UIColor redColor];
            repeatPwd.delegate = self;
            repeatPwd;
        });
    }
    return _repeatPwd;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton *saveBtn = [[UIButton alloc]init];
            [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
            saveBtn.layer.cornerRadius = 5.0;
            saveBtn.backgroundColor = kThemeColor;
            saveBtn;
        });
    }
    return _saveBtn;
}

#pragma mark -
#pragma mark - MDTextFieldDelegate

- (void)textFieldDidChange:(MDTextField *)textField {
    if (textField.text.length < 6 && textField.text.length > 0) {
        textField.hasError = YES;
        textField.errorMessage = @"密码最少6位";
    } else if (textField.text.length > textField.maxCharacterCount){
        textField.text = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:10]];
        textField.hasError = YES;
        textField.errorMessage = @"密码最大长度为10位";
    } else {
        textField.hasError = NO;
    }
    
    if (self.oldPwd.text.length > 5 && self.pwd.text.length > 5 && self.repeatPwd.text.length > 5) {
        if (self.repeatPwd.text != self.pwd.text) {
            self.repeatPwd.hasError = YES;
            self.repeatPwd.errorMessage = @"密码不一致";
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
        } else if (![self.password isEqualToString:self.oldPwd.text]) {
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
        } else {
            self.repeatPwd.hasError = NO;
            self.saveBtn.enabled = YES;
            self.saveBtn.alpha = 1.0;
        }
    } else {
        self.saveBtn.enabled = NO;
        self.saveBtn.alpha = 0.4;
    }
}

- (BOOL)textFieldShouldReturn:(MDTextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(MDTextField *)textField {
    if (textField == self.pwd || textField == self.repeatPwd) {
        if (![self.password isEqualToString:self.oldPwd.text] ) {
            self.oldPwd.hasError = YES;
            self.oldPwd.errorMessage = @"密码有误";
        }
    } else {
        self.oldPwd.hasError = NO;
    }
}

@end
