//
//  WSYNetworking.m
//  YouBao
//
//  Created by 王世勇 on 2018/6/27.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYNetworking.h"
#import <PPNetworkHelper/PPNetworkHelper.h>
#import <AFNetworking/AFNetworking.h>
#import "XMLDictionary.h"

static const NSTimeInterval kTimeOut = 10;

@implementation WSYNetworking

+ (void)cancelRequestWithURL:(NSString *)URL {
    [PPNetworkHelper cancelRequestWithURL:URL];
}

/** 登录 */
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kLogin];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 全团定位 */
+ (NSURLSessionTask *)getTeamLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kTeamLocation];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 行程列表 */
+ (NSURLSessionTask *)getItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kItineraryList];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 清空行程列表 */
+ (NSURLSessionTask *)emptyItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kEmptyItinerary];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 删除行程列表 */
+ (NSURLSessionTask *)deleteItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kDeleteItinerary];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 发布行程 */
+ (NSURLSessionTask *)releaseItineraryWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kReleaseItinerary];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 发布单个行程 */
+ (NSURLSessionTask *)releaseOneWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kReleaseOne];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 游客列表 */
+ (NSURLSessionTask *)getTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kTouristList];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 解散团 */
+ (NSURLSessionTask *)emptyTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kEmptyTourist];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 删除单个游客 */
+ (NSURLSessionTask *)deleteTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kDeleteOne];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 添加游客 */
+ (NSURLSessionTask *)addTouristWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kAddOne];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 定位信息 */
+ (NSURLSessionTask *)getLocationInfoWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kLocationInfo];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 轨迹信息 */
+ (NSURLSessionTask *)getTrackInfoWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kTrackInfo];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 单个手动定位 */
+ (NSURLSessionTask *)handLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kHandLocation];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 全团手动定位 */
+ (NSURLSessionTask *)handTeamLocationWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kHandTeam];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 紧急联系人 */
+ (NSURLSessionTask *)getSOSWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kGetSOS];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 设置联系人电话 */
+ (NSURLSessionTask *)setSOSPhoneWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kSetSOSPhone];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 设置联系人姓名 */
+ (NSURLSessionTask *)setSOSNameWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kSetSOSName];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 获取工作模式 */
+ (NSURLSessionTask *)getModelWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kGetModel];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 设置工作模式 */
+ (NSURLSessionTask *)setModelWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kSetModel];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 获取自定义模式时间间隔 */
+ (NSURLSessionTask *)getModelTimeWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kGetModelTime];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 设置自定义模式时间间隔 */
+ (NSURLSessionTask *)setModelTimeWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kSetModelTime];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 修改导游登录密码 */
+ (NSURLSessionTask *)updatePwdWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kUpdatePwd];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 退出登录 */
+ (NSURLSessionTask *)logoutWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kLogout];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 远程关机 */
+ (NSURLSessionTask *)shutDownWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kShutDown];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 获取围栏列表 */
+ (NSURLSessionTask *)getFenceListWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kGetFence];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/** 获取围栏经纬度 */
+ (NSURLSessionTask *)getFenceCoordinateWithParameters:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@",kApiPrefix,kGetFenceCoordinate];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

#pragma mark ==========请求的公共方法==========

+ (NSURLSessionTask *)requestWithURL:(NSString *)URL parameters:(NSDictionary *)parameter success:(SuccessBlock)success failure:(FailureBlock)failure {
    [PPNetworkHelper setAFHTTPSessionManagerProperty:^(AFHTTPSessionManager *sessionManager){
        sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        sessionManager.requestSerializer.timeoutInterval = kTimeOut;
        sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    }];
    return [PPNetworkHelper POST:URL parameters:parameter success:^(id response) {
        NSDictionary *dict = [NSDictionary dictionaryWithXMLParser:response];
        NSDictionary *dictt = [self dictionaryWithJsonString:dict[@"__text"]];
        NSLog(@"%@%@\n%@",URL,parameter,dictt);
        success(dictt);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        failure(error);
    }];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
