//
//  WSYItineraryCell.h
//  Travel_Card
//
//  Created by 王世勇 on 2018/8/31.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@class WSYItineraryData;

@interface WSYItineraryCell : MGSwipeTableCell

@property (nonatomic, strong) WSYItineraryData *data;

@end
