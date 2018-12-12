//
//  WSYTrackModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/4.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYTrackModel.h"

@implementation WSYTrackData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"lng" : @"Lng",
             @"lat" : @"Lat"
             };
}

@end

@implementation WSYTrackModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYTrackData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
