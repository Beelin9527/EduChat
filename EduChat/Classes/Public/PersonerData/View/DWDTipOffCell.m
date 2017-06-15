//
//  DWDTipOffCell.m
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTipOffCell.h"

@interface DWDTipOffCell ()

{
    UIButton *_selectBtn;
    UILabel *_titleLbl;
}

@end

@implementation DWDTipOffCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    _selectBtn = [[UIButton alloc] init];
    _selectBtn.frame = CGRectMake(6.5f, 10.0f, 22.0f, 22.0f);
    [_selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"] forState:UIControlStateNormal];
    [_selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"] forState:UIControlStateSelected];
    _selectBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:_selectBtn];
    
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.frame = CGRectMake(_selectBtn.x + _selectBtn.w + 6.5f, 0, DWDScreenW - 80.0f, 44.0f);
    _titleLbl.textColor = DWDColorBody;
    _titleLbl.font = DWDFontBody;
    [self.contentView addSubview:_titleLbl];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLbl.text = title;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _selectBtn.selected = YES;
    }else {
        _selectBtn.selected = NO;
    }
}

@end
