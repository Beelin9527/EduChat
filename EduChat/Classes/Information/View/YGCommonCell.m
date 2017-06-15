//
//  YGCommonCell.m
//  YouGuanJia
//
//  Created by mac on 16/6/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "YGCommonCell.h"

@implementation YGCommonCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _topLineStyle = CellLineStyleNone;
        _bottomLineStyle = CellLineStyleDefault;
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self.topLine setX:0];
    [self.bottomLine setY:self.h - _bottomLine.h];
    [self setBottomLineStyle:_bottomLineStyle];
    [self setTopLineStyle:_topLineStyle];
}

- (void) setTopLineStyle:(CellLineStyle)style
{
    _topLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.topLine setX:_leftFreeSpace];
        [self.topLine setW:self.w - _leftFreeSpace];
        [self.topLine setHidden:NO];
    }
    else if (style == CellLineStyleFill) {
        [self.topLine setX:0];
        [self.topLine setW:self.w];
        [self.topLine setHidden:NO];
    }
    else if (style == CellLineStyleNone) {
        [self.topLine setHidden:YES];
    }
}

- (void) setBottomLineStyle:(CellLineStyle)style
{
    _bottomLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.bottomLine setX:_leftFreeSpace];
        [self.bottomLine setW:self.w - _leftFreeSpace];
        [self.bottomLine setHidden:NO];
    }
    else if (style == CellLineStyleFill) {
        [self.bottomLine setX:0];
        [self.bottomLine setW:self.w];
        [self.bottomLine setHidden:NO];
    }
    else if (style == CellLineStyleNone) {
        [self.bottomLine setHidden:YES];
    }
}

- (UIView *) bottomLine
{
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        [_bottomLine setH:0.5f];
        [_bottomLine setBackgroundColor:[UIColor lightGrayColor]];
        [_bottomLine setAlpha:0.5];
        [self.contentView addSubview:_bottomLine];
    }
    return _bottomLine;
}

- (UIView *) topLine
{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        [_topLine setH:0.5f];
        [_topLine setBackgroundColor:[UIColor lightGrayColor]];
        [_topLine setAlpha:0.4];
        [self.contentView addSubview:_topLine];
    }
    return _topLine;
}

@end
