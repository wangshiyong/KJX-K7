//
//  WSYHomeViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYHomeViewController.h"

// Controllers
#import "WSYLoginViewController.h"
#import "WSYRailViewController.h"
// Models
#import "WSYLocationListModel.h"
#import "WSYRailModel.h"
// Views
#import "WSYAnnotation.h"
#import "WSYCalloutAnnotation.h"
#import "WSYCalloutAnnotationView.h"
// Vendors
#import "HMSegmentedControl.h"
// Categories

// Others
#import "WSYPrivacyPermission.h"

static NSString *const kSelectedIndex = @"SelectedIndex";

@interface WSYHomeViewController () <MAMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLLocationManager *locationManager;
/**自定义大头针*/
@property (nonatomic, strong) WSYAnnotation *customAnnotation;
/**分段选择器*/
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
/**定位*/
@property (nonatomic, strong) UIButton *locationBtn;
/**刷新*/
@property (nonatomic, strong) UIButton *refreshBtn;
/**电子围栏*/
@property (nonatomic, strong) UIButton *railBtn;
/**计秒*/
@property (nonatomic, strong) UIButton *timeBtn;
/**总设备*/
@property (nonatomic, strong) NSMutableArray *animations;
/**在线设备*/
@property (nonatomic, strong) NSMutableArray *onlineAnimations;
/**离线设备*/
@property (nonatomic, strong) NSMutableArray *offlineAnimations;
/**围栏列表*/
@property (nonatomic, strong) NSMutableArray *fenceList;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger timeCount;

@end

@implementation WSYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.customNavBar wr_setBottomLineHidden:YES];
    self.customNavBar.title = @"全团定位";
    
    _animations = [NSMutableArray array];
    _onlineAnimations = [NSMutableArray array];
    _offlineAnimations = [NSMutableArray array];
    _fenceList = [NSMutableArray array];

    [self setUpUI];
    [self bindUI];
    [self getFence];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView removeAnnotations:_animations];
    [_mapView removeAnnotations:_onlineAnimations];
    [_mapView removeAnnotations:_offlineAnimations];
    [_animations removeAllObjects];
    [_onlineAnimations removeAllObjects];
    [_offlineAnimations removeAllObjects];
    [self timeRefresh];
    [self getTeamLocation];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 1000.0f;
//        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    });
    
    [self.view addSubview:self.segmentedControl];
    
    
    [self.view addSubview:self.locationBtn];
    [_locationBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.view).offset(IS_IPHONE_X ? -109 : -75);
        make.size.mas_equalTo((CGSize){40, 40});
    }];
    
    [self.view addSubview:self.refreshBtn];
    [_refreshBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.locationBtn.mas_top).offset(-10);
        make.size.mas_equalTo((CGSize){40, 40});
    }];

    [self.view addSubview:self.railBtn];
    [_railBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.refreshBtn.mas_top).offset(-10);
        make.size.mas_equalTo((CGSize){40, 40});
    }];
    
    [self.view addSubview:self.timeBtn];
    [_timeBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view).offset(-15);
        make.centerY.equalTo(self.locationBtn);
        make.size.mas_equalTo((CGSize){40, 40});
    }];

}

- (void)bindUI {
    @weakify(self);
    [[self.timeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self timeSelect];
    }];
    
    [[self.segmentedControl rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(HMSegmentedControl *segmentedControl){
        @strongify(self);
        [WSYUserDataTool setUserData:@(segmentedControl.selectedSegmentIndex) forKey:kSelectedIndex];
        if (segmentedControl.selectedSegmentIndex == 0) {
            [self.mapView removeAnnotations:self.offlineAnimations];
            [self.mapView removeAnnotations:self.animations];
            [self.mapView addAnnotations:self.onlineAnimations];
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            [self.mapView removeAnnotations:self.onlineAnimations];
            [self.mapView removeAnnotations:self.animations];
            [self.mapView addAnnotations:self.offlineAnimations];
        } else {
            [self.mapView removeAnnotations:self.onlineAnimations];
            [self.mapView removeAnnotations:self.offlineAnimations];
            [self.mapView addAnnotations:self.animations];
        }
    }];
    
    [[self.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self locationClick];
    }];
    
    [[self.refreshBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self rotation];
    }];
    
    [[self.railBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self railClick];
    }];
}

/** 获取全团定位数据 */
-(void)getTeamLocation {
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
                    [self.offlineAnimations addObject:self.customAnnotation];
                } else {
                    self.customAnnotation.image = [UIImage imageNamed:@"H_online"];
                    self.customAnnotation.subtitle = @"在线";
                    [self.onlineAnimations addObject:self.customAnnotation];
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
            }
            NSString *str1 = [NSString stringWithFormat:@"总设备[%lu]",(unsigned long)self.animations.count];
            NSString *str2 = [NSString stringWithFormat:@"在线设备[%lu]",(unsigned long)self.onlineAnimations.count];
            NSString *str3 = [NSString stringWithFormat:@"离线设备[%lu]",(unsigned long)self.offlineAnimations.count];
            self.segmentedControl.sectionTitles = @[str2, str3, str1];
            self.segmentedControl.selectedSegmentIndex = [[WSYUserDataTool getUserData:kSelectedIndex] integerValue];
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                [self.mapView removeAnnotations:self.offlineAnimations];
                [self.mapView removeAnnotations:self.animations];
                [self.mapView addAnnotations:self.onlineAnimations];
            } else if (self.segmentedControl.selectedSegmentIndex == 1) {
                [self.mapView removeAnnotations:self.onlineAnimations];
                [self.mapView removeAnnotations:self.animations];
                [self.mapView addAnnotations:self.offlineAnimations];
            } else {
                [self.mapView removeAnnotations:self.onlineAnimations];
                [self.mapView removeAnnotations:self.offlineAnimations];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *parameters = @{@"TravelAgencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
        @weakify(self);
        [WSYNetworking getFenceListWithParameters:parameters success:^(id response){
            @strongify(self);
            WSYRailModel *model = [WSYRailModel mj_objectWithKeyValues:response];
            if ([model.code integerValue] == 0) {
                NSArray *array = [WSYRailData mj_objectArrayWithKeyValuesArray:model.Data];
                if (array.count == 0) {
                    
                } else {
                    self.fenceList = [NSMutableArray arrayWithArray:array];
                }
            }
        } failure:^(NSError *error){

        }];
    });
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
    [_mapView removeAnnotations:_onlineAnimations];
    [_mapView removeAnnotations:_offlineAnimations];
    [_animations removeAllObjects];
    [_onlineAnimations removeAllObjects];
    [_offlineAnimations removeAllObjects];
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

- (void)railClick {
    if (_fenceList.count > 0) {
        WSYRailViewController *vc = [WSYRailViewController new];
        vc.data = _fenceList[0];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showInfoHUDView:@"没有电子围栏"];
    }
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

#pragma mark -
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations[0];
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            
            [WSYUserDataTool setUserData:city forKey:GPS_CITY];
            
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

#pragma mark -
#pragma mark - 懒加载

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:(CGRect){0, IS_IPHONE_X ? 124 : 100, kScreenWidth, kScreenHeight - (IS_IPHONE_X ? 207 : 149)}];
        _mapView.delegate = self;
        //加入annotation旋转动画后，暂未考虑地图旋转的情况。
        _mapView.rotateCameraEnabled = NO;
        _mapView.rotateEnabled = NO;
    }
    return _mapView;
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc]initWithSectionTitles:@[@"在线设备[0]", @"离线设备[0]", @"总设备[0]"]];
        _segmentedControl.frame = (CGRect){0, IS_IPHONE_X ? 98 : 64, kScreenWidth, 36};
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:14.0f]};
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : kThemeColor};
        _segmentedControl.selectionIndicatorColor = kThemeColor;
        _segmentedControl.selectionIndicatorHeight = 2.0f;
    }
    return _segmentedControl;
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

- (UIButton *)railBtn {
    if (!_railBtn) {
        _railBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_railBtn setImage:[UIImage imageNamed:@"H_rail"] forState:UIControlStateNormal];
        _railBtn.layer.shadowOffset = CGSizeMake(0, 5);
        _railBtn.layer.shadowOpacity = 0.9;
        _railBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _railBtn;
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

@end
