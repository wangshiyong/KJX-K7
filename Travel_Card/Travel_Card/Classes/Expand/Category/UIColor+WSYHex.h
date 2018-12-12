//
//  UIColor+WSYHex.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/30.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WSYHex)

+ (UIColor *)wsy_colorWithHex:(UInt32)hex;
+ (UIColor *)wsy_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
+ (UIColor *)wsy_colorWithHexString:(NSString *)hexString;
- (NSString *)wsy_HEXString;

@end
