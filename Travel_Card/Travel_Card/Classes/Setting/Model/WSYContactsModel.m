//
//  WSYContactsModel.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/21.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYContactsModel.h"

@implementation WSYContactsData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"contact" : @"Contact",
             @"phone" : @"Phone",
             @"memberID" : @"ID"
             };
}

@end

@implementation WSYContactsModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYContactsData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
