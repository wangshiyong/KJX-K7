//
//  WSYRailViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/11.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYRailViewController.h"

// Controllers
#import "WSYLoginViewController.h"
// Models
#import "WSYLocationListModel.h"
#import "WSYRailModel.h"
#import "WSYCoordinateModel.h"
// Views
#import "WSYAnnotation.h"
#import "WSYCalloutAnnotation.h"
#import "WSYCalloutAnnotationView.h"
// Vendors
#import "HMSegmentedControl.h"
// Categories

// Others
#import "WSYPrivacyPermission.h"

@interface WSYRailViewController ()<MAMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPolygon *polygon;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/**自定义大头针*/
@property (nonatomic, strong) WSYAnnotation *customAnnotation;
/**定位*/
@property (nonatomic, strong) UIButton *locationBtn;
/**刷新*/
@property (nonatomic, strong) UIButton *refreshBtn;
/**计秒*/
@property (nonatomic, strong) UIButton *timeBtn;
/**围栏名称*/
@property (nonatomic, strong) UILabel *fenceName;
/**总设备*/
@property (nonatomic, strong) NSMutableArray *animations;
@property (nonatomic, strong) NSMutableArray *coordinateArray;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger timeCount;

@end

@implementation WSYRailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.customNavBar wr_setBottomLineHidden:YES];
    if ([_data.type integerValue] == 1) {
        self.customNavBar.title = @"进电子围栏";
    } else if ([_data.type integerValue] == 2) {
        self.customNavBar.title = @"出电子围栏";
    } else {
        self.customNavBar.title = @"进出电子围栏";
    }
    
    _animations = [NSMutableArray array];
    
    [self setUpUI];
    [self bindUI];
    
    [self timeRefresh];
    [self getTeamLocation];
    [self getFence];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self timeStop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法
// 初始化界面UI
- (void)setUpUI {
    [self.view addSubview:self.mapView];
    [self.mapView setZoomLevel:18];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self.view addSubview:self.locationBtn];
    [_locationBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.view).offset(-26);
        make.size.mas_equalTo((CGSize){40, 40});
    }];
    
    [self.view addSubview:self.refreshBtn];
    [_refreshBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.locationBtn.mas_top).offset(-10);
        make.size.mas_equalTo((CGSize){40, 40});
    }];
    
    [self.view addSubview:self.timeBtn];
    [_timeBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view).offset(-15);
        make.centerY.equalTo(self.locationBtn);
        make.size.mas_equalTo((CGSize){40, 40});
    }];
    
    [self.view addSubview:self.fenceName];
    [_fenceName mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(16);
        make.bottom.equalTo(self.mapView.mas_top).offset(-8);
        make.height.mas_equalTo(34);
    }];
    _fenceName.text = [NSString stringWithFormat:@"围栏名称：%@",_data.name];
}

- (void)bindUI {
    @weakify(self);
    [[self.timeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self timeSelect];
    }];
    
    [[self.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self locationClick];
    }];
    
    [[self.refreshBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self rotation];
    }];
}

/** 获取全团定位数据 */
- (void)getTeamLocation {
    [self showLoadHUD];
    NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
    @weakify(self);
    [WSYNetworking getTeamLocationWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        if ([response[@"Code"] integerValue] == 0) {
            WSYLocationListModel *model = [WSYLocationListModel mj_objectWithKeyValues:response];
            for (WSYLocationListData *data in model.Data ) {
                double lo = [data.lng doubleValue];
                double la = [data.lat doubleValue];
                if (lo == 0 && la == 0) {
                    self.coordinate = CLLocationCoordinate2DMake(30.60826, 104.06312);
                } else {
                    self.coordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake(la, lo), AMapCoordinateTypeGPS);
                }
                self.customAnnotation = [[WSYAnnotation alloc]initWithCoordinate:self.coordinate];
                
                if ([data.state integerValue] == 0) {
                    self.customAnnotation.image = [UIImage imageNamed:@"H_offline"];
                    self.customAnnotation.subtitle = @"离线";
                } else {
                    self.customAnnotation.image = [UIImage imageNamed:@"H_online"];
                    self.customAnnotation.subtitle = @"在线";
                }
                
                self.customAnnotation.title = data.memberName;
                self.customAnnotation.phone = data.tel;
                self.customAnnotation.gpsState = data.gpsState;
                
                if ([data.geo hasPrefix:@"出厂"]) {
                    self.customAnnotation.geoInfo = @"设备无定位数据，默认为出厂地址";
                } else {
                    self.customAnnotation.geoInfo = data.geo;
                }
                
                if ([data.battery integerValue] == -1) {
                    self.customAnnotation.battery = @"充电";
                }else{
                    self.customAnnotation.battery = [NSString stringWithFormat:@"%@",data.battery];
                }
                
                if ([data.onlineTime hasPrefix:@"0001"]) {
                    self.customAnnotation.onlineTime = @"无在线时间";
                } else {
                    self.customAnnotation.onlineTime = [NSDate wsy_getLocalDateFormateUTCDate:data.onlineTime];
                }
                
                if ([data.gpsTime hasPrefix:@"0001"]) {
                    self.customAnnotation.gpsTime = @"无定位时间";
                } else {
                    self.customAnnotation.gpsTime = [NSDate wsy_getLocalDateFormateUTCDate:data.gpsTime];
                }
                
                self.customAnnotation.memberID = data.memberID;
                
                [self.animations addObject:self.customAnnotation];
                [self.mapView addAnnotations:self.animations];
            }
            
        } else {
            [self showErrorHUDView:@"加载失败"];
        }
        self.refreshBtn.enabled = YES;
        [self.refreshBtn.layer removeAnimationForKey:@"rotate"];
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
        self.refreshBtn.enabled = YES;
        [self.refreshBtn.layer removeAnimationForKey:@"rotate"];
    }];
}

// 初始化计时器
- (void)timeRefresh {
    NSTimer *countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countChange) userInfo:nil repeats:YES];
    self.countTimer = countTimer;
    if ([[WSYUserDataTool getUserData:REFRESH_TIME] integerValue] > 0) {
        _timeCount = [[WSYUserDataTool getUserData:REFRESH_TIME] integerValue];
    } else {
        _timeCount = 60;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_timeCount target:self selector:@selector(rotation) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)getFence {
    NSDictionary *parameters = @{@"ElectronicFenceID":_data.railID};
    @weakify(self);
    [WSYNetworking getFenceCoordinateWithParameters:parameters success:^(id response){
        @strongify(self);
        WSYCoordinateModel *model = [WSYCoordinateModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            NSArray *array = [WSYCoordinateData mj_objectArrayWithKeyValuesArray:model.Data];
            self.coordinateArray = [NSMutableArray array];
            for(int i = 0; i < array.count; i++){
                WSYCoordinateData *data = array[i];
                [self.coordinateArray addObject:[NSValue valueWithMKCoordinate:AMapCoordinateConvert(CLLocationCoordinate2DMake([data.lat doubleValue], [data.lng doubleValue]), AMapCoordinateTypeBaidu)]];
            }
            CLLocationCoordinate2D coors[self.coordinateArray.count];
            NSInteger i = 0;
            for (NSValue *value in self.coordinateArray) {
                coors[i] = [value MKCoordinateValue];
                i++;
            }
            
            //画围栏
            self.polygon = [MAPolygon polygonWithCoordinates:coors count:self.coordinateArray.count];
            [self.mapView addOverlay:self.polygon];
            [self.mapView setCenterCoordinate:[self.coordinateArray.lastObject MKCoordinateValue]];
        }
    } failure:^(NSError *error){
        
    }];
}

#pragma mark -
#pragma mark - 事件响应

- (void)countChange {
    _timeCount -= 1;
    if (_timeCount == 0) {
        if ([[WSYUserDataTool getUserData:REFRESH_TIME] integerValue] > 0) {
            _timeCount = [[WSYUserDataTool getUserData:REFRESH_TIME] integerValue];
        }else {
            _timeCount = 60;
            [WSYUserDataTool setUserData:@"60" forKey:REFRESH_TIME];
        }
    }
    [_timeBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_timeCount] forState:UIControlStateNormal];
}

/** 全团手动定位 */
- (void)locationClick {
    @weakify(self);
    [[WSYPrivacyPermission sharedInstance]accessPrivacyPermissionWithType:PrivacyPermissionTypeLocation completion:^(BOOL response, PrivacyPermissionAuthorizationStatus status) {
        if (response == YES) {
            @strongify(self);
            self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            [self.mapView setZoomLevel:18];
            self.locationBtn.enabled = NO;
            NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
            [WSYNetworking handTeamLocationWithParameters:parameters success:^(id response){
                @strongify(self);
                self.locationBtn.enabled = YES;
            } failure:^(NSError *error){
                @strongify(self);
                self.locationBtn.enabled = YES;
            }];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位服务未开启" message:@"请在设置里面开启定位服务" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

/** 刷新 */
- (void)rotation {
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *50];
    animation.duration = 10;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [_refreshBtn.layer addAnimation:animation forKey:@"rotate"];
    _refreshBtn.enabled = NO;
    [_mapView removeAnnotations:_animations];
    [_animations removeAllObjects];
    [self getTeamLocation];
}

/** 选择刷新时间 */
- (void)timeSelect {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    @weakify(self);
    [alert addButton:@"30S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"30" forKey:REFRESH_TIME];
        [self timeRefresh];
        [self rotation];
    }];
    [alert addButton:@"40S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"40" forKey:REFRESH_TIME];
        [self timeRefresh];
        [self rotation];
    }];
    [alert addButton:@"50S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"50" forKey:REFRESH_TIME];
        [self timeRefresh];
        [self rotation];
    }];
    [alert addButton:@"60S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"60" forKey:REFRESH_TIME];
        [self timeRefresh];
        [self rotation];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"H_time"] color:kThemeColor title:@"刷新时间" subTitle:@"请选择自动刷新时间" closeButtonTitle:@"取消" duration:0.0f];
}

- (void)timeStop {
    [_timer invalidate];
    [_countTimer invalidate];
    _countTimer = nil;
    _timer = nil;
}

#pragma mark -
#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[WSYAnnotation class]]){
        static NSString *key = @"WSYAnnotationKey";
        MAAnnotationView *annotationView=[_mapView dequeueReusableAnnotationViewWithIdentifier:key];
        if (!annotationView) {
            annotationView=[[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key];
        }
        
        annotationView.annotation = annotation;
        annotationView.image = ((WSYAnnotation *)annotation).image;
        annotationView.centerOffset = CGPointMake(0, -22.5);
        
        return annotationView;
    } else if ([annotation isKindOfClass:[WSYCalloutAnnotation class]]) {
        WSYCalloutAnnotationView *calloutView = [WSYCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation = (id)annotation;
        return calloutView;
    } else {
        return nil;
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    WSYAnnotation *annotation = (id)view.annotation;
    
    if ([annotation isKindOfClass:[WSYAnnotation class]]) {
        WSYCalloutAnnotation *calloutAnnotation = [[WSYCalloutAnnotation alloc]init];
        calloutAnnotation.coordinate = view.annotation.coordinate;
        calloutAnnotation.gpsState = annotation.gpsState;
        calloutAnnotation.onlineTime = annotation.onlineTime;
        calloutAnnotation.gpsTime = annotation.gpsTime;
        calloutAnnotation.title = annotation.title;
        calloutAnnotation.subtitle = annotation.subtitle;
        calloutAnnotation.phone = annotation.phone;
        calloutAnnotation.battery = annotation.battery;
        calloutAnnotation.memberID = annotation.memberID;
        view.centerOffset = CGPointMake(0, -25.875);
        calloutAnnotation.geoInfo = annotation.geoInfo;
        [mapView addAnnotation:calloutAnnotation];
        [self.mapView setCenterCoordinate:calloutAnnotation.coordinate];
        
        [UIView animateWithDuration:1.0 animations:^{
            [view.layer pop_removeAllAnimations];
            POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            spring.delegate            = self;
            // 动画起始值 + 动画结束值
            spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.8f, 0.8f)];
            spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.15f, 1.15f)];
            // 参数的设置
            spring.springSpeed         = 12.0;
            spring.springBounciness    = 4.0;
            spring.dynamicsMass        = 1.0;
            spring.dynamicsFriction    = 5.0;
            spring.dynamicsTension     = 200.0;
            [view.layer pop_addAnimation:spring forKey:nil];
        } completion:^(BOOL finished){
            [self.timer setFireDate:[NSDate distantFuture]];
            [self.countTimer setFireDate:[NSDate distantFuture]];
        }];
        
    }
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    view.centerOffset = CGPointMake(0, -22.5);
    [UIView animateWithDuration:1 animations:^{
        [view.layer pop_removeAllAnimations];
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        spring.delegate            = self;
        // 动画起始值 + 动画结束值
        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(1.35f, 1.35f)];
        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        // 参数的设置
        spring.springSpeed         = 12.0;
        spring.springBounciness    = 4.0;
        spring.dynamicsMass        = 1.0;
        spring.dynamicsFriction    = 5.0;
        spring.dynamicsTension     = 200.0;
        [view.layer pop_addAnimation:spring forKey:nil];
    } completion:^(BOOL finished) {
        [self.timer setFireDate:[[NSDate alloc]initWithTimeIntervalSinceNow:self.timeCount]];
        [self.countTimer setFireDate:[[NSDate alloc]initWithTimeIntervalSinceNow:1]];
    }];
    
    [self removeCustomAnnotation];
}

- (void)removeCustomAnnotation {
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[WSYCalloutAnnotation class]]) {
            [self.mapView removeAnnotation:obj];
        }
    }];
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    for (MAAnnotationView *view in views) {
        [view.layer pop_removeAllAnimations];
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        spring.delegate            = self;
        // 动画起始值 + 动画结束值
        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.7f, 0.7f)];
        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        // 参数的设置
        spring.springSpeed         = 12.0;
        spring.springBounciness    = 4.0;
        spring.dynamicsMass        = 1.0;
        spring.dynamicsFriction    = 5.0;
        spring.dynamicsTension     = 200.0;
        [view.layer pop_addAnimation:spring forKey:nil];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolygon class]]){
        MAPolygonRenderer *polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:(id)overlay];
        polygonRenderer.lineWidth   = 3.f;
        polygonRenderer.strokeColor = [UIColor redColor];
        polygonRenderer.fillColor   = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:103/255.0 alpha:0.4];
        
        return polygonRenderer;
    }
    return nil;
}

#pragma mark -
#pragma mark - 懒加载

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:(CGRect){0, IS_IPHONE_X ? 124 : 110, kScreenWidth, kScreenHeight - (IS_IPHONE_X ? 124 : 110)}];
        _mapView.delegate = self;
        //加入annotation旋转动画后，暂未考虑地图旋转的情况。
        _mapView.rotateCameraEnabled = NO;
        _mapView.rotateEnabled = NO;
    }
    return _mapView;
}

- (UIButton *)refreshBtn {
    if (!_refreshBtn) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshBtn setImage:[UIImage imageNamed:@"H_refresh"] forState:UIControlStateNormal];
        _refreshBtn.layer.shadowOffset = CGSizeMake(0, 5);
        _refreshBtn.layer.shadowOpacity = 0.9;
        _refreshBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _refreshBtn;
}

- (UIButton *)locationBtn {
    if (!_locationBtn) {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationBtn setImage:[UIImage imageNamed:@"H_location"] forState:UIControlStateNormal];
        _locationBtn.layer.shadowOffset = CGSizeMake(0, 5);
        _locationBtn.layer.shadowOpacity = 0.9;
        _locationBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _locationBtn;
}

- (UIButton *)timeBtn {
    if (!_timeBtn) {
        _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeBtn.backgroundColor = [UIColor whiteColor];
        [_timeBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
        _timeBtn.layer.cornerRadius = 20;
        _timeBtn.layer.shadowOffset = CGSizeMake(0, 5);
        _timeBtn.layer.shadowOpacity = 0.9;
        _timeBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _timeBtn;
}

- (UILabel *)fenceName {
    if (!_fenceName) {
        _fenceName = [UILabel new];
    }
    return _fenceName;
}

@end
