//
//  WSYContactsCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYContactsCell.h"

@interface WSYBaseTextField : UITextField

@end

@implementation WSYBaseTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end

@interface WSYContactsCell()

@property (nonatomic, strong) UIView *contactsView;
@property (nonatomic, strong) UIView *nameLine;
@property (nonatomic, strong) UIView *phoneLine;
@property (nonatomic, strong) UIImageView *image;

@end

@implementation WSYContactsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.contactsView = [[UIView alloc]init];
        self.contactsView.backgroundColor = [UIColor whiteColor];
        
        self.name                    = [[UITextField alloc]init];
        self.name.placeholder        = @"姓名";
        self.name.textColor          = kThemeTextColor;
        self.name.clearButtonMode    = UITextFieldViewModeWhileEditing;
        
        self.phone                   = [[WSYBaseTextField alloc]init];
        self.phone.placeholder       = @"电话号码";
        self.phone.textColor         = kThemeTextColor;
        self.phone.keyboardType      = UIKeyboardTypeNumberPad;
        self.phone.clearButtonMode   = UITextFieldViewModeWhileEditing;
        
        self.image                   = [[UIImageView alloc]init];
        
        self.nameLine                = [[UIView alloc]init];
        self.nameLine.backgroundColor = WSYColor(225, 225, 225);

        self.phoneLine               = [[UIView alloc]init];
        self.phoneLine.backgroundColor = WSYColor(225, 225, 225);
        
        [self.contentView addSubview:self.contactsView];
        [self.contentView addSubview:self.image];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.phone];
        [self.contentView addSubview:self.nameLine];
        [self.contentView addSubview:self.phoneLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contactsView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPHONE_5) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
        } else {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(20, 0, 0, 0));
        }
    }];
    
    [self.image mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.contactsView);
        make.left.equalTo(self.contactsView).offset(20);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    [self.image wsy_rectWithColor:[UIColor whiteColor]];
    self.image.image  = [UIImage imageNamed:@"M_contact"];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.contactsView.mas_top).offset(8);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(30);
    }];
    
    [self.nameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.name.mas_bottom);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(1);
    }];

    [self.phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(30);
    }];
    
    [self.phoneLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.phone.mas_bottom);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(1);
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
