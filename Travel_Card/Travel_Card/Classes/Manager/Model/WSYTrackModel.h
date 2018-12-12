//
//  WSYTrackModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/4.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYTrackData : NSObject

@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *lng;

@end

@interface WSYTrackModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end
