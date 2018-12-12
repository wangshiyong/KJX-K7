//
//  WSYLoginModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/30.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYLoginData : NSObject

@property (nonatomic, strong) NSNumber *teamID;
@property (nonatomic, strong) NSNumber *travelGencyID;

@end

@interface WSYLoginModel : NSObject

@property (nonatomic, strong) WSYLoginData *data;

@end
