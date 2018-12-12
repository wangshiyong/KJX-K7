//
//  NSObject+WSYNull.m
//  YouBao
//
//  Created by 王世勇 on 2018/8/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "NSObject+WSYNull.h"

@implementation NSObject (WSYNull)

- (BOOL)wsy_isNull {
    if ([self isEqual:[NSNull null]]) {
        return YES;
        
    }else if ([self isEqual:[NSNull class]]){
        return YES;
    }else{
        if (self == nil) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([((NSString *)self) isEqualToString:@"(null)"] || [((NSString *)self) isEqualToString:@""]) {
            return YES;
        }
    }
    
    return NO;
}

@end
