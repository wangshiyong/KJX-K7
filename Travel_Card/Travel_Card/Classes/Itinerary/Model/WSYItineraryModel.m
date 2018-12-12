//
//  WSYItineraryModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYItineraryModel.h"

@implementation WSYItineraryData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"content" : @"Content",
             @"createTime" : @"CreateTime",
             @"subject" : @"Subject",
             @"itineraryID" : @"ID"
             };
}

@end

@implementation WSYItineraryModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYItineraryData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
