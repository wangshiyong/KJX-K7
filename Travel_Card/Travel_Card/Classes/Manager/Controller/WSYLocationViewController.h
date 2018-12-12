//
//  WSYLocationViewController.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYBaseViewController.h"

@interface WSYLocationViewController : WSYBaseViewController

@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, strong) NSNumber *terminalID;
@property (nonatomic, copy) NSString *str;
@property (nonatomic, assign, getter = isTrack) BOOL track;

@end
