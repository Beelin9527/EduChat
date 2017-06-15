//
//  DWDContactListCell.m
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactListCell.h"

@implementation DWDContactListCell

- (void)awakeFromNib {
    // Initializati
    [super awakeFromNib];
    
    _roleIcon = [[UIImageView alloc] init];
    
    [self.contentView addSubview:_roleIcon];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_nameLab sizeToFit];
    _roleIcon.frame = CGRectMake(_nameLab.x + _nameLab.w + 10, _nameLab.y + 3, 25, 14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
