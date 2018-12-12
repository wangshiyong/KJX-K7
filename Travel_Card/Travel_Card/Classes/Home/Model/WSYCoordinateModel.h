//
//  WSYCoordinateModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/11.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYCoordinateData : NSObject

@property (nonatomic, strong) NSNumber *coordinateID;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSNumber *lat;

@end

@interface WSYCoordinateModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end
