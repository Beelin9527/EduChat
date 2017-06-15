//
//  DWDDetailToolCell.m
//  EduChat
//
//  Created by Gatlin on 16/8/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDDetailToolCell.h"
#import "DWDVisitStat.h"

#import <Masonry.h>
#define padding 15
@interface DWDDetailToolCell()
@property (nonatomic, strong) UIView *ToolView;
@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) UIButton *readBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *praiseBtn;
@end

@implementation DWDDetailToolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.ToolView];
    }
    return self;
}
+ (instancetype)initDetailToolCellWithTableView:(UITableView *)tableView
{
     NSString *toolCellId = @"toolCellId";
    DWDDetailToolCell *toolCell= [tableView dequeueReusableCellWithIdentifier:toolCellId];
    if (!toolCell) {
        toolCell = [[DWDDetailToolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toolCellId];
        toolCell.userInteractionEnabled = NO;
    }
    return toolCell;
}

#pragma mark - Setup
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ToolView.w / 3);
//        make.left.equalTo(self.ToolView).offset(10);
        make.top.mas_equalTo(33);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(padding);
    }];

    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ToolView.w / 3 * 2);
        make.top.mas_equalTo(33);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(padding);
    }];
    
    [self.readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.equalTo(self.line1.mas_centerY);
        make.right.equalTo(self.line1.mas_left).offset(-padding);
        make.height.mas_equalTo(30);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.line1.mas_right).offset(5);
        make.centerY.equalTo(self.line1.mas_centerY);
        make.right.equalTo(self.line2.mas_left).offset(-padding);
        make.height.mas_equalTo(30);
    }];
    
    [self.praiseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.line2.mas_left).offset(5);
        make.centerY.equalTo(self.line1.mas_centerY);
        make.right.equalTo(self.ToolView).offset(-padding);
        make.height.mas_equalTo(30);
    }];
    
}
#pragma mark - Setter
- (void)setVisitStat:(DWDVisitStat *)visitStat
{
    _visitStat = visitStat;
    
    [self.readBtn setTitle:[visitStat.readCnt stringValue] forState:UIControlStateNormal];
    [self.praiseBtn setTitle:[visitStat.praiseCnt stringValue] forState:UIControlStateNormal];
    [self.commentBtn setTitle:[visitStat.commentCnt stringValue] forState:UIControlStateNormal];
}

#pragma mark - Getter
- (UIView *)ToolView
{
    if (!_ToolView) {
        _ToolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 81)];
        [_ToolView addSubview:self.line1];
        [_ToolView addSubview:self.line2];
        [_ToolView addSubview:self.readBtn];
        [_ToolView addSubview:self.commentBtn];
        [_ToolView addSubview:self.praiseBtn];
    }
    return _ToolView;
}

- (UIView *)line1
{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = DWDColorSeparator;
    }
    return _line1;
}
- (UIView *)line2
{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = DWDColorSeparator;
    }
    return _line2;
}
- (UIButton *)readBtn
{
    if (!_readBtn) {
        _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_readBtn setImage:[UIImage imageNamed:@"ic_read_details"] forState:UIControlStateNormal];
        [_readBtn setTitleColor:DWDColorSecondary forState:UIControlStateNormal];
        [_readBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
        _readBtn.titleLabel.font = DWDFontMin;
    }
    return _readBtn;
}
- (UIButton *)commentBtn
{
    if (!_commentBtn) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setImage:[UIImage imageNamed:@"ic_comment"] forState:UIControlStateNormal];
        [_commentBtn setTitleColor:DWDColorSecondary forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
         _commentBtn.titleLabel.font = DWDFontMin;
    }
    return _commentBtn;
}
- (UIButton *)praiseBtn
{
    if (!_praiseBtn) {
        _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_praiseBtn setImage:[UIImage imageNamed:@"ic_praise"] forState:UIControlStateNormal];
        [_praiseBtn setTitleColor:DWDColorSecondary forState:UIControlStateNormal];
        [_praiseBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
         _praiseBtn.titleLabel.font = DWDFontMin;
    }
    return _praiseBtn;
}
@end
