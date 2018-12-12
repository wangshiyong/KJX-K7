//
//  WSYContactsViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/5.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYContactsViewController.h"
// Controllers

// Models
#import "WSYContactsModel.h"
// Views
#import "WSYContactsCell.h"
// Vendors

// Categories

// Others


@interface WSYContactsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL ableEdit;
@property (nonatomic, strong) NSMutableArray *nameArray;
@property (nonatomic, strong) NSMutableArray *phoneArray;

@end

@implementation WSYContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"紧急联系人";
    [self.customNavBar wr_setRightButtonWithTitle:@"编辑" titleColor:kThemeColor];
    @weakify(self);
    self.customNavBar.onClickRightButton = ^{
        @strongify(self);
        self.ableEdit = !self.ableEdit;
        if (self.ableEdit) {
            [self.customNavBar wr_setRightButtonWithTitle:@"更新" titleColor:kThemeColor];
            self.ableEdit = YES;
        } else {
            [self.customNavBar wr_setRightButtonWithTitle:@"编辑" titleColor:kThemeColor];
            [self saveSOS];
        }
    };
    [self.view addSubview:self.tableView];
    
    [self showLoadHUD];
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [RACObserve(self, ableEdit) subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法

- (void)loadData {
    _nameArray = [NSMutableArray array];
    _phoneArray = [NSMutableArray array];
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID]};
    [WSYNetworking getSOSWithParameters:parameters success:^(id response){
        @strongify(self);
        [self hideLoadHUD];
        WSYContactsModel *model = [WSYContactsModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            for (WSYContactsData *data in model.Data){
                if ([data.contact wsy_isNull]) {
                    [self.nameArray addObject:@""];
                } else {
                    [self.nameArray addObject:data.contact];
                }
                
                if ([data.phone wsy_isNull]) {
                    [self.phoneArray addObject:@""];
                } else {
                    [self.phoneArray addObject:data.phone];
                }
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
    } failure:^(NSError *error){
        @strongify(self);
        [self hideLoadHUD];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark -
#pragma mark - 事件响应

- (void)saveSOS {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    alert.customViewColor = [UIColor redColor];
    for (NSInteger i = 0; i < 3; i++) {
        if ([_phoneArray[i] length] < 11 && [_phoneArray[i] length] > 0) {
            [alert showError:@"请输入正确的电话号码" subTitle:nil closeButtonTitle:nil duration:1.0f];
            [self.customNavBar wr_setRightButtonWithTitle:@"更新" titleColor:kThemeColor];
            self.ableEdit = YES;
            return;
        }
    }
    NSString *phoneSos = @"";
    for (NSInteger i = 0; i < 3; i++) {
        phoneSos = [phoneSos stringByAppendingString:[NSString stringWithFormat:@",%@",_phoneArray[i]]];
    }

    NSString *nameSos = @"";
    for (NSInteger i = 0; i< 3 ; i++) {
        nameSos = [nameSos stringByAppendingString:[NSString stringWithFormat:@",%@",_nameArray[i]]];
    }

    nameSos = [nameSos substringFromIndex:1];
    phoneSos = [phoneSos substringFromIndex:1];
    
    [self showHUDView:@"更新中..."];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSDictionary *parameters = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"SOSContactPhone":phoneSos};
    [WSYNetworking setSOSPhoneWithParameters:parameters success:^(id response){
        WSYContactsModel *model = [WSYContactsModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            [alert showSuccess:@"更新成功" subTitle:nil closeButtonTitle:nil duration:1.0f];
        } else {
            [alert showError:@"更新失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
        }
        dispatch_group_leave(group);
    } failure:^(NSError *error){
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    NSDictionary *parameterss = @{@"TouristTeamID":[WSYUserDataTool getUserData:TEAM_ID],@"SOSContactName":nameSos};
    [WSYNetworking setSOSNameWithParameters:parameterss success:^(id response){
        dispatch_group_leave(group);
    } failure:^(NSError *error){
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self hideLoadHUD];
    });
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.phone.text = _phoneArray[indexPath.row];
    cell.name.text = _nameArray[indexPath.row];
    
    if (self.ableEdit) {
        cell.name.enabled = YES;
        cell.phone.enabled = YES;
    } else {
        cell.name.enabled = NO;
        cell.phone.enabled = NO;
    }
    
    @weakify(self);
    [[RACObserve(cell.phone, text) takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.phoneArray removeObjectAtIndex:indexPath.row];
        if([x length] > 15){
            cell.phone.text = [NSString stringWithFormat:@"%@",[x substringToIndex:15]];
        }
        [self.phoneArray insertObject:cell.phone.text atIndex:indexPath.row];
    }];

    [[RACObserve(cell.name, text) takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.nameArray removeObjectAtIndex:indexPath.row];
        [self.nameArray insertObject:cell.name.text atIndex:indexPath.row];
        if([x length] > 11){
            cell.name.text = [NSString stringWithFormat:@"%@",[x substringToIndex:11]];
        }
    }];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight} style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 110;
    }
    return _tableView;
}

@end
