//
//  WSYKeyName.h
//  YouBao
//
//  Created by 王世勇 on 2018/5/22.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSYKeyName : NSObject

/** 用户账号 */
UIKIT_EXTERN NSString *const USER_ACCOUNT;
/** 旅行社ID */
UIKIT_EXTERN NSString *const TRAVELGENCY_ID;
/** 团ID */
UIKIT_EXTERN NSString *const TEAM_ID;
/** 登录状态 */
UIKIT_EXTERN NSString *const USER_LOGIN;
/** 退出状态 */
UIKIT_EXTERN NSString *const USER_LOGOUT;
/** 根控制器状态 */
UIKIT_EXTERN NSString *const ROOT_START;
/** 刷新间隔 */
UIKIT_EXTERN NSString *const REFRESH_TIME;
/** 定位城市 */
UIKIT_EXTERN NSString *const GPS_CITY;

@end
