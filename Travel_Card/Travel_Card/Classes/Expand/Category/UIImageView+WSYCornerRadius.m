//
//  UIImageView+WSYCornerRadius.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "UIImageView+WSYCornerRadius.h"

#import <objc/runtime.h>

const char kProcessedImage;

@interface UIImageView ()

@property (assign, nonatomic) CGFloat wsyRadius;
@property (assign, nonatomic) UIRectCorner roundingCorners;
@property (assign, nonatomic) CGFloat wsyBorderWidth;
@property (strong, nonatomic) UIColor *wsyBorderColor;
@property (strong, nonatomic) UIColor *wsyBGColor;
@property (assign, nonatomic) BOOL wsyHadAddObserver;
@property (assign, nonatomic) BOOL wsyIsRounding;

@end

@implementation UIImageView (WSYCornerRadius)
/**
 * @brief init the UIImageView, no off-screen-rendered, no Color Blended layers
 */
- (instancetype)initWithRectImageViewWithColor:(UIColor *)color{
    self = [super init];
    if (self) {
        [self wsy_rectWithColor:color];
    }
    return self;
}

/**
 * @brief init the Rounding UIImageView, no off-screen-rendered, no Color Blended layers
 */
- (instancetype)initWithRoundingRectImageViewWithColor:(UIColor *)color{
    self = [super init];
    if (self) {
        [self wsy_cornerRadiusRoundingRectWithColor:color];
    }
    return self;
}

/**
 * @brief init the UIImageView with cornerRadius, no off-screen-rendered, no Color Blended layers
 */
- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType color:(UIColor *)color{
    self = [super init];
    if (self) {
        [self wsy_cornerRadiusAdvance:cornerRadius rectCornerType:rectCornerType color:color];
    }
    return self;
}

/**
 * @brief attach border for UIImageView with width & color
 */
- (void)wsy_attachBorderWidth:(CGFloat)width color:(UIColor *)color {
    self.wsyBorderWidth = width;
    self.wsyBorderColor = color;
}

#pragma mark - Kernel
/**
 * @brief clip the cornerRadius with image, UIImageView must be setFrame before, no off-screen-rendered
 */
- (void)wsy_cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}

/**
 * @brief clip the cornerRadius with image, draw the backgroundColor you want, UIImageView must be setFrame before, no off-screen-rendered, no Color Blended layers
 */
- (void)wsy_cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType backgroundColor:(UIColor *)backgroundColor {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:self.bounds];
    [backgroundColor setFill];
    [backgroundRect fill];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}

/**
 * @brief set cornerRadius for UIImageView, no off-screen-rendered
 */
- (void)wsy_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType color:(UIColor *)color{
    self.wsyRadius = cornerRadius;
    self.roundingCorners = rectCornerType;
    self.wsyIsRounding = NO;
    self.wsyBGColor = color;
    if (!self.wsyHadAddObserver) {
        [[self class] swizzleDealloc];
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.wsyHadAddObserver = YES;
    }
    //Xcode 8 xib 删除了控件的Frame信息，需要主动创造
    [self layoutIfNeeded];
}

/**
 * @brief become Rounding UIImageView, no off-screen-rendered
 */
- (void)wsy_cornerRadiusRoundingRectWithColor:(UIColor *)color {
    self.wsyIsRounding = YES;
    self.wsyBGColor = color;
    if (!self.wsyHadAddObserver) {
        [[self class] swizzleDealloc];
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.wsyHadAddObserver = YES;
    }
    //Xcode 8 xib 删除了控件的Frame信息，需要主动创造
    [self layoutIfNeeded];
}

/**
 * @brief become Rounding UIImageView, no off-screen-rendered
 */
- (void)wsy_rectWithColor:(UIColor *)color {
    self.wsyIsRounding = NO;
    self.wsyBGColor = color;
    self.wsyRadius = 0;
    self.roundingCorners = 0;
    if (!self.wsyHadAddObserver) {
        [[self class] swizzleDealloc];
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.wsyHadAddObserver = YES;
    }
    //Xcode 8 xib 删除了控件的Frame信息，需要主动创造
    [self layoutIfNeeded];
}

#pragma mark - Private
- (void)drawBorder:(UIBezierPath *)path {
    if (0 != self.wsyBorderWidth && nil != self.wsyBorderColor) {
        [path setLineWidth:2 * self.wsyBorderWidth];
        [self.wsyBorderColor setStroke];
        [path stroke];
    }
}

- (void)wsy_dealloc {
    if (self.wsyHadAddObserver) {
        [self removeObserver:self forKeyPath:@"image"];
    }
    [self wsy_dealloc];
}

- (void)validateFrame {
    if (self.frame.size.width == 0) {
        [self.class swizzleLayoutSubviews];
    }
}

+ (void)swizzleMethod:(SEL)oneSel anotherMethod:(SEL)anotherSel {
    Method oneMethod = class_getInstanceMethod(self, oneSel);
    Method anotherMethod = class_getInstanceMethod(self, anotherSel);
    method_exchangeImplementations(oneMethod, anotherMethod);
}

+ (void)swizzleDealloc {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:NSSelectorFromString(@"dealloc") anotherMethod:@selector(wsy_dealloc)];
    });
}

+ (void)swizzleLayoutSubviews {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(layoutSubviews) anotherMethod:@selector(wsy_LayoutSubviews)];
    });
}

- (void)wsy_LayoutSubviews {
    [self wsy_LayoutSubviews];
    if (self.wsyIsRounding) {
        [self wsy_cornerRadiusWithImage:self.image cornerRadius:self.frame.size.width/2 rectCornerType:UIRectCornerAllCorners backgroundColor:self.wsyBGColor];
    } else if (0 != self.wsyRadius && 0 != self.roundingCorners && nil != self.image) {
        [self wsy_cornerRadiusWithImage:self.image cornerRadius:self.wsyRadius rectCornerType:self.roundingCorners backgroundColor:self.wsyBGColor];
    } else {
        [self wsy_cornerRadiusWithImage:self.image cornerRadius:0 rectCornerType:0 backgroundColor:self.wsyBGColor];
    }
}

#pragma mark - KVO for .image
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        if ([newImage isMemberOfClass:[NSNull class]]) {
            return;
        } else if ([objc_getAssociatedObject(newImage, &kProcessedImage) intValue] == 1) {
            return;
        }
        [self validateFrame];
        if (self.wsyIsRounding) {
            [self wsy_cornerRadiusWithImage:newImage cornerRadius:self.frame.size.width/2 rectCornerType:UIRectCornerAllCorners backgroundColor:self.wsyBGColor];
        } else if (0 != self.wsyRadius && 0 != self.roundingCorners && nil != self.image) {
            [self wsy_cornerRadiusWithImage:newImage cornerRadius:self.wsyRadius rectCornerType:self.roundingCorners backgroundColor:self.wsyBGColor];
        } else {
            [self wsy_cornerRadiusWithImage:newImage cornerRadius:0 rectCornerType:0 backgroundColor:self.wsyBGColor];
        }
    }
}

#pragma mark property
- (CGFloat)wsyBorderWidth {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setWsyBorderWidth:(CGFloat)wsyBorderWidth {
    objc_setAssociatedObject(self, @selector(wsyBorderWidth), @(wsyBorderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wsyBorderColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWsyBorderColor:(UIColor *)wsyBorderColor {
    objc_setAssociatedObject(self, @selector(wsyBorderColor), wsyBorderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wsyBGColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWsyBGColor:(UIColor *)wsyBGColor {
    objc_setAssociatedObject(self, @selector(wsyBGColor), wsyBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wsyHadAddObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWsyHadAddObserver:(BOOL)wsyHadAddObserver {
    objc_setAssociatedObject(self, @selector(wsyHadAddObserver), @(wsyHadAddObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wsyIsRounding {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWsyIsRounding:(BOOL)wsyIsRounding {
    objc_setAssociatedObject(self, @selector(wsyIsRounding), @(wsyIsRounding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIRectCorner)roundingCorners {
    return [objc_getAssociatedObject(self, _cmd) unsignedLongValue];
}

- (void)setRoundingCorners:(UIRectCorner)roundingCorners {
    objc_setAssociatedObject(self, @selector(roundingCorners), @(roundingCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)wsyRadius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setWsyRadius:(CGFloat)wsyRadius {
    objc_setAssociatedObject(self, @selector(wsyRadius), @(wsyRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
