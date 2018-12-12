//
//  WSYTabBarControllerConfig.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CYLTabBarController/CYLTabBarController.h>

@interface WSYTabBarControllerConfig : NSObject

@property (nonatomic, readonly, strong) CYLTabBarController *tabBarController;
@property (nonatomic, copy) NSString *context;

@end
