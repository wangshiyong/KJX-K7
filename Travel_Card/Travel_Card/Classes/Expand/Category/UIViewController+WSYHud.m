//
//  UIViewController+WSYHud.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "UIViewController+WSYHud.h"
#import <MBProgressHUD/MBProgressHUD.h>

static const NSTimeInterval kHideTime = 2.f;

@implementation UIViewController (WSYHud)

-(void)showLoadHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = @"数据加载中...";
}

-(void)showLoadHUD:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
}

-(void)showLoadHUDWindow:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
}

- (void)hideLoadHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)hideLoadHUDWindow {
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] delegate] window] animated:YES];
}

-(void)showHUD:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

- (void)showHUDView:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

- (void)showHUDWindow:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    //    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showErrorHUD:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_error"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showErrorHUDView:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_error"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showErrorHUDWindow:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_error"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showSuccessHUD:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_success"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showSuccessHUDView:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_success"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

-(void)showSuccessHUDWindow:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_success"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

- (void)showInfoHUDView:(NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *image = [UIImage imageNamed:@"N_info"];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = str;
    [hud hideAnimated:YES afterDelay:kHideTime];
}

@end
