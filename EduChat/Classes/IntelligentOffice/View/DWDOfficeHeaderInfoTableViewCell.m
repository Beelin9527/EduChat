//
//  DWDOfficeHeaderInfoTableViewCell.m
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDOfficeHeaderInfoTableViewCell.h"

@implementation DWDOfficeHeaderInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarImv.layer.masksToBounds = YES;
    self.avatarImv.layer.cornerRadius = 30;
    
    _nickname.text = [DWDCustInfo shared].custNickname;
    _detailLab.text = @"您好，愉快开启智能移动办公吧！";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
