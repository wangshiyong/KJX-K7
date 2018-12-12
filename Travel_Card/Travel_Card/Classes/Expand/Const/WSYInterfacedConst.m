//
//  WSYInterfacedConst.m
//  YouBao
//
//  Created by 王世勇 on 2018/6/27.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYInterfacedConst.h"

@implementation WSYInterfacedConst

#if DevelopSever
/** 接口前缀-开发服务器*/
NSString *const kApiPrefix = @"http://app.bdontour.com:8888/WebAppService.asmx";
#elif TestSever
/** 接口前缀-测试服务器*/
NSString *const kApiPrefix = @"http://app.bdontour.com:8888/WebAppService.asmx";
#endif

/** 登录 */
NSString *const kLogin = @"/TouristTeamLogin";
/** 全团定位 */
NSString *const kTeamLocation = @"/GetTouristTeamLocation";
/** 行程列表 */
NSString *const kItineraryList = @"/GetTripToTimeSpan";
/** 清空行程列表 */
NSString *const kEmptyItinerary = @"/ClearTouristTeamAllTrip";
/** 删除行程 */
NSString *const kDeleteItinerary = @"/DeleteTrip";
/** 发布行程 */
NSString *const kReleaseItinerary = @"/CreateTouristTeamTrip";
/** 发布单个行程 */
NSString *const kReleaseOne = @"/CreatTripToMember";
/** 游客列表 */
NSString *const kTouristList = @"/GetAllTourist";
/** 解散团 */
NSString *const kEmptyTourist = @"/DeleteAllTourist";
/** 删除单个游客 */
NSString *const kDeleteOne = @"/DeleteOneTourist";
/** 添加游客 */
NSString *const kAddOne = @"/AddTourist";
/** 定位信息 */
NSString *const kLocationInfo = @"/GetMenberLocation";
/** 轨迹信息 */
NSString *const kTrackInfo = @"/GetMemberHistoryTrace";
/** 单个手动定位 */
NSString *const kHandLocation = @"/GetOneHandLocation";
/** 全团手动定位 */
NSString *const kHandTeam = @"/GetTouristTeamHandLocation";
/** 紧急联系人电话和姓名 */
NSString *const kGetSOS = @"/GetTouristTeamSOSName";
/** 紧急联系人姓名 */
NSString *const kSetSOSName = @"/SetTouristTeamSOSName";
/** 紧急联系人电话 */
NSString *const kSetSOSPhone = @"/SetTouristTeamSOSPhone";
/** 获取工作模式 */
NSString *const kGetModel = @"/GetTouristTeamWorkMode";
/** 设置工作模式 */
NSString *const kSetModel = @"/SetTouristTeamWorkModel";
/** 获取自定义模式时间间隔 */
NSString *const kGetModelTime = @"/GetTouristTeamCustomModelTime";
/** 设置自定义模式时间间隔 */
NSString *const kSetModelTime = @"/SetTouristTeamCustomModel";
/** 修改导游登录密码 */
NSString *const kUpdatePwd = @"/UpdateTouristTeamAccount";
/** 退出登录 */
NSString *const kLogout = @"/TouristTeamLogout";
/** 远程关机 */
NSString *const kShutDown = @"/SetTerminalONAndOFF";
/** 获取围栏列表 */
NSString *const kGetFence = @"/GetTouristTeamElectronicFence";
/** 获取围栏经纬度 */
NSString *const kGetFenceCoordinate = @"/GetElectronicFenceCoordinate";

@end
