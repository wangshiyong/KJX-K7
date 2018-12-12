//
//  WSYContactsModel.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/21.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYContactsData : NSObject

@property (nonatomic, copy) NSString *contact;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, strong) NSNumber *memberID;

@end

@interface WSYContactsModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end

