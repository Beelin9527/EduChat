//
//  DWDPersonInfoSetCell.m
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPersonInfoSetCell.h"

@interface DWDPersonInfoSetCell ()

@end

@implementation DWDPersonInfoSetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.frame = CGRectMake(10.0f, 0, DWDScreenW * 0.5f, 44.0f);
    _titleLbl.textColor = DWDColorContent;
    _titleLbl.font = DWDFontContent;
    [self.contentView addSubview:_titleLbl];
}

- (void)setRightViewType:(DWDCellRightViewType)rightViewType
{
    _rightViewType = rightViewType;
    if (rightViewType == DWDCellRightViewTypeNone) {
        
        _arrowImgV.hidden = YES;
        _switchView.hidden = YES;
        
    }else if (rightViewType == DWDCellRightViewTypeSwitch) {
        
        _arrowImgV.hidden = YES;
        self.switchView.hidden = NO;
        
    }else if (rightViewType == DWDCellRightViewTypeArrow){
        
        _switchView.hidden = YES;
        self.arrowImgV.hidden = NO;
        
    }
}

- (UIImageView *)arrowImgV
{
    if (!_arrowImgV) {
        _arrowImgV = [[UIImageView alloc] init];
        _arrowImgV.frame = CGRectMake(DWDScreenW - 7.5f - 24.0f, 10.0f, 24.0f, 24.0f);
        _arrowImgV.contentMode = UIViewContentModeCenter;
        _arrowImgV.image = [UIImage imageNamed:@"ic_clickable_normal"];
        [self.contentView addSubview:_arrowImgV];
    }
    return _arrowImgV;
}

- (UISwitch *)switchView
{
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.frame = CGRectMake(DWDScreenW - 50.0f - 10.0f, 7.0f, 50.0f, 30.0f);
        [self.contentView addSubview:_switchView];
    }
    return _switchView;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
