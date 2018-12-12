//
//  WSYReleaseViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYReleaseViewController.h"
// Controllers

// Models
#import "WSYItineraryModel.h"
// Views

// Vendors
#import <IQKeyboardManager/IQKeyboardManager.h>
// Categories
#import "UITextView+Placeholder.h"
// Others


@interface WSYReleaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextView  *textView;
@property (nonatomic, strong) UILabel     *hintLab;
@property (nonatomic, strong) UILabel     *numLab;
@property (nonatomic, strong) UIButton    *releaseBtn;

@end

@implementation WSYReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"行程发布";
    [self.customNavBar wr_setLeftButtonWithTitle:@"取消" titleColor:[UIColor blackColor]];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self setupUI];
    [self controlMonitor];

//    @weakify(self);
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]init];
//    [[recognizer rac_gestureSignal]subscribeNext:^(id x){
//        @strongify(self);
//        [self.textView resignFirstResponder];
//    }];
//    recognizer.delegate = self;
//    [self.view addGestureRecognizer:recognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupUI {
    @weakify(self);
    [self.view addSubview:self.textView];
    if (IS_IPHONE_5) {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(84);
            make.height.mas_equalTo(120);
        }];
    } else if (IS_IPHONE_X){
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(114);
            make.height.mas_equalTo(180);
        }];
    } else {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(84);
            make.height.mas_equalTo(180);
        }];
    }

    
    [self.view addSubview:self.hintLab];
    [self.hintLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 100);
    }];
    
    [self.view addSubview:self.numLab];
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.releaseBtn];
    [self.releaseBtn mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.numLab.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    
    [self.textView becomeFirstResponder];
}

//监听
- (void)controlMonitor {
    @weakify(self);
    [self.textView.rac_textSignal subscribeNext:^(NSString *str){
        @strongify(self);
        str = [self disable_emoji:str];
        if (str.length > 0) {
            self.releaseBtn.enabled = YES;
            self.releaseBtn.alpha = 1.0;
        } else {
            self.releaseBtn.enabled = NO;
            self.releaseBtn.alpha = 0.4;
        }
        if (str.length >= 50) {
            self.textView.text = [NSString stringWithFormat:@"%@",[str substringToIndex:50]];
            self.numLab.textColor = [UIColor redColor];
            self.hintLab.text = @"提示:最多输入50位";
            self.numLab.text = @"50/50";
        } else {
            self.hintLab.text = @"";
            self.numLab.textColor = [UIColor grayColor];
            self.numLab.text = [NSString stringWithFormat:@"%lu/50",(unsigned long)str.length];
        }
        
    }];

    [[self.releaseBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self showLoadHUD:@"发布中..."];
        if (self.isMemberRelease == YES) {
            NSDictionary *parameters = @{@"MemberID":self.memberID,@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Subject": self.deviceID,@"Content":self.textView.text};
            [WSYNetworking releaseOneWithParameters:parameters success:^(id response){
                @strongify(self);
                [self hideLoadHUD];
                WSYItineraryModel *model = [WSYItineraryModel mj_objectWithKeyValues:response];
                if ([model.code integerValue] == 0) {
                    [self showSuccessHUDWindow:@"发布成功"];
                    [[NSNotificationCenter defaultCenter]postNotificationName:RELEASE_SUCESSS_NOTICE object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self showErrorHUDView:@"设备无定位,发布失败"];
                }
            } failure:^(NSError *error){
                @strongify(self);
                [self hideLoadHUD];
            }];
        } else {
            NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"Subject": @"团行程",@"Content":self.textView.text};
            [WSYNetworking releaseItineraryWithParameters:parameters success:^(id response){
                @strongify(self);
                [self hideLoadHUD];
                WSYItineraryModel *model = [WSYItineraryModel mj_objectWithKeyValues:response];
                if ([model.code integerValue] == 0) {
                    [self showSuccessHUDWindow:@"发布成功"];
                    [[NSNotificationCenter defaultCenter]postNotificationName:RELEASE_SUCESSS_NOTICE object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self showErrorHUDView:@"发布失败"];
                }
            } failure:^(NSError *error){
                @strongify(self);
                [self hideLoadHUD];
            }];
        }
    }];
}

#pragma mark - 正则判断

//- (BOOL)matchStringFormat:(NSString *)matchedStr withRegex:(NSString *)regex {
//    //SELF MATCHES一定是大写   ^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$ 中文英文数字空格
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
//    return [predicate evaluateWithObject:matchedStr];
//}

- (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

#pragma mark -
#pragma mark - 懒加载

- (UITextView *)textView{
    if (!_textView) {
        _textView = ({
            UITextView *textView = [[UITextView alloc]init];
            textView.backgroundColor = [UIColor whiteColor];
            textView.layer.cornerRadius = 10.0;
            textView.font = [UIFont systemFontOfSize:17.0f];
            textView.placeholder = @"请输入行程内容";
            textView;
        });
    }
    return _textView;
}

- (UILabel *)hintLab{
    if (!_hintLab) {
        _hintLab = ({
            UILabel *hintLab = [[UILabel alloc]init];
            hintLab.textColor = [UIColor redColor];
            hintLab.font = [UIFont systemFontOfSize:IS_IPHONE_5 ? 12.0f : 15.0f];
            hintLab;
        });
    }
    return _hintLab;
}

- (UILabel *)numLab{
    if (!_numLab) {
        _numLab = ({
            UILabel *numLab = [[UILabel alloc]init];
            numLab.textColor = [UIColor lightGrayColor];
            numLab.textAlignment = NSTextAlignmentRight;
            numLab.font = [UIFont systemFontOfSize:15.0f];
            numLab.text = @"0/50";
            numLab;
        });
    }
    return _numLab;
}

- (UIButton *)releaseBtn{
    if (!_releaseBtn) {
        _releaseBtn = ({
            UIButton *releaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [releaseBtn setTitle:@"发 布" forState:UIControlStateNormal];
            [releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            releaseBtn.titleLabel.font = WSYFont(19);
            releaseBtn.layer.cornerRadius = 5.0;
            releaseBtn.backgroundColor = kThemeColor;
            releaseBtn;
        });
    }
    return _releaseBtn;
}

@end
