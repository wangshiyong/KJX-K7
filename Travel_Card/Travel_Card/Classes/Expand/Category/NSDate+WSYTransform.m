//
//  NSDate+WSYTransform.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "NSDate+WSYTransform.h"

@implementation NSDate (WSYTransform)

+ (NSDateFormatter *)wsy_formatter {
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    
    return formatter;
}

+ (NSString *)wsy_transformation:(NSString *)time{
    CFStringRef str = (__bridge CFStringRef)(time);
    NSString *test = [(__bridge NSString*)str substringWithRange:NSMakeRange(6, 13)];
    long long intString = [test longLongValue];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:intString/1000];
    NSDateFormatter *dateFormatter = [NSDate wsy_formatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    return currentDateStr;
}

+ (NSString*)wsy_transformationGMTDate:(NSString*)date{
    NSDateFormatter *iosDateFormater = [NSDate wsy_formatter];
    iosDateFormater.dateFormat=@"EEE, dd MMM yyyy HH:mm:ss z";
    iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    NSDate *datee = [iosDateFormater dateFromString:date];
    NSDateFormatter *resultFormatter = [NSDate wsy_formatter];
    [resultFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [resultFormatter stringFromDate:datee];
    return currentDateStr;
}

+ (NSString *)wsy_getUTCFormateLocalDate:(NSString *)localDate {
    NSDateFormatter *dateFormatter = [NSDate wsy_formatter];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    
    return dateString;
}

+ (NSString *)wsy_getLocalDateFormateUTCDate:(NSString *)utcDate {
    NSDateFormatter *dateFormatter = [NSDate wsy_formatter];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    
    return dateString;
}

+ (NSString *)wsy_currentDateStringWithFormat:(NSString *)format {
    NSDate *chosenDate = [NSDate date];
    NSDateFormatter *formatter = [NSDate wsy_formatter];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:chosenDate];
    return date;
}

@end
