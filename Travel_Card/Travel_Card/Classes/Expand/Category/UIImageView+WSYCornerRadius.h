//
//  UIImageView+WSYCornerRadius.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (WSYCornerRadius)


/**
 UIImageView 自定义圆角和背景颜色
 */
- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType color:(UIColor *)color;
- (void)wsy_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType color:(UIColor *)color;

/**
 UIImageView 圆和背景颜色
 */
- (instancetype)initWithRoundingRectImageViewWithColor:(UIColor *)color;
- (void)wsy_cornerRadiusRoundingRectWithColor:(UIColor *)color;

/**
 UIImageView 背景颜色
 */
- (instancetype)initWithRectImageViewWithColor:(UIColor *)color;
- (void)wsy_rectWithColor:(UIColor *)color;

- (void)wsy_attachBorderWidth:(CGFloat)width color:(UIColor *)color;

@end
