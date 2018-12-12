//
//  WSYWorkModel.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYWorkData : NSObject

@property (nonatomic, strong) NSNumber *workingMode;

@end

@interface WSYWorkModel : NSObject

@property (nonatomic, strong) WSYWorkData *data;
@property (nonatomic, strong) NSNumber *code;

@end
