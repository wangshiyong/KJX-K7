//
//  WSYLocationModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYLocationModel.h"

@implementation WSYLocationData

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
             @"terminalID" : @"TerminalID",
             @"battery" : @"Battery"
             };
}

@end

@implementation WSYLocationModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"data" : @"Data",
             @"code" : @"Code"
             };
}

@end
