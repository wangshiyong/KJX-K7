//
//  WSYLoginViewModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYLoginViewModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *pwd;

@property (nonatomic, strong, readonly) RACSubject *successSubject;
@property (nonatomic, strong, readonly) RACSubject *failureSubject;
@property (nonatomic, strong, readonly) RACSubject *errorSubject;

- (RACSignal *)validSignal;

- (void)loginBtn;

@end
