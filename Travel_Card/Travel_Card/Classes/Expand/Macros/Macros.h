//
//  Macros.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

//#define IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_5 (kScreenHeight == 568)
#define IS_IPHONE_X (kScreenHeight == 812)

#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kNavHeight (IS_IPHONE_X ? 88 : 64)
#define kTabBarHeight (IS_IPHONE_X ? 83 : 49)

#define kThemeColor  [UIColor colorWithRed:240.0/255.0 green:133.0/255.0 blue:25.0/255.0 alpha:1.0]
#define kThemeTextColor  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]
#define WSYColor(a, b, c)  [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:1.0]

#define WSYFont(a)  [UIFont systemFontOfSize:a];
#define WSYBoldFont(a)  [UIFont boldSystemFontOfSize:a];

#endif /* Macros_h */
