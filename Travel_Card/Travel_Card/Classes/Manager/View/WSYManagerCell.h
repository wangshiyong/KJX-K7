//
//  WSYManagerCell.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/9/3.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSYMemberListData;

@interface WSYManagerCell : MGSwipeTableCell

@property (nonatomic, strong) UIButton *phoneBtn;
@property (nonatomic, strong) UIButton *trackBtn;
@property (nonatomic, strong) UIButton *locationBtn;

@property (nonatomic,strong) WSYMemberListData *data;

@end
