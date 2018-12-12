//
//  WSYRailModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/11.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYRailData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *railID;

@end

@interface WSYRailModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end
