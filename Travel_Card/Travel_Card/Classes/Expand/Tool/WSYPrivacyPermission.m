//
//  WSYPrivacyPermission.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/4.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYPrivacyPermission.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

static WSYPrivacyPermission *_instance = nil;
static NSInteger const PrivacyPermissionTypeLocationDistanceFilter = 10; //`Positioning accuracy` -> 定位精度

@implementation WSYPrivacyPermission

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return _instance;
}

- (void)accessPrivacyPermissionWithType:(PrivacyPermissionType)type completion:(void(^)(BOOL response,PrivacyPermissionAuthorizationStatus status))completion API_AVAILABLE(ios(9.0)){
    switch (type) {
        case PrivacyPermissionTypePhoto: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusDenied) {
                    completion(NO,PrivacyPermissionAuthorizationStatusDenied);
                } else if (status == PHAuthorizationStatusNotDetermined) {
                    completion(NO,PrivacyPermissionAuthorizationStatusNotDetermined);
                } else if (status == PHAuthorizationStatusRestricted) {
                    completion(NO,PrivacyPermissionAuthorizationStatusRestricted);
                } else if (status == PHAuthorizationStatusAuthorized) {
                    completion(YES,PrivacyPermissionAuthorizationStatusAuthorized);
                }
            }];
        }break;
            
        case PrivacyPermissionTypeCamera: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (granted) {
                    completion(YES,PrivacyPermissionAuthorizationStatusAuthorized);
                } else {
                    if (status == AVAuthorizationStatusDenied) {
                        completion(NO,PrivacyPermissionAuthorizationStatusDenied);
                    } else if (status == AVAuthorizationStatusNotDetermined) {
                        completion(NO,PrivacyPermissionAuthorizationStatusNotDetermined);
                    } else if (status == AVAuthorizationStatusRestricted) {
                        completion(NO,PrivacyPermissionAuthorizationStatusRestricted);
                    }
                }
            }];
        }break;
            
        case PrivacyPermissionTypeLocation: {
            if ([CLLocationManager locationServicesEnabled]) {
                CLLocationManager *locationManager = [[CLLocationManager alloc]init];
                [locationManager requestAlwaysAuthorization];
                [locationManager requestWhenInUseAuthorization];
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                locationManager.distanceFilter = PrivacyPermissionTypeLocationDistanceFilter;
                [locationManager startUpdatingLocation];
            }
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                completion(YES,PrivacyPermissionAuthorizationStatusLocationAlways);
            } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                completion(YES,PrivacyPermissionAuthorizationStatusLocationWhenInUse);
            } else if (status == kCLAuthorizationStatusDenied) {
                completion(NO,PrivacyPermissionAuthorizationStatusDenied);
            } else if (status == kCLAuthorizationStatusNotDetermined) {
                completion(NO,PrivacyPermissionAuthorizationStatusNotDetermined);
            } else if (status == kCLAuthorizationStatusRestricted) {
                completion(NO,PrivacyPermissionAuthorizationStatusRestricted);
            }
        }break;
            
        default:
            break;
    }
}

@end
