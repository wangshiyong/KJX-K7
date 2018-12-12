//
//  WSYSettingViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYSettingViewController.h"

// Controllers
#import "WSYAboutViewController.h"
#import "WSYContactsViewController.h"
#import "WSYWorkModeViewController.h"
#import "WSYModifyPasswordViewController.h"
#import "WSYLoginViewController.h"
// Models

// Views

// Vendors
#import "JPUSHService.h"
// Categories

// Others

#define WSYCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

typedef NS_ENUM(NSInteger, WSYSettingSection) {
    WSYSettingSectionOne  = 0,
    WSYSettingSectiontwo  = 1,
    WSYSettingSectionthree     = 2,
};

@interface WSYSettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WSYSettingViewController

static NSInteger seq = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法

- (void)setUpUI {
    self.customNavBar.title = @"设置";

    [self.view addSubview:self.tableView];
}

#pragma mark -
#pragma mark - 事件响应

/** 清理缓存 */
- (void)cleanCaches:(NSIndexPath *)indexPath{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:@"确定" actionBlock:^(void) {
        [self showLoadHUD:@"清理中..."];
        NSString *path = WSYCachesPath;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            NSArray *childerFiles=[fileManager subpathsAtPath:path];
            for (NSString *fileName in childerFiles) {
                NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideLoadHUD];
            [self showSuccessHUD:@"清理完成"];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_clean"] color:kThemeColor title:@"清理缓存" subTitle:[NSString stringWithFormat:@"缓存大小为%.2fM,确定清理缓存？", [self getCashes]] closeButtonTitle:@"取消" duration:0.0f];
}

- (float)getCashes{
    NSString *path = WSYCachesPath;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fullPath];
        }
    }
    return folderSize;
}

- (float)fileSizeAtPath:(NSString *)path{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

/** 退出 */
- (void)logout {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    @weakify(self);
    [alert addButton:@"确定" actionBlock:^(void) {
        @strongify(self);
        [self showLoadHUD:@"退出中..."];
        NSDictionary *parameterss = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID]};
        [WSYNetworking logoutWithParameters:parameterss success:^(id response){
            @strongify(self);
            [self hideLoadHUD];
            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                NSLog(@"%ld====%@=====%ld",(long)iResCode,iAlias,(long)seq);
            } seq:[self seq]];
            if ([[WSYUserDataTool getUserData:ROOT_START]integerValue] == 1) {
                [WSYUserDataTool removeUserData:USER_LOGIN];
                [self dismissViewControllerAnimated:YES completion:^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = [WSYLoginViewController new];
                }];
            } else {
                self.tabBarController.selectedIndex = 0;
                [WSYNetworking cancelRequestWithURL:[NSString stringWithFormat:@"%@%@",kApiPrefix,kTeamLocation]];
                [WSYUserDataTool removeUserData:USER_LOGIN];
                WSYLoginViewController *vc = [WSYLoginViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:vc animated:YES completion:nil];
            }
        } failure:^(NSError *error){
            @strongify(self);
            [self hideLoadHUD];
            [self showErrorHUD:@"退出失败"];
        }];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_logout"] color:kThemeColor title:@"确定退出登录?" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
}

- (NSInteger)seq {
    return ++ seq;
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : section == 1 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.section) {
        case WSYSettingSectionOne:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"紧急联系人";
                cell.imageView.image = [UIImage imageNamed:@"S_sos"];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"工作模式";
                cell.imageView.image = [UIImage imageNamed:@"S_workMode"];
            } else {
                cell.textLabel.text = @"修改密码";
                cell.imageView.image = [UIImage imageNamed:@"S_modify"];
            }
            break;

        case WSYSettingSectiontwo:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"清理缓存";
                cell.imageView.image = [UIImage imageNamed:@"S_clear"];
            } else {
                cell.textLabel.text = @"关于";
                cell.imageView.image = [UIImage imageNamed:@"S_about"];
            }
            break;

        case WSYSettingSectionthree:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"退出登录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
            break;

        default:
            break;
    }
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == WSYSettingSectiontwo) {
        return 20;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case WSYSettingSectionOne:
            if (indexPath.row == 0) {
                WSYContactsViewController *vc = [WSYContactsViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 1) {
                WSYWorkModeViewController *vc = [WSYWorkModeViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                WSYModifyPasswordViewController *vc = [WSYModifyPasswordViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case WSYSettingSectiontwo:
            if (indexPath.row == 0) {
                if (!([[NSString stringWithFormat:@"%.2f",[self getCashes]] isEqualToString:@"0.00"])) {
                    [self cleanCaches:indexPath];
                }
            } else {
                WSYAboutViewController *vc = [WSYAboutViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }

            break;
        case WSYSettingSectionthree:
            [self logout];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight} style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _tableView;
    
}

@end
