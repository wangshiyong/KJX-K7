//
//  WSYTimeSelectViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/14.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTimeSelectViewController.h"
#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSYTimeSelectViewController()<FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *images;
@property (strong, nonatomic) NSCalendar *gregorianCalendar;

@end

NS_ASSUME_NONNULL_END

@implementation WSYTimeSelectViewController

#pragma mark - Life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.title = @"FSCalendar";
//        self.images = @{@"2017/10/04":[UIImage imageNamed:@"icon_cat"],
//                        @"2017/10/05":[UIImage imageNamed:@"icon_footprint"],
//                        @"2017/10/12":[UIImage imageNamed:@"icon_cat"],
//                        @"2017/10/10":[UIImage imageNamed:@"icon_footprint"]};
        self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight - kNavHeight)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = FSCalendarScrollDirectionHorizontal;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
    
    [view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.title = @"选择日期";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    // [self.calendar selectDate:[self.dateFormatter dateFromString:@"2016/02/03"]];
    
    
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     [self.calendar setScope:FSCalendarScopeWeek animated:YES];
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     [self.calendar setScope:FSCalendarScopeMonth animated:YES];
//     });
//     });
    
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark -
#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSLog(@"should select date %@",[self.dateFormatter stringFromDate:date]);
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    if (self.delegateSignal) {
        [self.delegateSignal sendNext:[self.dateFormatter stringFromDate:date]];
    }
    
//    if (self.NextViewControllerBlock) {
//        self.NextViewControllerBlock([self.dateFormatter stringFromDate:date]);
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    NSLog(@"did change to page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark -
#pragma mark - <FSCalendarDataSource>

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    if (self.num == 1) {
        return [self.dateFormatter dateFromString:self.startTimeStr];
    }
    return [self.dateFormatter dateFromString:@"2018-08-01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    if (self.num == 2) {
        return [self.dateFormatter dateFromString:self.endTimeStr];
    }
    NSDate *currentDate = [NSDate date];
    return currentDate;
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date {
    return [self.gregorianCalendar isDateInToday:date] ? @"今" : nil;
}

- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date {
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return self.images[dateString];
}

@end
