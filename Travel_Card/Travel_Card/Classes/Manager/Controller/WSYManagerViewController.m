//
//  WSYManagerViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYManagerViewController.h"

// Controllers
#import "WSYLocationViewController.h"
// Models
#import "WSYMemberListModel.h"
// Views
#import "WSYManagerCell.h"
// Vendors

// Categories
#import "UITableView+FDTemplateLayoutCell.h"

// Others

@interface WSYManagerViewController ()<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
/** 设备数组 */
@property (nonatomic, strong) NSMutableArray *array;
/** 搜索数组 */
@property (nonatomic, strong) NSMutableArray *searchDataSource;
/** 滚回顶部 */
@property (nonatomic, strong) UIButton *scrollBtn;

@end

@implementation WSYManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    [self refresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 私有方法

- (void)refresh {
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData {
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID]};
    [WSYNetworking getTouristWithParameters:parameters success:^(id response){
        @strongify(self);
        WSYMemberListModel *model = [WSYMemberListModel mj_objectWithKeyValues:response];
        if ([model.code integerValue] == 0) {
            if (model.Data.count == 0) {
                self.customNavBar.rightButton.enabled = NO;
                self.customNavBar.rightButton.alpha = 0.4;
                [self.array removeAllObjects];
                [self.tableView reloadEmptyDataSet];
            } else {
                self.customNavBar.rightButton.enabled = YES;
                self.customNavBar.rightButton.alpha = 1.0;
                self.array = [NSMutableArray arrayWithArray:model.Data];
                [self.tableView reloadData];
            }
            [self.tableView.mj_header endRefreshing];
        }
    } failure:^(NSError *error){
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)setUpUI {
    self.customNavBar.title = @"游客管理";
    [self.customNavBar wr_setRightButtonWithTitle:@"解散" titleColor:kThemeColor];
    @weakify(self);
    [self.customNavBar setOnClickRightButton:^{
        @strongify(self);
        [self deleteList];
    }];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[WSYManagerCell class] forCellReuseIdentifier:@"WSYManagerCell"];
    //防止搜索框在下一界面显示
    self.definesPresentationContext = YES;
    
    [self.view addSubview:self.scrollBtn];
    [[self.scrollBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

#pragma mark -
#pragma mark - 事件响应

- (void)callPhone:(NSString*)phoneStr {
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneStr]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:telURL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:telURL];
    }
}

- (void)deleteList {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert setHorizontalButtons:YES];
    @weakify(self);
    [alert addButton:@"确定" actionBlock:^(void) {
        [self showLoadHUD:@"解散中..."];
        NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID]};
        [WSYNetworking deleteTouristWithParameters:parameters success:^(id response){
            @strongify(self);
            [self hideLoadHUD];
            WSYMemberListModel *model = [WSYMemberListModel mj_objectWithKeyValues:response];
            if ([model.code integerValue] == 0) {
                self.customNavBar.rightButton.enabled = NO;
                self.customNavBar.rightButton.alpha = 0.4;
                [self showSuccessHUDView:@"解散成功"];
            } else {
                [self showErrorHUDView:@"解散失败"];
            }
        }failure:^(NSError *error){
            @strongify(self);
            [self hideLoadHUD];
        }];
    }];
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    
    [alert showCustom:[UIImage imageNamed:@"M_disband"] color:kThemeColor title:@"解散团" subTitle:@"确定解散当前团?" closeButtonTitle:@"取消" duration:0.0f];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollBtn.hidden = (scrollView.contentOffset.y > kScreenHeight) ? NO : YES;//判断回到顶部按钮是否隐藏
    self.scrollBtn.frame  = (CGRect){kScreenWidth - 110, kScreenHeight - (IS_IPHONE_X ? 144 : 110), 40, 40};
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_searchController.active) {
        return _array.count;
    } else {
        return _searchDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"WSYManagerCell";
    WSYManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[WSYManagerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    
    @weakify(self);
    [[[cell.phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
        @strongify(self);
        [self callPhone:cell.data.phone];
    }];
    
    [[[cell.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
        @strongify(self);
        WSYLocationViewController *vc = [WSYLocationViewController new];
        vc.memberID = cell.data.memberID;
        vc.str = cell.data.codeMachine;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[[cell.trackBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
        @strongify(self);
        WSYLocationViewController *vc = [WSYLocationViewController new];
        vc.memberID = cell.data.memberID;
        vc.terminalID = cell.data.terminalID;
        vc.track = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return cell;
}

- (void)configureCell:(WSYManagerCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!_searchController.active) {
        cell.data = _array[indexPath.row];
    } else {
        cell.data = _searchDataSource[indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"WSYManagerCell" cacheByKey:indexPath configuration:^(WSYManagerCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

#pragma mark -
#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _array;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.codeMachine contains [cd]%@ ", searchController.searchBar.text];
        NSArray *array = [NSArray arrayWithArray:_array];
        _searchDataSource = (NSMutableArray *)[array filteredArrayUsingPredicate:predicate];
        if (_searchDataSource.count == 0) {
            [self.tableView reloadEmptyDataSet];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 删除操作
#pragma mark - MGSwipeTableCellDelegate

- (NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    swipeSettings.transition = MGSwipeTransitionClipCenter;
    expansionSettings.buttonIndex = 0;
    
    CGFloat padding = 20;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        return @[[MGSwipeButton buttonWithTitle:@"左滑删除" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {

            return YES;
        }]];
    } else {
        expansionSettings.fillOnTrigger = YES;
        @weakify(self);
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            @strongify(self);
            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
            WSYMemberListData *data = nil;
            if (!self.searchController.active) {
                data = self.array[indexPath.row];
            } else {
                data = self.searchDataSource[indexPath.row];
            }
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            [alert setHorizontalButtons:YES];

            [alert addButton:@"确定" actionBlock:^(void) {
                [self showLoadHUD:@"删除中..."];
                NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID],@"MemberID":data.memberID};
                [WSYNetworking deleteTouristWithParameters:parameters success:^(id response){
                    @strongify(self);
                    [self hideLoadHUD];
                    WSYMemberListModel *model = [WSYMemberListModel mj_objectWithKeyValues:response];
                    if ([model.code integerValue] == 0) {
                        if (!self.searchController.active) {
                            [self.array removeObjectAtIndex:indexPath.row];//移除数据源的数据
                            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                            [self showSuccessHUDView:@"删除成功"];
                            if (self.array.count == 0) {
                                self.customNavBar.rightButton.enabled = NO;
                                self.customNavBar.rightButton.alpha = 0.4;
                                [self.tableView reloadEmptyDataSet];
                            }
                        } else {
                            self.searchController.active = false;
                            [self showSuccessHUDView:@"删除成功"];
                            [self refresh];
                        }
                    } else {
                        [self showErrorHUDView:@"删除失败"];
                    }
                }failure:^(NSError *error){
                    @strongify(self);
                    [self hideLoadHUD];
                }];
            }];


            alert.completeButtonFormatBlock = ^NSDictionary* (void) {
                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
                return buttonConfig;
            };


            [alert showCustom:[UIImage imageNamed:@"I_del1"] color:kThemeColor title:@"行程删除" subTitle:@"确定删除当前行程信息？" closeButtonTitle:@"取消" duration:0.0f];
            return YES;
        }];
        return @[trash];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped accessory button");
}

#pragma mark -
#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (_searchController.active) {
        text = @"未找到结果";
    }else{
        text = @"没有游客设备";
    }
    font = WSYFont(17);
    textColor = [UIColor grayColor];
    
    if (!text) {
        return nil;
    }
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if (!_searchController.active) {
        return [UIImage imageNamed:@"M_device"];
    }else{
        return [UIImage imageNamed:@"M_search"];
    }
}

#pragma mark -
#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight - kTabBarHeight} style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iOS11Later ? 44 : 34 )];
        [header addSubview:self.searchController.searchBar];
        _tableView.tableHeaderView = header;
    }
    return _tableView;
}

- (UISearchController*)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.dimsBackgroundDuringPresentation = NO;
        [_searchController.searchBar sizeToFit];
        _searchController.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
        _searchController.searchResultsUpdater = self;
        //searchBar不上移
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchBar.layer.borderWidth = 1;
        _searchController.searchBar.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        
        [_searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
        _searchController.searchBar.placeholder = @"设备号";
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

- (UIButton *)scrollBtn {
    if(!_scrollBtn){
        _scrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scrollBtn setBackgroundImage:[UIImage imageNamed:@"M_goBack"] forState:UIControlStateNormal];
        _scrollBtn.layer.shadowOffset =  CGSizeMake(0, 5);
        _scrollBtn.layer.shadowOpacity = 0.9;
        _scrollBtn.layer.shadowColor = [UIColor wsy_colorWithHexString:@"bababa"].CGColor;
    }
    return _scrollBtn;
}

@end
