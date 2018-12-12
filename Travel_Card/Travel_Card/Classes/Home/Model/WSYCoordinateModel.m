//
//  WSYCoordinateModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/11.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYCoordinateModel.h"

@implementation WSYCoordinateData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"coordinateID" : @"ID",
             @"lng" : @"Lng",
             @"lat" : @"Lat"
             };
}

@end

@implementation WSYCoordinateModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYCoordinateData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
