//
//  WSYItineraryModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYItineraryData : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) NSNumber *itineraryID;

@end

@interface WSYItineraryModel : NSObject

@property (nonatomic, strong) NSArray *Data;
@property (nonatomic, strong) NSNumber *code;

@end
