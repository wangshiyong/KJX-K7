//
//  NSDate+WSYTransform.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WSYTransform)

+ (NSDateFormatter *)wsy_formatter;

//时间戳转换
+ (NSString *)wsy_transformation:(NSString *)time;

+ (NSString*)wsy_transformationGMTDate:(NSString*)date;

//将本地日期字符串转为UTC日期字符串
//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式
+ (NSString *)wsy_getUTCFormateLocalDate:(NSString *)localDatel;

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)wsy_getLocalDateFormateUTCDate:(NSString *)utcDate;

//当前时间
+ (NSString *)wsy_currentDateStringWithFormat:(NSString *)format;

@end
