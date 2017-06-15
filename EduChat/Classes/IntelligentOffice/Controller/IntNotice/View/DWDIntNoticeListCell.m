//
//  DWDIntNoticeListCell.m
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeListCell.h"

#import "DWDIntNoticeListModel.h"
@interface DWDIntNoticeListCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@end

@implementation DWDIntNoticeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter
- (void)setModel:(DWDIntNoticeListModel *)model{
    _model = model;
    
    _titleLab.text = _model.title;
    _detailLab.text = _model.orgNm;
    _timeLab.text = _model.creatTime;
    
}
@end
