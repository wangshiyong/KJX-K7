//
//  WSYLocationListModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/8.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLocationListModel.h"

@implementation WSYLocationListData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"memberName" : @"MemberName",
             @"gpsState" : @"GpsState",
             @"tel" : @"Tel",
             @"onlineTime" : @"OnlineTime",
             @"geo" : @"Geo",
             @"gpsTime" : @"GpsTime",
             @"lng" : @"Lng",
             @"lat" : @"Lat",
             @"state" : @"State",
             @"memberID" : @"MemberID",
             @"battery" : @"Battery"
             };
}

@end

@implementation WSYLocationListModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYLocationListData"
             };
}

@end
