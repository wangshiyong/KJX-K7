//
//  UIColor+WSYHex.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/30.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "UIColor+WSYHex.h"

CGFloat wsy_colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@implementation UIColor (WSYHex)

+ (UIColor *)wsy_colorWithHex:(UInt32)hex {
    return [UIColor wsy_colorWithHex:hex andAlpha:1];
}

+ (UIColor *)wsy_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF)/255.0
                           green:((hex >> 8) & 0xFF)/255.0
                            blue:(hex & 0xFF)/255.0
                           alpha:alpha];
}

+ (UIColor *)wsy_colorWithHexString:(NSString *)hexString {
    CGFloat alpha, red, blue, green;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch ([colorString length]) {
            case 3: // #RGB
            alpha = 1.0f;
            red   = wsy_colorComponentFrom(colorString, 0, 1);
            green = wsy_colorComponentFrom(colorString, 1, 1);
            blue  = wsy_colorComponentFrom(colorString, 2, 1);
            break;
            
            case 4: // #ARGB
            alpha = wsy_colorComponentFrom(colorString, 0, 1);
            red   = wsy_colorComponentFrom(colorString, 1, 1);
            green = wsy_colorComponentFrom(colorString, 2, 1);
            blue  = wsy_colorComponentFrom(colorString, 3, 1);
            break;
            
            case 6: // #RRGGBB
            alpha = 1.0f;
            red   = wsy_colorComponentFrom(colorString, 0, 2);
            green = wsy_colorComponentFrom(colorString, 2, 2);
            blue  = wsy_colorComponentFrom(colorString, 4, 2);
            break;
            
            case 8: // #AARRGGBB
            alpha = wsy_colorComponentFrom(colorString, 0, 2);
            red   = wsy_colorComponentFrom(colorString, 2, 2);
            green = wsy_colorComponentFrom(colorString, 4, 2);
            blue  = wsy_colorComponentFrom(colorString, 6, 2);
            break;
            
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)wsy_HEXString{
    UIColor* color = self;
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

@end
