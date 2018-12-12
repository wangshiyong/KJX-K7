//
//  WSYScanViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/6.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYScanViewController.h"
#import <SGQRCode/SGQRCode.h>
#import "UIButton+WSYLayout.h"
#import "UIImage+WSYColor.h"
#import "WRNavigationBar.h"

@interface WSYScanViewController (){
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) AVSpeechUtterance *utterance;
@property (nonatomic, strong) UILabel *promptLabel;
/** 手电筒 */
@property (nonatomic, strong) UIButton *flashlightBtn;
/** 手动输入按钮 */
@property (nonatomic, strong) UIButton *inputBtn;
/** 是否扫描 */
@property (nonatomic, assign) BOOL isfrishScan;

@end

@implementation WSYScanViewController

#pragma mark -
#pragma mark - 生命周期

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.scanView removeTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanView removeTimer];
    [obtain closeFlashlight];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"WBQRCodeVC - dealloc");
    [self removeScanningView];
}

- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

#pragma mark -
#pragma mark - 私有方法

- (void)setUpUI {
    self.isfrishScan = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self.customNavBar wr_setBackgroundAlpha:0];
    
    obtain = [SGQRCodeObtain QRCodeObtain];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupQRCodeScan];
        [self.view addSubview:self.scanView];
        [self.view bringSubviewToFront:self.customNavBar];
        self.customNavBar.title = @"扫一扫";
        self.customNavBar.titleLabelColor = [UIColor whiteColor];
        [self.customNavBar wr_setLeftButtonWithImage:[[UIImage imageNamed:@"N_back"] imageWithTintColor:[UIColor whiteColor]]];
        [self.view addSubview:self.flashlightBtn];
        [self.view addSubview:self.inputBtn];
        [self.view addSubview:self.promptLabel];
        [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
    });
}

- (void)setupQRCodeScan {
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
//    configure.openLog = YES;
    configure.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 这里只是提供了几种作为参考（共：13）；需什么类型添加什么类型即可
    NSArray *arr = @[AVMetadataObjectTypeQRCode];
    configure.metadataObjectTypes = arr;
    @weakify(self);
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain startRunningWithBefore:^{
        @strongify(self);
        [self showLoadHUD:@"正在加载..."];
    } completion:^{
        @strongify(self);
        [self hideLoadHUD];
    }];
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            @strongify(self);
            if (self.isfrishScan == YES) {
                self.isfrishScan = NO;
                if (result.length > 49) {
                    result = [result substringFromIndex:49];
                }
                NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"sex":@"男",@"CodeCodeMachine":result};
                
                [WSYNetworking addTouristWithParameters:parameters success:^(id response){
                    @strongify(self);
                    if ([response[@"Code"] integerValue] == 0) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:SCAN_SUCESSS_NOTICE object:nil];
                        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@添加成功",result]];
                        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                        
                    } else {
                        if ([response[@"Message"] hasPrefix:@"设备未"]) {
                            [self showErrorHUDView:[NSString stringWithFormat:@"%@未加入该旅行社",result]];
                            self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@未加入该旅行社",result]];
                            self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                        } else if ([response[@"Message"] hasPrefix:@"该设备"]) {
                            [self showErrorHUDView:[NSString stringWithFormat:@"%@已经绑定",result]];
                            self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@已经绑定",result]];
                            self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                        } else {
                            [self showErrorHUDView:[NSString stringWithFormat:@"%@已超出上限人数",result]];
                            self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@已超出上限人数",result]];
                            self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                        }
                    }
                    [av speakUtterance:self.utterance];
                } failure:^(NSError *error){
                    @strongify(self);
                    self.isfrishScan = YES;
                }];
                
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isfrishScan = YES;
            });
                
            }
        }
    }];
}

#pragma mark -
#pragma mark - 事件响应

- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) {
        [obtain openFlashlight];
        button.selected = YES;
    } else {
        [obtain closeFlashlight];
        button.selected = NO;
    }
}

- (void)input_buttonAction:(UIButton *)button {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
    [alert setHorizontalButtons:YES];
    SCLTextView *textField = [alert addTextField:@"请输入机器码"];
    @weakify(self);
    [alert addButton:@"确定" actionBlock:^(void) {
        NSString *str = textField.text;
        if (str.length == 7) {
            NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"sex":@"男",@"CodeCodeMachine":str};
            [WSYNetworking addTouristWithParameters:parameters success:^(id response){
                @strongify(self);
                if ([response[@"Code"] integerValue] == 0) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:SCAN_SUCESSS_NOTICE object:nil];
                    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@添加成功",str]];
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    [self showSuccessHUDView:[NSString stringWithFormat:@"%@添加成功",str]];
                } else {
                    if ([response[@"Message"] hasPrefix:@"设备未"]) {
                        [self showErrorHUDView:[NSString stringWithFormat:@"%@未加入该旅行社",str]];
                        self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@未加入该旅行社",str]];
                        self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    } else if ([response[@"Message"] hasPrefix:@"该设备"]) {
                        [self showErrorHUDView:[NSString stringWithFormat:@"%@已经绑定",str]];
                        self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@已经绑定",str]];
                        self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    } else {
                        [self showErrorHUDView:[NSString stringWithFormat:@"%@已超出上限人数",str]];
                        self.utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@已超出上限人数",str]];
                        self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    }
                }
                [av speakUtterance:self.utterance];
            } failure:^(NSError *error){

            }];
        } else {
            [self showErrorHUDView:@"请输入正确的机器码"];
        }
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"M_input2"] color:kThemeColor title:@"设备添加" subTitle:@"确定添加设备?" closeButtonTitle:@"取消" duration:0.0f];
}

#pragma mark -
#pragma mark - 懒加载

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        // 静态库加载 bundle 里面的资源使用 SGQRCode.bundle/QRCodeScanLineGrid
        // 动态库加载直接使用 QRCodeScanLineGrid
        _scanView.scanImageName = @"QRCodeScanLineGrid";
        _scanView.scanAnimationStyle = ScanAnimationStyleGrid;
        _scanView.cornerLocation = CornerLoactionOutside;
        _scanView.cornerColor = [UIColor orangeColor];
    }
    return _scanView;
}

- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        _flashlightBtn = ({
            UIButton *flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            flashlightBtn.frame = (CGRect){kScreenWidth - 160, kScreenHeight - 100, 120, 80};
            [flashlightBtn setImage:[UIImage imageNamed:@"M_open"] forState:UIControlStateNormal];
            [flashlightBtn setImage:[UIImage imageNamed:@"M_off"] forState:UIControlStateSelected];
            [flashlightBtn addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [flashlightBtn setTitle:@"打开手电筒" forState:UIControlStateNormal];
            [flashlightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            flashlightBtn.titleLabel.font = WSYFont(14);
            flashlightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            flashlightBtn.titleRect = (CGRect){0,50,120,30};
            flashlightBtn.imageRect = (CGRect){40,0,40,40};
            flashlightBtn;
        });
    }
    return _flashlightBtn;
}

- (UIButton *)inputBtn {
    if (!_inputBtn) {
        _inputBtn = ({
            UIButton *inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            inputBtn.frame = (CGRect){40, kScreenHeight - 100, 120, 80};
            [inputBtn setImage:[UIImage imageNamed:@"M_input"] forState:UIControlStateNormal];
            [inputBtn addTarget:self action:@selector(input_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [inputBtn setTitle:@"手动输入设备号" forState:UIControlStateNormal];
            [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            inputBtn.titleLabel.font = WSYFont(14);
            inputBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            inputBtn.titleRect = (CGRect){0,50,120,30};
            inputBtn.imageRect = (CGRect){40,0,40,40};
            inputBtn;
        });
    }
    return _inputBtn;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = ({
            UILabel *promptLabel = [[UILabel alloc]initWithFrame:({
                CGRect frame = (CGRect){0, 0.2 * kScreenHeight + 20, kScreenWidth, 25};
                frame;
            })];
            promptLabel.textAlignment = NSTextAlignmentCenter;
            promptLabel.font = [UIFont boldSystemFontOfSize:15.0];
            promptLabel.textColor = [UIColor whiteColor];
            promptLabel.text = @"将码放入框内，即可自动扫描";
            promptLabel;
        });
    }
    return _promptLabel;
}

@end
