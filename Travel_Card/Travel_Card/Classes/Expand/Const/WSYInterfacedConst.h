//
//  WSYInterfacedConst.h
//  YouBao
//
//  Created by 王世勇 on 2018/6/27.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DevelopSever 0
#define TestSever    1

@interface WSYInterfacedConst : NSObject

/** 接口前缀-开发服务器*/
UIKIT_EXTERN NSString *const kApiPrefix;

#pragma mark - 详细接口地址
/** 登录 */
UIKIT_EXTERN NSString *const kLogin;
/** 全团定位 */
UIKIT_EXTERN NSString *const kTeamLocation;
/** 行程列表 */
UIKIT_EXTERN NSString *const kItineraryList;
/** 清空行程列表 */
UIKIT_EXTERN NSString *const kEmptyItinerary;
/** 删除行程 */
UIKIT_EXTERN NSString *const kDeleteItinerary;
/** 发布行程 */
UIKIT_EXTERN NSString *const kReleaseItinerary;
/** 发布单个行程 */
UIKIT_EXTERN NSString *const kReleaseOne;
/** 游客列表 */
UIKIT_EXTERN NSString *const kTouristList;
/** 解散团 */
UIKIT_EXTERN NSString *const kEmptyTourist;
/** 删除单个游客 */
UIKIT_EXTERN NSString *const kDeleteOne;
/** 添加游客 */
UIKIT_EXTERN NSString *const kAddOne;
/** 定位信息 */
UIKIT_EXTERN NSString *const kLocationInfo;
/** 轨迹信息 */
UIKIT_EXTERN NSString *const kTrackInfo;
/** 单个手动定位 */
UIKIT_EXTERN NSString *const kHandLocation;
/** 全团手动定位 */
UIKIT_EXTERN NSString *const kHandTeam;
/** 紧急联系人电话和姓名 */
UIKIT_EXTERN NSString *const kGetSOS;
/** 紧急联系人姓名 */
UIKIT_EXTERN NSString *const kSetSOSName;
/** 紧急联系人电话 */
UIKIT_EXTERN NSString *const kSetSOSPhone;
/** 获取工作模式 */
UIKIT_EXTERN NSString *const kGetModel;
/** 设置工作模式 */
UIKIT_EXTERN NSString *const kSetModel;
/** 获取自定义模式时间间隔 */
UIKIT_EXTERN NSString *const kGetModelTime;
/** 设置自定义模式时间间隔 */
UIKIT_EXTERN NSString *const kSetModelTime;
/** 修改导游登录密码 */
UIKIT_EXTERN NSString *const kUpdatePwd;
/** 退出登录 */
UIKIT_EXTERN NSString *const kLogout;
/** 远程关机 */
UIKIT_EXTERN NSString *const kShutDown;
/** 获取围栏列表 */
UIKIT_EXTERN NSString *const kGetFence;
/** 获取围栏经纬度 */
UIKIT_EXTERN NSString *const kGetFenceCoordinate;

@end
