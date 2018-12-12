//
//  WSYRailModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/11.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYRailModel.h"

@implementation WSYRailData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"name" : @"Name",
             @"type" : @"Type",
             @"railID" : @"ID"
             };
}

@end

@implementation WSYRailModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYRailData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
