//
//  WSYNetworking.h
//  YouBao
//
//  Created by 王世勇 on 2018/6/27.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(id response);
typedef void(^FailureBlock)(NSError *error);

@interface WSYNetworking : NSObject

+ (void)cancelRequestWithURL:(NSString *)URL;

/** 登录 */
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 全团定位 */
+ (NSURLSessionTask *)getTeamLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 行程列表 */
+ (NSURLSessionTask *)getItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 清空行程列表 */
+ (NSURLSessionTask *)emptyItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 删除行程列表 */
+ (NSURLSessionTask *)deleteItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 发布行程 */
+ (NSURLSessionTask *)releaseItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 发布单个行程 */
+ (NSURLSessionTask *)releaseOneWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 游客列表 */
+ (NSURLSessionTask *)getTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 解散团 */
+ (NSURLSessionTask *)emptyTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 删除单个游客 */
+ (NSURLSessionTask *)deleteTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 添加游客 */
+ (NSURLSessionTask *)addTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 定位信息 */
+ (NSURLSessionTask *)getLocationInfoWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 轨迹信息 */
+ (NSURLSessionTask *)getTrackInfoWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 单个手动定位 */
+ (NSURLSessionTask *)handLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 全团手动定位 */
+ (NSURLSessionTask *)handTeamLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 紧急联系人电话和姓名 */
+ (NSURLSessionTask *)getSOSWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 设置联系人电话 */
+ (NSURLSessionTask *)setSOSPhoneWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 设置联系人姓名 */
+ (NSURLSessionTask *)setSOSNameWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 获取工作模式 */
+ (NSURLSessionTask *)getModelWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 设置工作模式 */
+ (NSURLSessionTask *)setModelWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 获取自定义模式时间间隔 */
+ (NSURLSessionTask *)getModelTimeWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 设置自定义模式时间间隔 */
+ (NSURLSessionTask *)setModelTimeWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 修改导游登录密码 */
+ (NSURLSessionTask *)updatePwdWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 退出登录 */
+ (NSURLSessionTask *)logoutWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 远程关机 */
+ (NSURLSessionTask *)shutDownWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 获取围栏列表 */
+ (NSURLSessionTask *)getFenceListWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;
/** 获取围栏经纬度 */
+ (NSURLSessionTask *)getFenceCoordinateWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
