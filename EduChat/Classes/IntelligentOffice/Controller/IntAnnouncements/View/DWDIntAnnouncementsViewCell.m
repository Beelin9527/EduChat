//
//  DWDIntAnnouncementsViewCell.m
//  EduChat
//
//  Created by Catskiy on 2016/12/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntAnnouncementsViewCell.h"

@interface DWDIntAnnouncementsViewCell()

/** 通知名称 */
@property (nonatomic, strong) UILabel *announcementsNameLabel;

/** 通知内容 */
@property (nonatomic, strong) UILabel *announcementsContentLabel;

/** 通知时间 */
@property (nonatomic, strong) UILabel *announcementsTimeLabel;


@end

@implementation DWDIntAnnouncementsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self.contentView addSubview:self.announcementsNameLabel];
    
    [self.contentView addSubview:self.announcementsContentLabel];
    
    [self.contentView addSubview:self.announcementsTimeLabel];
}

#pragma mark - Getter/Setter
-(UILabel *)announcementsNameLabel {
    if (!_announcementsNameLabel) {
        _announcementsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
        _announcementsNameLabel.text = @"元旦放假通知安排";
        _announcementsNameLabel.textColor = DWDRGBColor(34, 34, 34);
        _announcementsNameLabel.font = [UIFont systemFontOfSize:17.0f];
        _announcementsNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _announcementsNameLabel;
}

-(UILabel *)announcementsContentLabel {
    if (!_announcementsContentLabel) {
        _announcementsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 30)];
        _announcementsContentLabel.text = @"教导处";
        _announcementsContentLabel.textColor = DWDRGBColor(153, 153, 153);
        _announcementsContentLabel.font = [UIFont systemFontOfSize:15.0f];
        _announcementsContentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _announcementsContentLabel;
}

-(UILabel *)announcementsTimeLabel {
    if (!_announcementsTimeLabel) {
        _announcementsTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 30, 200, 30)];
        _announcementsTimeLabel.text = @"12-28 09:00";
        _announcementsTimeLabel.textColor = DWDRGBColor(153, 153, 153);
        _announcementsTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _announcementsTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _announcementsTimeLabel;
}

@end
