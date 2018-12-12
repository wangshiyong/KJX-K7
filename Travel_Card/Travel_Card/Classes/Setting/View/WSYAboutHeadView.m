//
//  WSYAboutHeadView.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYAboutHeadView.h"

@interface WSYAboutHeadView ()

@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *versionLab;

@end

@implementation WSYAboutHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        _iconImage = [[UIImageView alloc]init];
        _versionLab = [[UILabel alloc]init];
        _versionLab.textAlignment = NSTextAlignmentCenter;
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        
        _versionLab.text = [NSString stringWithFormat:@"北斗小伴旅 %@",currentVersion];
        [self addSubview:_iconImage];
        [self addSubview:_versionLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    [_iconImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(50);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [_iconImage wsy_rectWithColor:[UIColor groupTableViewBackgroundColor]];
    _iconImage.image = [UIImage imageNamed:@"S_logo"];
    
    [_versionLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.width.equalTo(self);
        make.top.equalTo(self.iconImage.mas_bottom).offset(20);
    }];
    
}

@end
