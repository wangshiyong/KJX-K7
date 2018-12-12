//
//  AppDelegate.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/24.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "AppDelegate.h"
#import "WSYLoginViewController.h"
#import "WSYTabBarControllerConfig.h"
#import "WSYPlusButtonSubclass.h"

static NSString *const APIKey = @"cac778b85d7c3e8203072cdaf8bf4efa";

@interface AppDelegate () <UITabBarControllerDelegate, CYLTabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //根控制器判断
    [self setUpRootVC];
    
    //高德key
    [[AMapServices sharedServices] setApiKey:APIKey];
    
    //适配IOS 11
    [self setUpFixiOS11];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark - 私有方法

// 适配
- (void)setUpFixiOS11 {
    if (@available(ios 11.0,*)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
}

// 根控制器
- (void)setUpRootVC {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if ([[WSYUserDataTool getUserData:USER_LOGIN] integerValue] == 1) {
        [WSYUserDataTool removeUserData:ROOT_START];
        [WSYPlusButtonSubclass registerPlusButton];
        WSYTabBarControllerConfig *tabBarControllerConfig = [[WSYTabBarControllerConfig alloc] init];
        CYLTabBarController *tabBarController = tabBarControllerConfig.tabBarController;
        tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.window.rootViewController = tabBarController;
        tabBarController.delegate = self;
//        tabBarController.selectedIndex = 3;
    } else {
        [WSYUserDataTool setUserData:@1 forKey:ROOT_START];
        self.window.rootViewController = [WSYLoginViewController new];
    }
    [self.window makeKeyAndVisible];
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

@end
