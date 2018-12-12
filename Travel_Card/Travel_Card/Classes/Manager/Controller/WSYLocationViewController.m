//
//  WSYLocationViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYLocationViewController.h"

// Controllers
#import "WSYTimeSelectViewController.h"
// Models
#import "WSYLocationModel.h"
#import "WSYTrackModel.h"
// Views
#import "WSYAnnotation.h"
#import "WSYCalloutAnnotation.h"
#import "WSYCalloutAnnotationView.h"
// Vendors

// Categories

// Others
#import "WSYPrivacyPermission.h"

@interface WSYLocationViewController ()<MAMapViewDelegate> {
    CLLocationCoordinate2D * coords;
}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPolyline *route;
@property (nonatomic, strong) MAAnimatedAnnotation* annotation;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/**自定义大头针*/
@property (nonatomic, strong) WSYAnnotation *customAnnotation;
/**定位*/
@property (nonatomic, strong) UIButton *locationBtn;
/**刷新*/
@property (nonatomic, strong) UIButton *refreshBtn;
/**选择刷新时间*/
@property (nonatomic, strong) UIButton *time;
/**选择日期*/
@property (nonatomic, strong) UIButton *timeBtn;
/**gps轨迹经纬度*/
@property (nonatomic, strong) NSMutableArray *coordinates;
/**lbs轨迹经纬度*/
@property (nonatomic, strong) NSMutableArray *lbsCoordinates;
/**gps轨迹点*/
@property (nonatomic, strong) NSMutableArray *routeAnno;
/**基站轨迹点*/
@property (nonatomic, strong) NSMutableArray *lbsAnno;

@property (nonatomic, strong) NSMutableString *startTime;
@property (nonatomic, strong) NSMutableString *endTime;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) NSTimer *countTimer;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) NSInteger timeCount;

@end

@implementation WSYLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    [self bindUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    [_countTimer invalidate];
    _countTimer = nil;
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
    
    if (_track) {
        self.customNavBar.title = @"历史轨迹";
        [self.customNavBar wr_setRightButtonWithTitle:@"回放" titleColor:kThemeColor];
        @weakify(self);
        self.customNavBar.onClickRightButton = ^{
            @strongify(self);
            [self playMove];
        };
        
        [self.customNavBar wr_setRightButton1Withtitle:@"基站" titleColor:kThemeColor];
        self.customNavBar.onClickRightButton1 = ^{
            @strongify(self);
            [self getLBSTrackInfo];
        };
        
        [self.mapView addSubview:self.timeBtn];
        [self.timeBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_offset(15);
             make.top.equalTo(self.view).offset(kNavHeight + 16);
            make.size.mas_offset((CGSize){40, 40});
        }];
        
        _startTime = [NSMutableString stringWithString:[NSDate wsy_currentDateStringWithFormat:@"YYYY-MM-dd 00:00:00"]];
        _endTime = [NSMutableString stringWithString:[NSDate wsy_currentDateStringWithFormat:@"YYYY-MM-dd HH:mm:ss"]];
        _lbsCoordinates = [NSMutableArray array];
        _coordinates = [NSMutableArray array];
        [self getTrackInfo];
    } else {
        self.customNavBar.title = @"精确定位";
        
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
        
        [self.view addSubview:self.time];
        [_time mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.view).offset(-15);
            make.centerY.equalTo(self.locationBtn);
            make.size.mas_equalTo((CGSize){40, 40});
        }];
        
        [self timeRefresh];
        [self getLocationInfo];
    }
}

- (void)getLocationInfo {
    [self showLoadHUD];
    NSDictionary *parameters = @{@"TravelGencyID": [WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID],@"MemberID": _memberID};
    @weakify(self);
    [WSYNetworking getLocationInfoWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYLocationModel *model = [WSYLocationModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            WSYLocationData *data = [WSYLocationData mj_objectWithKeyValues:model.data];
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
            
            [self.mapView addAnnotation:self.customAnnotation];
            [self.mapView selectAnnotation:self.customAnnotation animated:YES];
        } else {
            [self showInfoHUDView:@"无定位信息"];
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

- (void)getTrackInfo {
    [self showLoadHUD];
    NSDictionary *parameters = @{@"MemberID": _memberID,
                            @"TerminalID": _terminalID,
                            @"StartTime": [NSDate wsy_getUTCFormateLocalDate:_startTime],
                            @"EndTime": [NSDate wsy_getUTCFormateLocalDate:_endTime],
                            @"Type":@1
                            };
    @weakify(self);
    [WSYNetworking getTrackInfoWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYTrackModel *model = [WSYTrackModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            if (model.Data.count == 0) {
                [self showInfoHUDView:@"无历史轨迹点"];
                self.customNavBar.rightButton.enabled = NO;
                self.customNavBar.rightButton.alpha = 0.4;
            } else {
                for (WSYTrackData *data in model.Data) {
                    NSString *coordinates = [NSString stringWithFormat:@"%@,%@",data.lng,data.lat];
                    [self.coordinates addObject:coordinates];
                }
                //加载轨迹
                [self initRoute];
            }
            
        } else {
            [self showInfoHUDView:@"无历史轨迹点"];
        }
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

- (void)getLBSTrackInfo {
    [self.mapView removeAnnotations:_lbsAnno];
    [_lbsCoordinates removeAllObjects];
    [self showLoadHUD];
    NSDictionary *parameters = @{@"MemberID": _memberID,
                                 @"TerminalID": _terminalID,
                                 @"StartTime": [NSDate wsy_getUTCFormateLocalDate:_startTime],
                                 @"EndTime": [NSDate wsy_getUTCFormateLocalDate:_endTime],
                                 @"Type":@2
                                 };
    @weakify(self);
    [WSYNetworking getTrackInfoWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYTrackModel *model = [WSYTrackModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            if (model.Data.count == 0) {
                [self showInfoHUDView:@"无历史基站点"];
            } else {
                for (WSYTrackData *data in model.Data) {
                    NSString *coordinates = [NSString stringWithFormat:@"%@,%@",data.lng,data.lat];
                    [self.lbsCoordinates addObject:coordinates];
                }
                CLLocationCoordinate2D * coords = malloc(self.lbsCoordinates.count * sizeof(CLLocationCoordinate2D));
                for (NSInteger i = 0; i < self.lbsCoordinates.count; i++) {
                    NSArray *coordArrTotal = [self.lbsCoordinates[i] componentsSeparatedByString:@","];
                    CLLocationCoordinate2D coord1 = AMapCoordinateConvert(CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]), AMapCoordinateTypeGPS);
                    coords[i] = coord1;
                }
                
                [self showLBSForCoords:coords count:self.lbsCoordinates.count];
                
                if (coords) {
                    free(coords);
                }
            }
            
        } else {
            [self showInfoHUDView:@"无历史基站点"];
        }
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
    }];
}

- (void)initRoute {
    _duration = 4;
    coords = malloc(_coordinates.count * sizeof(CLLocationCoordinate2D));
    for (NSInteger i = 0; i < _coordinates.count; i++) {
        NSArray *coordArrTotal = [_coordinates[i] componentsSeparatedByString:@","];
        CLLocationCoordinate2D coord1 = AMapCoordinateConvert(CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]), AMapCoordinateTypeGPS);
        coords[i] = coord1;
    }
    
    [self showRouteForCoords:coords count:_coordinates.count];
    _route = [MAPolyline polylineWithCoordinates:coords count:_coordinates.count];
    [self.mapView addOverlay:_route];
    
    _annotation = [[MAAnimatedAnnotation alloc] init];
    _annotation.coordinate = coords[0];
    _annotation.title = @"Car";
    
    [self.mapView addAnnotation:_annotation];
}

- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count {
    _routeAnno = [NSMutableArray array];
    for (int i = 0 ; i < count; i++) {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = coords[i];
        if (i == 0) {
            a.title = @"startPoint";
        }else if(i == count - 1){
            a.title = @"endPoint";
        }else{
            a.title = @"route";
        }
        [_routeAnno addObject:a];
    }
    [self.mapView addAnnotations:@[_routeAnno.firstObject,_routeAnno.lastObject]];
    [self.mapView showAnnotations:_routeAnno animated:NO];
}

- (void)showLBSForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count {
    _lbsAnno = [NSMutableArray array];
    for (int i = 0 ; i < count; i++) {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = coords[i];
        a.title = @"lbsPoint";
        [_lbsAnno addObject:a];
    }
    [self.mapView addAnnotations:_lbsAnno];
    [self.mapView showAnnotations:_lbsAnno animated:NO];
}

- (void)bindUI {
    if (_track) {
        @weakify(self);
        [[self.timeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
            @strongify(self);
            [self dateSelect];
        }];
    } else {
        @weakify(self);
        [[self.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
            @strongify(self);
            [self locationClick];
        }];
        
        [[self.time rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
            @strongify(self);
            [self timeSelect];
        }];
        
        [[self.refreshBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
            @strongify(self);
            [self rotation];
        }];
    }
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

#pragma mark -
#pragma mark - 事件响应

- (void)playMove {
    if (_coordinates.count > 1) {
        _annotation.coordinate = coords[0];
        [self.mapView showAnnotations:_routeAnno animated:NO];
        MAAnimatedAnnotation *anno = self.annotation;
        [anno addMoveAnimationWithKeyCoordinates:coords count:_coordinates.count withDuration:_duration withName:nil completeCallback:nil];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(movingStop) userInfo:nil repeats:NO];
        self.customNavBar.rightButton.enabled = NO;
        self.customNavBar.rightButton.alpha = 0.4;
    }
}

- (void)movingStop {
    [_timer invalidate];
    _timer = nil;
    self.customNavBar.rightButton.enabled = YES;
    self.customNavBar.rightButton.alpha = 1.0;
}

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
    [_time setTitle:[NSString stringWithFormat:@"%ld",(long)_timeCount] forState:UIControlStateNormal];
}

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
    [self.mapView removeAnnotation:_customAnnotation];
    [self getLocationInfo];
}

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

/** 选择日期 */
- (void)dateSelect {
    WSYTimeSelectViewController *vc = [WSYTimeSelectViewController new];
    vc.delegateSignal = [RACSubject subject];
     @weakify(self);
    [vc.delegateSignal subscribeNext:^(NSString *str){
        @strongify(self);
        NSString *startStr = [NSString stringWithFormat:@"%@ 00:00:00",str];
        NSString *endStr = [NSString stringWithFormat:@"%@ 23:59:59",str];
        self.startTime = [NSMutableString stringWithString:startStr];
        self.endTime = [NSMutableString stringWithString:endStr];
        [self.mapView removeAnnotation:self.annotation];
        [self.mapView removeAnnotations:self.routeAnno];
        [self.mapView removeOverlay:self.route];
        [self.mapView removeAnnotations:self.lbsAnno];
        [self.coordinates removeAllObjects];
        [self.lbsCoordinates removeAllObjects];
        self.customNavBar.rightButton.enabled = YES;
        self.customNavBar.rightButton.alpha = 1.0;
        [self getTrackInfo];
    }];
    for(MAAnnotationMoveAnimation *animation in [self.annotation allMoveAnimations]) {
        [animation cancel];
    }
    if (self.coordinates.count > 0) {
        self.annotation.movingDirection = 0;
        self.annotation.coordinate = coords[0];
        [self movingStop];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

/** 定位 */
- (void)locationClick {
    @weakify(self);
    [[WSYPrivacyPermission sharedInstance]accessPrivacyPermissionWithType:PrivacyPermissionTypeLocation completion:^(BOOL response, PrivacyPermissionAuthorizationStatus status) {
        if (response == YES) {
            @strongify(self);
            self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            [self.mapView setZoomLevel:18];
            self.locationBtn.enabled = NO;
            NSDictionary *parameters = @{@"MemberID":self.memberID,@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID]};
            [WSYNetworking handLocationWithParameters:parameters success:^(id response){
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

- (void)timeStop {
    [_timer invalidate];
    [_countTimer invalidate];
    _countTimer = nil;
    _timer = nil;
}

#pragma mark -
#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:(id)overlay];
        polylineView.lineWidth   = 5.f;
        polylineView.strokeImage = [UIImage imageNamed:@"M_arrowTexture"];
        return polylineView;
    }
    return nil;
}

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
    } else if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        NSString *pointReuseIndetifier = @"myReuseIndetifier";
        MAAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:pointReuseIndetifier];
        }
        if ([annotation.title isEqualToString:@"Car"]) {
            UIImage *imge  =  [UIImage imageNamed:@"M_userPosition"];
            annotationView.image =  imge;
            CGPoint centerPoint = CGPointZero;
            [annotationView setCenterOffset:centerPoint];
            
        } else if ([annotation.title isEqualToString:@"route"]) {
            annotationView.image = nil;
        } else if ([annotation.title isEqualToString:@"lbsPoint"]) {
            annotationView.image = [UIImage imageNamed:@"M_trackingPoints"];
        } else if ([annotation.title isEqualToString:@"startPoint"]) {
            annotationView.image = [UIImage imageNamed:@"M_startPoint"];
        } else if ([annotation.title isEqualToString:@"endPoint"]) {
            annotationView.image = [UIImage imageNamed:@"M_endPoint"];
        } else {
            annotationView.image = [UIImage imageNamed:@"M_blue"];
        }
        //
        //        annotationView.canShowCallout               = YES;
        //        annotationView.draggable                    = NO;
        //        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
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
        calloutAnnotation.memberID = self.memberID;
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

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
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
#pragma mark - 懒加载

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:(CGRect){0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight}];
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
        [_timeBtn setImage:[UIImage imageNamed:@"M_time"] forState:UIControlStateNormal];
        _timeBtn.layer.shadowOffset = CGSizeMake(0, 5);
        _timeBtn.layer.shadowOpacity = 0.9;
        _timeBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _timeBtn;
}

- (UIButton *)time {
    if (!_time) {
        _time = [UIButton buttonWithType:UIButtonTypeCustom];
        _time.backgroundColor = [UIColor whiteColor];
        [_time setTitleColor:kThemeColor forState:UIControlStateNormal];
        _time.layer.cornerRadius = 20.0f;
        _time.layer.shadowOffset = CGSizeMake(0, 5);
        _time.layer.shadowOpacity = 0.9;
        _time.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _time;
}

@end
