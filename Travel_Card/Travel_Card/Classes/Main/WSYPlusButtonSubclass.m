//
//  WSYPlusButtonSubclass.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYPlusButtonSubclass.h"
#import "WSYReleaseViewController.h"
#import "WSYScanViewController.h"
#import "HyPopMenuView.h"
#import "WSYPopMenuTopView.h"
#import "WSYPrivacyPermission.h"

@interface WSYPlusButtonSubclass ()<UIActionSheetDelegate, HyPopMenuViewDelegate> {
    CGFloat _buttonImageHeight;
}

/* 弹出菜单 */
@property (nonatomic, strong) HyPopMenuView* menu;

@end

@implementation WSYPlusButtonSubclass

#pragma mark -
#pragma mark - Life Cycle

+ (void)load {
    //请在 `-[AppDelegate application:didFinishLaunchingWithOptions:]` 中进行注册，否则iOS10系统下存在Crash风险。
    //[super registerPlusButton];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

//上下结构的 button
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 控件大小,间距大小
    // 注意：一定要根据项目中的图片去调整下面的0.7和0.9，Demo之所以这么设置，因为demo中的 plusButton 的 icon 不是正方形。
    CGFloat const imageViewEdgeWidth   = self.bounds.size.width * 0.7;
    CGFloat const imageViewEdgeHeight  = imageViewEdgeWidth * 0.9;
    
    CGFloat const centerOfView    = self.bounds.size.width * 0.5;
    CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
    CGFloat const verticalMargin  = (self.bounds.size.height - labelLineHeight - imageViewEdgeHeight) * 0.5;
    
    // imageView 和 titleLabel 中心的 Y 值
    CGFloat const centerOfImageView  = verticalMargin + imageViewEdgeHeight * 0.5;
    CGFloat const centerOfTitleLabel = imageViewEdgeHeight  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
    
    //imageView position 位置
    self.imageView.bounds = CGRectMake(0, 0, imageViewEdgeWidth, imageViewEdgeHeight);
    self.imageView.center = CGPointMake(centerOfView, centerOfImageView);
    
    //title position 位置
    self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
    self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
}

#pragma mark -
#pragma mark - CYLPlusButtonSubclassing Methods

/*
 *
 Create a custom UIButton with title and add it to the center of our tab bar
 *
 */
+ (id)plusButton {
    WSYPlusButtonSubclass *button = [[WSYPlusButtonSubclass alloc] init];
    UIImage *buttonImage = [UIImage imageNamed:@"T_post_normal"];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"发布" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setTitle:@"发布" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    button.titleLabel.font = [UIFont systemFontOfSize:9.5];
    [button sizeToFit]; // or set frame in this way `button.frame = CGRectMake(0.0, 0.0, 250, 100);`
    //    button.frame = CGRectMake(0.0, 0.0, 250, 100);
    //    button.backgroundColor = [UIColor redColor];
    
    // if you use `+plusChildViewController` , do not addTarget to plusButton.
    [button addTarget:button action:@selector(setUpPopMenu) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
//+ (id)plusButton
//{
//
//    UIImage *buttonImage = [UIImage imageNamed:@"hood.png"];
//    UIImage *highlightImage = [UIImage imageNamed:@"hood-selected.png"];
//
//    CYLPlusButtonSubclass* button = [CYLPlusButtonSubclass buttonWithType:UIButtonTypeCustom];
//
//    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
//    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
//
//    return button;
//}

#pragma mark -
#pragma mark - Event Response

//- (void)clickPublish {
//    CYLTabBarController *tabBarController = [self cyl_tabBarController];
//    UIViewController *viewController = tabBarController.selectedViewController;
//
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"拍照", @"从相册选取", @"淘宝一键转卖", nil];
//    [actionSheet showInView:viewController.view];
//}

- (void)setUpPopMenu {
//    CYLTabBarController *tabBarController = [self cyl_tabBarController];
//    UIViewController *viewController = tabBarController.selectedViewController;
//    WSYScanViewController *vc = [WSYScanViewController new];
//    [viewController presentViewController:vc animated:YES completion:nil];
    
    _menu = [HyPopMenuView sharedPopMenuManager];
    PopMenuModel* model = [PopMenuModel
                           allocPopMenuModelWithImageNameString:@"I_release1"
                           AtTitleString:@"扫描添加"
                           AtTextColor:WSYColor(81, 81, 81)
                           AtTransitionType:PopMenuTransitionTypeSystemApi
                           AtTransitionRenderingColor:nil];

    PopMenuModel* model1 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"I_release1"
                            AtTitleString:@"发布行程"
                            AtTextColor:WSYColor(81, 81, 81)
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];

    PopMenuModel* model2 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"I_release1"
                            AtTitleString:@"远程关机"
                            AtTextColor:WSYColor(81, 81, 81)
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];


    _menu.dataSource = @[model, model1, model2];
    _menu.delegate = self;
    _menu.popMenuSpeed = 8.0f;
    _menu.automaticIdentificationColor = false;
    _menu.animationType = HyPopMenuViewAnimationTypeSina;
    _menu.backgroundType = HyPopMenuViewBackgroundTypeLightBlur;

    WSYPopMenuTopView* topView = [WSYPopMenuTopView new];
    topView.frame = CGRectMake(0, 44, kScreenWidth, 92);
    _menu.topView = topView;

    [_menu openMenu];
}

#pragma mark - HyPopMenuViewDelegate

- (void)popMenuView:(HyPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index {
    CYLTabBarController *tabBarController = [self cyl_tabBarController];
    UIViewController *viewController = tabBarController.selectedViewController;
//    UIViewController *viewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    if (index == 0) {
        [[WSYPrivacyPermission sharedInstance]accessPrivacyPermissionWithType:PrivacyPermissionTypeCamera completion:^(BOOL response, PrivacyPermissionAuthorizationStatus status) {
            NSLog(@"response:%d \n status:%lu",response,(unsigned long)status);
            if (response == YES) {
                WSYScanViewController *vc = [WSYScanViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [viewController presentViewController:vc animated:YES completion:nil];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机访问权限未开启" message:@"请在设置里面开启相机访问权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [viewController presentViewController:alertController animated:YES completion:nil];
            }
        }];
    } else if (index == 1) {
        WSYReleaseViewController *vc = [WSYReleaseViewController new];
        [viewController presentViewController:vc animated:YES completion:nil];
    } else {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert setHorizontalButtons:YES];
        [alert addButton:@"确定" actionBlock:^(void) {
            [viewController showLoadHUDWindow:@"关机中..."];
            NSDictionary *parameters = @{@"TravelGencyID": [WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
            [WSYNetworking shutDownWithParameters:parameters success:^(id response){
                [viewController hideLoadHUDWindow];
                if ([response[@"Code"] integerValue]== 0) {
                    [viewController showSuccessHUDWindow:@"关机成功"];
                } else {
                    [viewController showErrorHUDWindow:@"关机失败"];
                }
            } failure:^(NSError *error){
                [viewController hideLoadHUDWindow];
                [viewController showErrorHUDWindow:@"关机失败"];
            }];
        }];
        alert.completeButtonFormatBlock = ^NSDictionary* (void) {
            NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
            buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
            return buttonConfig;
        };
        [alert showCustom:[UIImage imageNamed:@"H_off"] color:kThemeColor title:@"远程关机" subTitle:@"确定远程关机所有设备?" closeButtonTitle:@"取消" duration:0.0f];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %@", @(buttonIndex));
}

#pragma mark - CYLPlusButtonSubclassing

//+ (UIViewController *)plusChildViewController {
//    UIViewController *plusChildViewController = [[UIViewController alloc] init];
//    plusChildViewController.view.backgroundColor = [UIColor redColor];
//    plusChildViewController.navigationItem.title = @"PlusChildViewController";
//    UIViewController *plusChildNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:plusChildViewController];
//    return plusChildNavigationController;
//}
//
//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 1;
//}
//
//+ (BOOL)shouldSelectPlusChildViewController {
//    BOOL isSelected = CYLExternPlusButton.selected;
//    if (isSelected) {
//        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"PlusButton is selected");
//    } else {
//        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"PlusButton is not selected");
//    }
//    return YES;
//}

+ (CGFloat)multiplierOfTabBarHeight:(CGFloat)tabBarHeight {
    return  0.3;
}

+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    return  -10;
}

//+ (NSString *)tabBarContext {
//    return NSStringFromClass([self class]);
//}

@end
