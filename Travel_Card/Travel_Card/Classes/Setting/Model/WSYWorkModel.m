//
//  WSYWorkModel.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYWorkModel.h"

@implementation WSYWorkData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"workingMode" : @"WorkingMode"
             };
}

@end

@implementation WSYWorkModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"data" : @"Data",
             @"code" : @"Code"
             };
}

@end
