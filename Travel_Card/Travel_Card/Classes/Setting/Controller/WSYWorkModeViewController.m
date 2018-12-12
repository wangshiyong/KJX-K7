//
//  WSYWorkModeViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/28.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYWorkModeViewController.h"
// Controllers

// Models
#import "WSYWorkModel.h"
// Views

// Vendors

// Categories

// Others


typedef NS_ENUM(NSInteger, WSYWorkModeSection) {
    WSYSettingSectionContacts  = 0,
    WSYSettingSectionShutDown  = 1,
    WSYSettingSectionAbout     = 2,
};

static NSString *const kShowTime = @"ShowTime";

@interface WSYWorkModeViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *normalView;
@property (nonatomic, strong) UIView *urgentVeiw;
@property (nonatomic, strong) UIView *customVeiw;
@property (nonatomic, strong) UIView *lineVeiw;

@property (nonatomic, strong) UILabel *normalTitle;
@property (nonatomic, strong) UILabel *normalSubTitle;
@property (nonatomic, strong) UILabel *urgentTitle;
@property (nonatomic, strong) UILabel *urgentSubTitle;
@property (nonatomic, strong) UILabel *customTitle;
@property (nonatomic, strong) UILabel *customSubTitle;

@property (nonatomic, strong) UISwitch *normalSwitch;
@property (nonatomic, strong) UISwitch *urgentSwitch;
@property (nonatomic, strong) UISwitch *customSwitch;

@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) UITextField *time;

@end

@implementation WSYWorkModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"工作模式";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setupUI];
    [self showLoadHUD];
    [self getModeState];
    [self configureSignal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法
/** 获取工作模式 */

- (void)getModeState {
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
    [WSYNetworking getModelWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            WSYWorkData *data = [WSYWorkData mj_objectWithKeyValues:model.data];
            if ([data.workingMode integerValue] == 0) {
                self.urgentSwitch.on = YES;
            } else if ([data.workingMode integerValue] == 1){
                self.normalSwitch.on = YES;
            } else {
                self.customSwitch.on = YES;
                [self customTime];
            }
        } else {
            self.normalSwitch.enabled = NO;
            self.urgentSwitch.enabled = NO;
            self.customSwitch.enabled = NO;
            self.time.enabled = NO;
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            [alert showError:@"模式获取失败" subTitle:@"旅游团无设备，请在游客管理添加设备！" closeButtonTitle:@"知道了" duration:0];
        }
        
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

/** 控件监听 */
-(void)configureSignal {
    @weakify(self);
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]init];
//    [[recognizer rac_gestureSignal]subscribeNext:^(id x){
//        @strongify(self);
//        [self.time resignFirstResponder];
//    }];
//    recognizer.delegate = self;
//    [self.view addGestureRecognizer:recognizer];
    
    [[self.normalSwitch rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(UISwitch *normal){
        @strongify(self);
        if (normal.on == YES) {
            [self showHUDView:@"设置中..."];
            [self normalSetup];
        }
    }];
    
    [[self.urgentSwitch rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(UISwitch *normal){
        if (normal.on == YES) {
            @strongify(self);
            [self showHUDView:@"设置中..."];
            [self urgentSetup];
        }
    }];
    
    [[self.customSwitch rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(UISwitch *normal){
        if (normal.on == YES) {
            @strongify(self);
            [self showHUDView:@"设置中..."];
            [self customSetup];
        }
    }];
    
    [self.time.rac_textSignal subscribeNext:^(id x){
        @strongify(self);
        if([x length] > 2){
            self.time.text = [NSString stringWithFormat:@"%@",[x substringToIndex:2]];
        }
    }];
    
    [[self.saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self showHUDView:@"设置中..."];
        [self saveSetup];
    }];
    
    RACSignal *valid = [RACSignal combineLatest:@[_time.rac_textSignal]
                                         reduce:^(NSString *time){
                                             return @(time.length > 0 );
                                         }];
    RAC(self.saveBtn, enabled) = valid;
    RAC(self.saveBtn, alpha) = [valid map:^(NSNumber *b){
        return b.boolValue ? @1: @0.4;
    }];
}


/** 初始化界面 */
- (void)setupUI {
    @weakify(self);
    [self.view addSubview:self.normalView];
    [self.normalView mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        if (IS_IPHONE_5) {
            make.top.equalTo(self.view).offset(74);
            make.height.mas_equalTo(70);
        } else if (IS_IPHONE_X) {
            make.top.equalTo(self.view).offset(106);
            make.height.mas_equalTo(80);
        } else {
            make.top.equalTo(self.view).offset(84);
            make.height.mas_equalTo(80);
        }
        make.left.right.equalTo(self.view).offset(0);
    }];
    
    [self.normalView addSubview:self.normalTitle];
    [self.normalTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        if (IS_IPHONE_5) {
            make.top.equalTo(self.normalView).offset(10);
        } else {
            make.top.equalTo(self.normalView).offset(15);
        }
        make.width.mas_equalTo(kScreenWidth - 100);
        make.left.equalTo(self.normalView).offset(15);
    }];

    [self.normalView addSubview:self.normalSubTitle];
    [self.normalSubTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.normalView).offset(15);
        make.top.equalTo(self.normalTitle.mas_bottom).offset(8);
        make.right.equalTo(self.normalView.mas_right).offset(-80);
    }];

    [self.normalView addSubview:self.normalSwitch];
    [self.normalSwitch mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerY.equalTo(self.normalView);
        make.right.equalTo(self.normalView).offset(-20);
    }];

    [self.view addSubview:self.urgentVeiw];
    [self.urgentVeiw mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        if (IS_IPHONE_5) {
            make.top.equalTo(self.normalView.mas_bottom).offset(10);
        } else {
            make.top.equalTo(self.normalView.mas_bottom).offset(20);
        }
        make.left.right.equalTo(self.view).offset(0);
        make.height.mas_equalTo(80);
    }];

    [self.urgentVeiw addSubview:self.urgentTitle];
    [self.urgentTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.urgentVeiw).offset(15);
        make.top.equalTo(self.urgentVeiw).offset(15);
        make.width.mas_equalTo(kScreenWidth - 100);
    }];

    [self.urgentVeiw addSubview:self.urgentSubTitle];
    [self.urgentSubTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.urgentVeiw).offset(15);
        make.top.equalTo(self.urgentTitle.mas_bottom).offset(8);
        make.right.equalTo(self.urgentVeiw.mas_right).offset(-80);
    }];

    [self.urgentVeiw addSubview:self.urgentSwitch];
    [self.urgentSwitch mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerY.equalTo(self.urgentVeiw);
        make.right.equalTo(self.urgentVeiw).offset(-20);
    }];

    [self.view addSubview:self.customVeiw];
    [self.customVeiw mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        if (IS_IPHONE_5) {
            make.top.equalTo(self.urgentVeiw.mas_bottom).offset(10);
            make.height.mas_equalTo(120);
        } else {
            make.top.equalTo(self.urgentVeiw.mas_bottom).offset(20);
            make.height.mas_equalTo(110);
        }
        make.left.right.equalTo(self.view).offset(0);
    }];

    [self.customVeiw addSubview:self.customTitle];
    [self.customTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.customVeiw).offset(15);
        make.top.equalTo(self.customVeiw).offset(15);
        make.width.mas_equalTo(kScreenWidth - 100);
    }];

    [self.customVeiw addSubview:self.customSwitch];
    [self.customSwitch mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerY.equalTo(self.customVeiw);
        make.right.equalTo(self.customVeiw).offset(-20);
    }];

    [self.customVeiw addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerX.equalTo(self.customVeiw);
        make.bottom.equalTo(self.customVeiw.mas_bottom).offset(-2);
    }];

    [self.customVeiw addSubview:self.time];
    [self.time mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.customVeiw).offset(15);
        make.top.equalTo(self.customTitle.mas_bottom).offset(6);
        make.width.mas_equalTo(50);
    }];

    [self.customVeiw addSubview:self.customSubTitle];
    [self.customSubTitle mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.time.mas_right).offset(2);
        make.centerY.equalTo(self.time);
        make.right.equalTo(self.urgentVeiw.mas_right).offset(-80);
    }];
}


#pragma mark -
#pragma mark - 事件响应

- (void)normalSetup {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    alert.customViewColor = [UIColor redColor];
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Value":@1,@"WorkModeName":@"work"};
    [WSYNetworking setModelWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            self.customSwitch.on = NO;
            self.urgentSwitch.on = NO;
            self.time.text = @"";
            [self.time resignFirstResponder];
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
            [alert showSuccess:@"设置成功" subTitle:@"正常模式已开启" closeButtonTitle:nil duration:1.0f];
        } else {
            [alert showError:@"设置失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
            self.normalSwitch.on = NO;
        }
        
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

- (void)urgentSetup {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    alert.customViewColor = [UIColor redColor];
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Value":@0,@"WorkModeName":@"work"};
    [WSYNetworking setModelWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            self.customSwitch.on = NO;
            self.normalSwitch.on = NO;
            self.time.text = @"";
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
            [self.time resignFirstResponder];
            [alert showSuccess:@"设置成功" subTitle:@"正常模式已开启" closeButtonTitle:nil duration:1.0f];
        } else {
            [alert showError:@"设置失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
            self.urgentSwitch.on = NO;
        }
        
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

- (void)customSetup {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    alert.customViewColor = [UIColor redColor];
    alert.shouldDismissOnTapOutside = YES;
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"LocationInterval":@"180"};
    [WSYNetworking setModelTimeWithParameters:parameters success:^(id response){
        @strongify(self);
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            self.time.text = @"3";
            self.saveBtn.enabled = YES;
            self.saveBtn.alpha = 1.0;
            [alert showSuccess:@"模式已开启" subTitle:@"请设置自定义时间!" closeButtonTitle:nil duration:1.0f];
        } else {
            [alert showError:@"设置失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
        }
        
    } failure:^(NSError *error){

    }];
    
    NSDictionary *parameterss = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Value":@2,@"WorkModeName":@"work"};
    [WSYNetworking setModelWithParameters:parameterss success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            self.urgentSwitch.on = NO;
            self.normalSwitch.on = NO;
            [self.time resignFirstResponder];
        } else {
            [alert showError:@"设置失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
            self.customSwitch.on = NO;
        }
        
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

- (void)customTime {
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
    [WSYNetworking getModelTimeWithParameters:parameters success:^(id response){
        @strongify(self);
        WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            NSString *str = [NSString stringWithFormat:@"%@", response[@"Data"]];
            NSInteger num = [str integerValue]/60;
            self.time.text = [NSString stringWithFormat:@"%ld",(long)num];
            [self.time.rac_textSignal subscribeNext:^(NSString *str){
                @strongify(self);
                if (str.length == 0 || [str isEqualToString:@"0"]) {
                    self.time.text = @"";
                    self.saveBtn.enabled = NO;
                }else{
                    self.saveBtn.enabled = YES;
                    self.saveBtn.alpha = 1.0;
                }
            }];
        } else {
            [self showErrorHUD:@"获取自定义时间失败"];
        }
        
    } failure:^(NSError *error){
        
    }];
}

-(void)saveSetup {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    alert.customViewColor = [UIColor redColor];
    alert.shouldDismissOnTapOutside = YES;
    [self.time resignFirstResponder];
    if (self.customSwitch.on == NO) {
        [self hideLoadHUD];
        [alert showError:nil subTitle:@"非自定义模式,不能保存" closeButtonTitle:nil duration:1.0f];
    }else if ([_time.text integerValue] < 3) {
        [self hideLoadHUD];
        [alert showError:nil subTitle:@"自定义时间不能少于3分钟" closeButtonTitle:nil duration:1.0f];
    }else{
//        NSString *tsnStr = [WSYUserDataTool getUserData:kGuideID];
        NSInteger num = [_time.text integerValue]*60;
        NSString *str = [NSString stringWithFormat:@"%ld",(long)num];
        NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"LocationInterval":str};
        @weakify(self);
        [WSYNetworking setModelTimeWithParameters:parameters success:^(id response){
            @strongify(self);
            [self hideLoadHUD];
            WSYWorkModel *model = [WSYWorkModel mj_objectWithKeyValues:response];
            if ([model.code integerValue] == 0) {
                alert.shouldDismissOnTapOutside = YES;
                [alert showSuccess:nil subTitle:@"自定义模式设置成功!" closeButtonTitle:nil duration:1.0f];
            } else {
                [alert showError:@"设置失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
            }
            
        } failure:^(NSError *error){
            @strongify(self);
            [self hideLoadHUD];
        }];
    }
}

#pragma mark -
#pragma mark - 懒加载

- (UIView *)normalView {
    if (!_normalView) {
        _normalView = ({
            UIView *normalView = [[UIView alloc]init];
            normalView.backgroundColor = [UIColor whiteColor];
            normalView;
        });
    }
    return _normalView;
}

- (UIView *)urgentVeiw {
    if (!_urgentVeiw) {
        _urgentVeiw = ({
            UIView *urgentVeiw = [[UIView alloc]init];
            urgentVeiw.backgroundColor = [UIColor whiteColor];
            urgentVeiw;
        });
    }
    return _urgentVeiw;
}

- (UIView *)customVeiw {
    if (!_customVeiw) {
        _customVeiw = ({
            UIView *customVeiw = [[UIView alloc]init];
            customVeiw.backgroundColor = [UIColor whiteColor];
            customVeiw;
        });
    }
    return _customVeiw;
}

- (UIView *)lineVeiw {
    if (!_lineVeiw) {
        _lineVeiw = ({
            UIView *lineVeiw = [[UIView alloc]init];
            lineVeiw.backgroundColor = [UIColor lightGrayColor];
            lineVeiw;
        });
    }
    return _lineVeiw;
}

- (UILabel *)normalTitle {
    if (!_normalTitle) {
        _normalTitle = ({
            UILabel *normalTitle = [[UILabel alloc]init];
            normalTitle.text = @"正常模式";
            normalTitle;
        });
    }
    return _normalTitle;
}

- (UILabel *)normalSubTitle {
    if (!_normalSubTitle) {
        _normalSubTitle = ({
            UILabel *normalSubTitle = [[UILabel alloc]init];
            normalSubTitle.textColor = [UIColor lightGrayColor];
            normalSubTitle.font = [UIFont systemFontOfSize:15];
            normalSubTitle.text = @"每30分钟发送一次定位信息";
            normalSubTitle.numberOfLines = 0;
            normalSubTitle;
        });
    }
    return _normalSubTitle;
}

- (UILabel *)urgentTitle {
    if (!_urgentTitle) {
        _urgentTitle = ({
            UILabel *urgentTitle = [[UILabel alloc]init];
            urgentTitle.text = @"紧急模式";
            urgentTitle;
        });
    }
    return _urgentTitle;
}

- (UILabel *)urgentSubTitle {
    if (!_urgentSubTitle) {
        _urgentSubTitle = ({
            UILabel *urgentSubTitle = [[UILabel alloc]init];
            urgentSubTitle.textColor = [UIColor lightGrayColor];
            urgentSubTitle.font = [UIFont systemFontOfSize:15];
            urgentSubTitle.text = @"每10秒钟发送一次定位信息";
            urgentSubTitle.numberOfLines = 0;
            urgentSubTitle;
        });
    }
    return _urgentSubTitle;
}

- (UILabel *)customTitle {
    if (!_customTitle) {
        _customTitle = ({
            UILabel *customTitle = [[UILabel alloc]init];
            customTitle.text = @"自定义模式";
            customTitle;
        });
    }
    return _customTitle;
}

- (UILabel *)customSubTitle {
    if (!_customSubTitle) {
        _customSubTitle = ({
            UILabel *customSubTitle = [[UILabel alloc]init];
            customSubTitle.textColor = [UIColor lightGrayColor];
            customSubTitle.font = [UIFont systemFontOfSize:15];
            customSubTitle.text = @"分钟(数字越小，设备耗电越大)";
            customSubTitle.numberOfLines = 0;
            customSubTitle;
        });
    }
    return _customSubTitle;
}

- (UISwitch *)normalSwitch {
    if (!_normalSwitch) {
        _normalSwitch = ({
            UISwitch *normalSwitch = [[UISwitch alloc]init];
            normalSwitch.onTintColor = kThemeColor;
            normalSwitch;
        });
    }
    return _normalSwitch;
}

- (UISwitch *)urgentSwitch {
    if (!_urgentSwitch) {
        _urgentSwitch = ({
            UISwitch *urgentSwitch = [[UISwitch alloc]init];
            urgentSwitch.onTintColor = kThemeColor;
            urgentSwitch;
        });
    }
    return _urgentSwitch;
}

- (UISwitch *)customSwitch {
    if (!_customSwitch) {
        _customSwitch = ({
            UISwitch *customSwitch = [[UISwitch alloc]init];
            customSwitch.onTintColor = kThemeColor;
            customSwitch;
        });
    }
    return _customSwitch;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
            [saveBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
            saveBtn;
        });
    }
    return _saveBtn;
}

- (UITextField *)time {
    if (!_time) {
        _time = ({
            UITextField *time = [[UITextField alloc]init];
            time.font = [UIFont systemFontOfSize:15];
            time.placeholder = @">=3";
            time.borderStyle = UITextBorderStyleRoundedRect;
            time.textAlignment = NSTextAlignmentCenter;
            time.keyboardType = UIKeyboardTypeNumberPad;
            time;
        });
    }
    return _time;
}

@end
