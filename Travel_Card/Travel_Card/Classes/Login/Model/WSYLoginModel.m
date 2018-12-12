//
//  WSYLoginModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/30.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYLoginModel.h"

@implementation WSYLoginModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"data" : @"Data"
             };
}

@end

@implementation WSYLoginData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"teamID" : @"ID",
             @"travelGencyID" : @"TravelGencyID"
             };
}

@end
