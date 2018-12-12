//
//  WSYUserDataTool.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/1.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYUserDataTool.h"
#import <SAMKeychain/SAMKeychain.h>

static NSString *const kService = @"Service";

@implementation WSYUserDataTool

+ (BOOL)isUserExist{
    NSString *uid = [self getUserData:@"uid"];
    return uid != nil;
}

+ (BOOL)isUserExist:(NSString*)key
{
    NSString *value = [self getUserData:key];
    return value != nil;
}


+ (void)setUserData:(id)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:key];
    [userDefaults synchronize];
    
    [SAMKeychain setPassword:password forService:kService account:account];
}

+ (id)getUserData:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

+ (NSArray *)getkAccountAndPassword:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:key];
    NSString *password = [SAMKeychain passwordForService:kService account:account];
    
    if (account) {return @[account, password];}
    return nil;
}

+ (void)removeUserData:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

+ (void)deletePasswordKtsn:(NSString *)key {
    [SAMKeychain deletePasswordForService:kService account:key];
}

@end
