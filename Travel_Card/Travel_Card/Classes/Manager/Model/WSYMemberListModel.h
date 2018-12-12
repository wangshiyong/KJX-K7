//
//  WSYMemberListModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYMemberListData : NSObject

@property (nonatomic, copy) NSString *codeMachine;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *onlineTime;
@property (nonatomic, strong) NSNumber *isOnline;
@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, strong) NSNumber *terminalID;

@end

@interface WSYMemberListModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end
