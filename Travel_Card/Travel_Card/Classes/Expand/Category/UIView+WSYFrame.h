//
//  UIView+WSYFrame.h
//  YouBao
//
//  Created by 王世勇 on 2018/5/23.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WSYFrame)

@property (nonatomic , assign) CGFloat wsy_width;
@property (nonatomic , assign) CGFloat wsy_height;
@property (nonatomic , assign) CGSize  wsy_size;
@property (nonatomic , assign) CGFloat wsy_x;
@property (nonatomic , assign) CGFloat wsy_y;
@property (nonatomic , assign) CGPoint wsy_origin;
@property (nonatomic , assign) CGFloat wsy_centerX;
@property (nonatomic , assign) CGFloat wsy_centerY;
@property (nonatomic , assign) CGFloat wsy_right;
@property (nonatomic , assign) CGFloat wsy_bottom;

- (BOOL)intersectWithView:(UIView *)view;

+ (instancetype)wsy_viewFromXib;
- (BOOL)isShowingOnKeyWindow;

@end
