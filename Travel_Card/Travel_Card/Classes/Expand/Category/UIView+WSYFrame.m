//
//  UIView+WSYFrame.m
//  YouBao
//
//  Created by 王世勇 on 2018/5/23.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "UIView+WSYFrame.h"

@implementation UIView (WSYFrame)

- (CGFloat)wsy_x
{
    return self.frame.origin.x;
}
- (void)setWsy_x:(CGFloat)wsy_x
{
    CGRect wsyFrame = self.frame;
    wsyFrame.origin.x = wsy_x;
    self.frame = wsyFrame;
}

-(CGFloat)wsy_y
{
    return self.frame.origin.y;
}
-(void)setWsy_y:(CGFloat)wsy_y
{
    CGRect wsyFrame = self.frame;
    wsyFrame.origin.y = wsy_y;
    self.frame = wsyFrame;
}

-(CGPoint)wsy_origin
{
    return self.frame.origin;
}
-(void)setWsy_origin:(CGPoint)wsy_origin
{
    CGRect wsyFrame = self.frame;
    wsyFrame.origin = wsy_origin;
    self.frame = wsyFrame;
}

-(CGFloat)wsy_width
{
    return self.frame.size.width;
}
-(void)setWsy_width:(CGFloat)wsy_width
{
    CGRect wsyFrame = self.frame;
    wsyFrame.size.width = wsy_width;
    self.frame = wsyFrame;
}

-(CGFloat)wsy_height
{
    return self.frame.size.height;
}
-(void)setWsy_height:(CGFloat)wsy_height
{
    CGRect wsyFrame = self.frame;
    wsyFrame.size.height = wsy_height;
    self.frame = wsyFrame;
}

-(CGSize)wsy_size
{
    return self.frame.size;
}
- (void)setWsy_size:(CGSize)wsy_size
{
    CGRect wsyFrame = self.frame;
    wsyFrame.size = wsy_size;
    self.frame = wsyFrame;
}

-(CGFloat)wsy_centerX{
    
    return self.center.x;
}

-(void)setWsy_centerX:(CGFloat)wsy_centerX{
    
    CGPoint wsyFrmae = self.center;
    wsyFrmae.x = wsy_centerX;
    self.center = wsyFrmae;
}

-(CGFloat)wsy_centerY{
    
    return self.center.y;
}

-(void)setWsy_centerY:(CGFloat)wsy_centerY{
    
    CGPoint wsyFrame = self.center;
    wsyFrame.y = wsy_centerY;
    self.center = wsyFrame;
}

- (CGFloat)wsy_right{
    
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)wsy_bottom{
    
    return CGRectGetMaxY(self.frame);
}

- (void)setWsy_right:(CGFloat)wsy_right{
    
    self.wsy_x = wsy_right - self.wsy_width;
}

- (void)setWsy_bottom:(CGFloat)wsy_bottom{
    
    self.wsy_y = wsy_bottom - self.wsy_height;
}

- (BOOL)intersectWithView:(UIView *)view{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect selfRect = [self convertRect:self.bounds toView:window];
    CGRect viewRect = [view convertRect:view.bounds toView:window];
    return CGRectIntersectsRect(selfRect, viewRect);
}

- (BOOL)isShowingOnKeyWindow {
    // 主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // 以主窗口左上角为坐标原点, 计算self的矩形框
    CGRect newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect winBounds = keyWindow.bounds;
    
    // 主窗口的bounds 和 self的矩形框 是否有重叠
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
    return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects;
}

+(instancetype)wsy_viewFromXib
{
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

@end
