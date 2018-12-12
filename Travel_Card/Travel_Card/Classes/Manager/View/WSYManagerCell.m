//
//  WSYManagerCell.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYManagerCell.h"
#import "WSYMemberListModel.h"

@interface WSYManagerCell()

@property (nonatomic, strong) UILabel *tsn;
@property (nonatomic, strong) UILabel *time;

@property (nonatomic, strong) UIImageView *stateImage;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation WSYManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
        [self setUpViewAutoLayout];
    }
    return self;
}

- (void)setUpUI {
    self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _bgView = [UIView new];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_bgView];
    
    _stateImage = [UIImageView new];
    [self.contentView addSubview:_stateImage];
    
    _tsn = [UILabel new];
    _tsn.backgroundColor = [UIColor whiteColor];
    _tsn.layer.masksToBounds = YES;
    _tsn.font = WSYFont(15);
    [self.contentView addSubview:_tsn];
    
    _trackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _trackBtn.titleLabel.font = WSYFont(15);
    [_trackBtn setTitle:@"行程轨迹" forState:UIControlStateNormal];
    [_trackBtn setTitleColor:WSYColor(0, 138, 255) forState:UIControlStateNormal];
    [self.contentView addSubview:_trackBtn];
    
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_locationBtn setImage:[UIImage imageNamed:@"M_location"] forState:UIControlStateNormal];
    [self.contentView addSubview:_locationBtn];
    
    _time = [UILabel new];
    _time.backgroundColor = [UIColor whiteColor];
    _time.layer.masksToBounds = YES;
    _time.font = WSYFont(13);
    _time.textColor = WSYColor(170, 170, 170);
    [self.contentView addSubview:_time];

    _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _phoneBtn.titleLabel.font = WSYFont(15);
    [_phoneBtn setTitleColor:WSYColor(0, 138, 255) forState:UIControlStateNormal];
    [self.contentView addSubview:_phoneBtn];
}

- (void)setUpViewAutoLayout {
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    
    [_stateImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).offset(8);
        make.top.equalTo(self.contentView).offset(25);
        make.size.mas_equalTo((CGSize){10, 10});
    }];
    [_stateImage wsy_rectWithColor:[UIColor whiteColor]];
    _stateImage.image = [UIImage imageNamed:@"M_online"];
    
    [_tsn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.stateImage.mas_right).offset(8);
        make.centerY.equalTo(self.stateImage);
    }];
    
    [_trackBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.stateImage);
    }];
    
    [_locationBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.stateImage);
        make.size.mas_equalTo((CGSize){30, 30});
    }];
    
    [_time mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.locationBtn.mas_bottom).offset(10).priorityHigh();
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [_phoneBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.stateImage.mas_right).offset(8);
        make.centerY.equalTo(self.time);
    }];
}

- (void)setData:(WSYMemberListData *)data {
    _data = data;
    if ([data.isOnline integerValue] == 0) {
        _stateImage.image = [UIImage imageNamed:@"M_offline"];
    } else {
        _stateImage.image = [UIImage imageNamed:@"M_online"];
    }
    _tsn.text = data.codeMachine;
    if ([data.onlineTime wsy_isNull]) {
        _time.text = @"无在线时间";
    } else {
        _time.text = [NSDate wsy_getLocalDateFormateUTCDate:data.onlineTime];
    }
    [_phoneBtn setTitle:data.phone forState:UIControlStateNormal];
}

@end
