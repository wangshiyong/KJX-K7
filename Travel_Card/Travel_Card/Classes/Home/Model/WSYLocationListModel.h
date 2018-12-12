//
//  WSYLocationListModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/8.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYLocationListData : NSObject

@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *gpsState;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *onlineTime;
@property (nonatomic, copy) NSString *geo;
@property (nonatomic, copy) NSString *gpsTime;

@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, strong) NSNumber *battery;

@end

@interface WSYLocationListModel : NSObject

@property (nonatomic, strong) NSArray *Data;

@end
