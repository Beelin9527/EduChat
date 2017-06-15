//
//  DWDRelayOnChatRentCell.m
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRelayOnChatRentCell.h"
#import <Masonry.h>

@interface DWDRelayOnChatRentCell ()

@end

@implementation DWDRelayOnChatRentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *imageView = [UIImageView new];
        _iconView = imageView;
        [self.contentView addSubview:imageView];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UIView *seperator = [UIView new];
        seperator.backgroundColor = DWDColorBackgroud;
        [self.contentView addSubview:seperator];
        
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
            make.centerY.equalTo(self.centerY);
        }];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.right).offset(10);
            make.centerY.equalTo(self.centerY);
        }];
        
        [seperator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@2);
            make.right.equalTo(self.contentView.right);
            make.bottom.equalTo(self.contentView.bottom);
            make.height.equalTo(@1);
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
