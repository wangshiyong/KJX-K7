//
//  WSYPopMenuTopView.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/4.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYPopMenuTopView.h"
#import "NSDate+JKExtension.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface WSYPopMenuTopView ()<AMapSearchDelegate>

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UILabel *label4;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation WSYPopMenuTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    
    _label1 = [UILabel new];
    _label1.font = WSYFont(50);
    _label1.textColor = WSYColor(81, 81, 81);
    _label1.text = [NSDate wsy_currentDateStringWithFormat:@"dd"];
    [self addSubview:_label1];
    
    _label2 = [UILabel new];
    _label2.font = WSYFont(13);
    _label2.textColor = WSYColor(108, 108, 108);
    _label2.text = [NSDate jk_dayFromWeekday:[NSDate date]];
    [self addSubview:_label2];
    
    _label3 = [UILabel new];
    _label3.font = WSYFont(13);
    _label3.textColor = WSYColor(108, 108, 108);
    _label3.text = [NSDate wsy_currentDateStringWithFormat:@"MM/yyyy"];
    [self addSubview:_label3];
    
    _label4 = [UILabel new];
    _label4.font = WSYFont(14);
    _label4.textColor = WSYColor(81, 81, 81);
    [self addSubview:_label4];
    
    _imageView = [UIImageView new];
    _imageView.image = [UIImage imageNamed:@"L_headLogo"];
    [self addSubview:_imageView];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city                      = [WSYUserDataTool getUserData:GPS_CITY];
    request.type                      = AMapWeatherTypeLive;
    
    [self.search AMapWeatherSearch:request];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_label1 mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(8);
    }];
    
    [_label2 mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.label1.mas_right).offset(10);
        make.centerY.equalTo(self.label1).offset(-12);
    }];
    
    [_label3 mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.label1.mas_right).offset(10);
        make.centerY.equalTo(self.label1).offset(12);
    }];
    
    [_label4 mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.label1.mas_bottom).offset(10);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.label1);
        make.right.equalTo(self).offset(-20);
        make.size.mas_equalTo((CGSize){130, 120});
    }];
}

#pragma mark - AMapSearchDelegate

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response {
    if (request.type == AMapWeatherTypeLive)
    {
        if (response.lives.count == 0)
        {
            return;
        }
        
        AMapLocalWeatherLive *liveWeather = [response.lives firstObject];
        if (liveWeather != nil)
        {
            _label4.text = [NSString stringWithFormat:@"%@: %@ %@℃",liveWeather.city, liveWeather.weather, liveWeather.temperature];
        }
    }
    else
    {
        if (response.forecasts.count == 0)
        {
            return;
        }
        
        AMapLocalWeatherForecast *forecast = [response.forecasts firstObject];
        
        if (forecast != nil)
        {
//            [self.weatherForecastView updateWeatherWithInfo:forecast];
        }
    }
}


@end
