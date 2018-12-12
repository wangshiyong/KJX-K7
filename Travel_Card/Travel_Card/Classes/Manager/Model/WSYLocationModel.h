//
//  WSYLocationModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYLocationData : NSObject

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
@property (nonatomic, strong) NSNumber *terminalID;
@property (nonatomic, strong) NSNumber *battery;

@end

@interface WSYLocationModel : NSObject

@property (nonatomic, strong) WSYLocationData *data;
@property (nonatomic, strong) NSNumber *code;

@end
