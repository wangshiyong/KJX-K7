//
//  WSYMemberListModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYMemberListModel.h"

@implementation WSYMemberListData

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"codeMachine" : @"CodeMachine",
             @"isOnline" : @"IsOnline",
             @"memberID" : @"MemberID",
             @"onlineTime" : @"OnlineTime",
             @"phone" : @"Phone",
             @"terminalID" : @"TerminalID"
             };
}

@end

@implementation WSYMemberListModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"Data" : @"WSYMemberListData"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"code" : @"Code"
             };
}

@end
