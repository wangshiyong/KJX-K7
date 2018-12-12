//
//  WSYLoginViewModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYLoginViewModel.h"
#import "WSYLoginModel.h"

@interface WSYLoginViewModel ()

@property (nonatomic, strong) RACSignal *userNameSignal;
@property (nonatomic, strong) RACSignal *pwdSignal;
@property (nonatomic, strong) RACSignal *loginSignal;

@end

@implementation WSYLoginViewModel

-(instancetype)init{
    if (self = [super init]) {
        _userNameSignal = RACObserve(self, userName);
        _pwdSignal = RACObserve(self, pwd);
        _successSubject = [RACSubject subject];
        _failureSubject = [RACSubject subject];
        _errorSubject   = [RACSubject subject];
    }
    return self;
}

- (RACSignal *)validSignal {
    RACSignal *validSignal = [RACSignal combineLatest:@[_userNameSignal, _pwdSignal] reduce:^id(NSString *userName, NSString *password){
        return @(userName.length >= 5 && password.length >= 6);
    }];
    return validSignal;
}

- (void)loginBtn {
    NSDictionary *parameters = @{@"UserName":_userName, @"UserPwd":_pwd};
    @weakify(self);
    [WSYNetworking getLoginWithParameters:parameters success:^(id response){
        @strongify(self);
        if ([response[@"Code"] integerValue]== 0) {
            [self.successSubject sendNext:@"登录成功"];
            [WSYUserDataTool saveOwnAccount:self.userName andPassword:self.pwd forKey:USER_ACCOUNT];
            [WSYUserDataTool setUserData:@1 forKey:USER_LOGIN];
            WSYLoginModel *model = [WSYLoginModel mj_objectWithKeyValues:response];
            [WSYUserDataTool setUserData:model.data.teamID forKey:TEAM_ID];
            [WSYUserDataTool setUserData:model.data.travelGencyID forKey:TRAVELGENCY_ID];
        } else {
            [self.failureSubject sendNext:@"账号或密码错误"];
        }
    } failure:^(NSError *error){
        @strongify(self);
        [self.errorSubject sendNext:@"登录失败"];
    }];
}

@end
