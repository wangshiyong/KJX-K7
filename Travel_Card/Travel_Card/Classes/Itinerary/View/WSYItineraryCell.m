//
//  WSYItineraryCell.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYItineraryCell.h"
#import "WSYItineraryModel.h"
#import "UILabel+WSYSpace.h"

@interface WSYItineraryCell ()

@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *contentImage;
@property (nonatomic, strong) UIImageView *timeImage;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation WSYItineraryCell

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
    
    _timeImage = [UIImageView new];
    [self.contentView addSubview:_timeImage];
    
    _titleLab = [UILabel new];
    _titleLab.backgroundColor = [UIColor whiteColor];
    _titleLab.layer.masksToBounds = YES;
    [self.contentView addSubview:_titleLab];

    _contentLab = [UILabel new];
    _contentLab.backgroundColor = [UIColor whiteColor];
    _contentLab.layer.masksToBounds = YES;
    _contentLab.numberOfLines = 0;
    _contentLab.font = WSYFont(15);
    _contentLab.textColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.contentView addSubview:_contentLab];
    
    _timeLab = [UILabel new];
    _timeLab.backgroundColor = [UIColor whiteColor];
    _timeLab.layer.masksToBounds = YES;
    _timeLab.font = WSYFont(13);
    _timeLab.textColor = WSYColor(170, 170, 170);
    _timeLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeLab];
    
    _contentImage = [UIImageView new];
    [self.contentView addSubview:_contentImage];
    
}

- (void)setUpViewAutoLayout {
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    
    [_contentImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(37);
        make.size.mas_equalTo((CGSize){30, 30});
    }];
    [_contentImage wsy_rectWithColor:[UIColor whiteColor]];
    _contentImage.image = [UIImage imageNamed:@"I_horn"];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
    [_contentLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(self.contentLab.mas_bottom).offset(6);
        make.bottom.equalTo(self.contentView).offset(-6);
        make.right.equalTo(self.contentView).offset(-28);
    }];
    
    [_timeImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.contentView).offset(-16);
        make.centerY.equalTo(self.timeLab);
        make.size.mas_equalTo((CGSize){10, 10});
    }];
    [_timeImage wsy_rectWithColor:[UIColor whiteColor]];
    _timeImage.image = [UIImage imageNamed:@"I_time"];
}

- (void)setData:(WSYItineraryData *)data {
    _data = data;
    _titleLab.text = data.subject;
    _contentLab.text = data.content;
    [UILabel wsy_changeLineSpaceForLabel:_contentLab WithSpace:8];
    _timeLab.text = [NSDate wsy_getLocalDateFormateUTCDate:data.createTime];
}

@end
