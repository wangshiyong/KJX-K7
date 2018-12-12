//
//  WSYReleaseViewController.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYBaseViewController.h"

@interface WSYReleaseViewController : WSYBaseViewController

@property (nonatomic, assign) BOOL isMemberRelease;
@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, copy) NSString *deviceID;

@end
