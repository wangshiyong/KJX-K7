//
//  UIViewController+WSYHud.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WSYHud)

- (void)showLoadHUD;
- (void)showLoadHUD:(NSString *)str;
- (void)showLoadHUDWindow:(NSString *)str;
- (void)hideLoadHUD;
- (void)hideLoadHUDWindow;

/**
 加载提示
 */
- (void)showHUD:(NSString *)str;
- (void)showHUDView:(NSString *)str;
- (void)showHUDWindow:(NSString *)str;

/**
 成功提示
 */
- (void)showSuccessHUD:(NSString *)str;
- (void)showSuccessHUDView:(NSString *)str;
- (void)showSuccessHUDWindow:(NSString *)str;

/**
 错误提示
 */
- (void)showErrorHUD:(NSString *)str;
- (void)showErrorHUDView:(NSString *)str;
- (void)showErrorHUDWindow:(NSString *)str;

/**
 友好提示
 */
- (void)showInfoHUDView:(NSString *)str;

@end
