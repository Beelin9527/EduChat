//
//  DWDRelayOnChatChooseContactCell.m
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRelayOnChatChooseContactCell.h"
#import <Masonry.h>

@interface DWDRelayOnChatChooseContactCell ()


@end

@implementation DWDRelayOnChatChooseContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *selectImageView = [UIImageView new];
        selectImageView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
//        selectImageView.userInteractionEnabled = YES;
        
        _selectImageView = selectImageView;
        [self.contentView addSubview:selectImageView];
        
        UIImageView *iconView = [UIImageView new];
        _iconView = iconView;
        [self.contentView addSubview:iconView];
        
        UILabel *nameLabel = [UILabel new];
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        [selectImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(@15);
            make.height.equalTo(@15);
        }];
        
        [iconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(selectImageView.right).offset(10);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.right).offset(10);
            make.centerY.equalTo(self.centerY);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setMultSelect:(BOOL)multSelect{
    _multSelect = multSelect;
    if (_multSelect) {
        _selectImageView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
    }else{
        _selectImageView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
    }
}

@end
