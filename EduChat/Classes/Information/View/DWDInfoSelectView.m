//
//  DWDInfoSelectView.m
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoSelectView.h"
#import "DWDInfoPlateModel.h"

@interface DWDInfoSelectView ()

{
    UIButton *_currentBtn;
    UIView *_indicateView;
    UIView *_topLine;
    UIView *_bottomLine;
    CGFloat itemW;
}

@end

@implementation DWDInfoSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //指示线
        _indicateView = [[UIView alloc] initWithFrame:CGRectMake(20, selectViewHeight - 2.0, itemW - 40.0, 2.0)];
        _indicateView.backgroundColor = DWDColorMain;
        
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 0.5)];
        _topLine.backgroundColor = DWDRGBColor(226, 226, 226);
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, selectViewHeight - 0.5, DWDScreenW, 0.5)];
        _bottomLine.backgroundColor = DWDRGBColor(226, 226, 226);
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    if (_items) {
        for (DWDInfoPlateModel *plate in _items) {
            [plate removeObserver:self forKeyPath:@"showBadge" context:nil];
        }
    }
    _items = items;
    itemW = DWDScreenW/items.count;

    CGFloat labelW = 0;
    CGFloat margin = 0;
    // 移除当前已添加Button
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] || [subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }
    for (DWDInfoPlateModel *item in items) {
        CGFloat w = [item.plateName boundingRectWithfont:DWDFontBody].width;
        margin += w;
    }
    margin = (DWDScreenW - margin)/(items.count + 1);
    
    // 重新添加Button
    for (int i = 0; i < items.count; i++) {
        
        DWDInfoPlateModel *plate = items[i];
        [plate addObserver:self forKeyPath:@"showBadge" options:0 context:nil];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(itemW * i, 0, itemW, selectViewHeight);
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = DWDFontBody;
        btn.adjustsImageWhenHighlighted = NO;
        btn.tag = 1000 + i;
        [self addSubview:btn];
        
        // 文本
        UILabel *lbl = [[UILabel alloc] init];
        lbl.font = DWDFontBody;
        lbl.textColor = DWDColorContent;
        lbl.text = [items[i] plateName];
        CGSize size = [lbl.text boundingRectWithfont:lbl.font];
        lbl.y = 0;
        lbl.w = size.width;
        lbl.h = selectViewHeight;
        lbl.x = (i + 1) * margin + labelW;
        labelW += lbl.w;
        lbl.tag = 555 + i;
        [self addSubview:lbl];
        
        // 小红点
        UIView *badge = [[UIView alloc] init];
        badge.w = 8;
        badge.h = 8;
        badge.y = 8;
        badge.x = lbl.w;
        badge.tag = 222;
        badge.backgroundColor = [UIColor redColor];
        badge.layer.cornerRadius = 4;
        badge.layer.masksToBounds = YES;
        badge.hidden = YES;
        [lbl addSubview:badge];
        
        if ([items[i] isDefault])
        {
            btn.selected = YES;
            lbl.textColor = DWDColorMain;
            _currentBtn = btn;
            _indicateView.cenX = lbl.cenX;
            _indicateView.w = lbl.w + 10;
        }
    }
    [self addSubview:_topLine];
    [self addSubview:_bottomLine];
    [self addSubview:_indicateView];
}

- (void)buttonAction:(UIButton *)sender
{
    if (sender == _currentBtn) {
        return;
    }
    
    NSUInteger fromIndex = _currentBtn.tag - 1000;
    _currentBtn.selected = NO;
    _currentBtn = sender;
    _currentBtn.selected = YES;
    NSUInteger toIndex = _currentBtn.tag - 1000;
    
    UILabel *fromLbl = [self viewWithTag:555 + fromIndex];
    fromLbl.textColor = DWDColorContent;
    UILabel *curLbl = [self viewWithTag:555 + toIndex];
    curLbl.textColor = DWDColorMain;
    // 指示线长度可变
    [UIView animateWithDuration:0.2 animations:^{
        _indicateView.w = curLbl.w + 10;
        _indicateView.cenX = curLbl.cenX;
    }];
    
    if (self.selectViewBlock) {
        self.selectViewBlock(fromIndex, toIndex);
    }
}

//- (void)setSelectIndex:(NSInteger)selectIndex
//{
//    if (_selectIndex >= _items.count || _currentBtn.tag - 1000 == selectIndex)
//        return;
//    
//    _selectIndex = selectIndex;
//    _currentBtn.selected = NO;
//    _currentBtn.backgroundColor = [UIColor whiteColor];
//    _currentBtn = [self viewWithTag:1000 + _selectIndex];
//    _currentBtn.selected = YES;
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        _indicateView.x = selectIndex * itemW + 20;
//    }];
//}

- (NSInteger)selectIndex
{
    _selectIndex = _currentBtn.tag - 1000;
    return _selectIndex;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    DWDInfoPlateModel *plate = object;
    NSUInteger index = [_items indexOfObject:plate];

    UILabel *lbl = (UILabel *)[self viewWithTag:555 + index];
    
    if (plate.showBadge && index != _currentBtn.tag - 1000) {
        
        [lbl viewWithTag:222].hidden = NO;
    }else {
        [lbl viewWithTag:222].hidden = YES;
    }
}

@end
