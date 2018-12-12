//
//  WSYItineraryViewController.m
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/29.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "WSYItineraryViewController.h"
// Controllers

// Models
#import "WSYItineraryModel.h"
// Views
#import "WSYItineraryCell.h"
// Vendors

// Categories
#import "UITableView+FDTemplateLayoutCell.h"
// Others

@interface WSYItineraryViewController ()<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
/** 行程数组 */
@property (nonatomic, strong) NSMutableArray *array;
/** 滚回顶部 */
@property (nonatomic, strong) UIButton *scrollBtn;

@end

@implementation WSYItineraryViewController

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
    self.customNavBar.title = @"行程列表";
    [self.customNavBar wr_setRightButtonWithTitle:@"清空" titleColor:kThemeColor];
    @weakify(self);
    [self.customNavBar setOnClickRightButton:^{
        @strongify(self);
        [self delList];
    }];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[WSYItineraryCell class] forCellReuseIdentifier:@"WSYItineraryCell"];
    [self.view addSubview:self.scrollBtn];
    
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:RELEASE_SUCESSS_NOTICE object:nil]subscribeNext:^(id x){
        @strongify(self);
        self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadData];
        }];
        [self.tableView.mj_header beginRefreshing];
    }];
    
    [[self.scrollBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

- (void)loadData {
    NSMutableString *startTime = [NSMutableString stringWithString:[NSDate wsy_currentDateStringWithFormat:@"YYYY-MM-dd 00:00:00"]];
    NSMutableString *endTime = [NSMutableString stringWithString:[NSDate wsy_currentDateStringWithFormat:@"YYYY-MM-dd 23:59:59"]];
    @weakify(self);
    NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID], @"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"start":[NSDate wsy_getUTCFormateLocalDate:startTime],@"end":[NSDate wsy_getUTCFormateLocalDate:endTime]};
    [WSYNetworking getItineraryWithParameters:parameters success:^(id response){
        @strongify(self);
        WSYItineraryModel *model = [WSYItineraryModel mj_objectWithKeyValues:response];
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

#pragma mark -
#pragma mark - 事件响应

- (void)delList {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    @weakify(self);
    [alert setHorizontalButtons:YES];
    [alert addButton:@"确定" actionBlock:^(void) {
        @strongify(self);
        [self showLoadHUD:@"清空中..."];
        NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID], @"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID]};
        [WSYNetworking emptyItineraryWithParameters:parameters success:^(id response){
            @strongify(self);
            [self hideLoadHUD];
            WSYItineraryModel *model = [WSYItineraryModel mj_objectWithKeyValues:response];
            if ([model.code integerValue] == 0) {
                [self showSuccessHUDView:@"清除成功"];
                self.customNavBar.rightButton.enabled = NO;
                self.customNavBar.rightButton.alpha = 0.4;
                [self.array removeAllObjects];
                [self.tableView reloadData];
            } else {
                [self showErrorHUDView:@"清除失败"];
            }
        } failure:^(NSError *error){
            @strongify(self);
            [self hideLoadHUD];
        }];
    }];
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    
    [alert showCustom:[UIImage imageNamed:@"I_del1"] color:kThemeColor title:@"一键清空" subTitle:@"确定删除所有行程信息？" closeButtonTitle:@"取消" duration:0.0f];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"WSYItineraryCell";
    WSYItineraryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[WSYItineraryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(WSYItineraryCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.data = _array[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"WSYItineraryCell" cacheByKey:indexPath configuration:^(WSYItineraryCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
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
            WSYItineraryData *data = self.array[indexPath.row];
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            [alert setHorizontalButtons:YES];
            
            [alert addButton:@"确定" actionBlock:^(void) {
                [self showLoadHUD:@"删除中..."];
                NSDictionary *parameters = @{@"TouristTeamID": [WSYUserDataTool getUserData:TEAM_ID], @"TravelGencyID":[WSYUserDataTool getUserData:TRAVELGENCY_ID],@"TripID":data.itineraryID};
                [WSYNetworking deleteItineraryWithParameters:parameters success:^(id response){
                    @strongify(self);
                    [self hideLoadHUD];
                    WSYItineraryModel *model = [WSYItineraryModel mj_objectWithKeyValues:response];
                    if ([model.code integerValue] == 0) {
                        [self.array removeObjectAtIndex:indexPath.row];//移除数据源的数据
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [self showSuccessHUDView:@"删除成功"];
                        if (self.array.count == 0) {
                            self.customNavBar.rightButton.enabled = NO;
                            self.customNavBar.rightButton.alpha = 0.4;
                            [self.tableView reloadEmptyDataSet];
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
    text = @"没有行程信息";
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
    return [UIImage imageNamed:@"I_trip"];
}

#pragma mark -
#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
//    return -64;
//}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollBtn.hidden = (scrollView.contentOffset.y > kScreenHeight) ? NO : YES;//判断回到顶部按钮是否隐藏
    self.scrollBtn.frame  = (CGRect){kScreenWidth - 110, kScreenHeight - (IS_IPHONE_X ? 144 : 110), 40, 40};
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
    }
    return _tableView;
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
