//
//  UIViewController+WSYLog.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "UIViewController+WSYLog.h"
#import <objc/runtime.h>

@implementation UIViewController (WSYLog)

+(void)load{
#ifdef DEBUG
    SEL systemSel = @selector(viewWillAppear:);
    SEL swizzSel = @selector(logViewWillAppear:);
    Method systemMethod = class_getInstanceMethod(self, systemSel);
    Method swizzMethod = class_getInstanceMethod(self, swizzSel);
    
    BOOL isAddMethod = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
    if (isAddMethod) {
        class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, swizzMethod);
    }
    
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"dealloc")),
                                   
                                   class_getInstanceMethod(self, @selector(swizzledDealloc)));
#endif
}

-(void)logViewWillAppear:(BOOL)animated{
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"WSY"] == YES) {
        NSLog(@"%@ will appear",className);
    }
    [self logViewWillAppear:animated];
}

-(void)swizzledDealloc{
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"WSY"] == YES) {
        NSLog(@"%@ 销毁",className);
    }
    [self swizzledDealloc];
}

@end
