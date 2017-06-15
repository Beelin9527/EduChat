//
//  DWDIntSchoolItemView.m
//  EduChat
//
//  Created by Beelin on 16/12/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntSchoolItemView.h"

#import "DWDSchoolModel.h"

@interface DWDIntSchoolItemView ()
@property (nonatomic, strong) UIView *boxView;

@end

@implementation DWDIntSchoolItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.clipsToBounds = YES;
        
        //add gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(putAction:)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.boxView];
    }
    return self;
}


#pragma mark - Setter
- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    
    for (int i = 0; i < dataSource.count; i ++) {
        DWDSchoolModel *model = dataSource[i];
        
        UIButton *btn = [self createButton];
        btn.origin = CGPointMake(0, 44 * i);
        btn.tag = i;
        [btn setTitle:model.schoolName forState:UIControlStateNormal];
        [self.boxView addSubview:btn];
        
        CGFloat btnW = [btn.titleLabel.text boundingRectWithfont:DWDFontBody].width;
        UILabel *lab = [self createLabel];
        lab.origin = CGPointMake(btn.cenX + btnW/2.0 + 10, btn.cenY - lab.h/2.0);
         //[self.boxView addSubview:lab];
        
        if (i == 0) continue;
        UIView *line = [self createLine];
        line.origin = CGPointMake(10, btn.h * i);
        [self.boxView addSubview:line];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.frame = CGRectMake(0, 0, self.w, 44 * dataSource.count);
    }];
}

#pragma mark - Getter
- (UIView *)boxView{
    if (!_boxView) {
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.w, 0)];
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
}

#pragma mark - Event Response
- (void)selectItem:(UIButton *)sender{
    [self putAction:nil];
    
    !self.selectItemBlock ?: self.selectItemBlock(self.dataSource[sender.tag]);
}

/** remove from superview */
- (void)putAction:(UIButton *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.frame = CGRectMake(0, 0, self.w, 0);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    } completion:^(BOOL finished) {
        !self.removeFromSuperViewBlock ?: self.removeFromSuperViewBlock();
         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self removeFromSuperview];
        
    }];
    
}

#pragma mark - Private Method
- (UIButton *)createButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.size = CGSizeMake(DWDScreenW, 44);
    [btn setTitleColor:DWDColorBody forState:UIControlStateNormal];
    [btn setTitleColor:DWDColorMain forState:UIControlStateSelected];
    btn.titleLabel.font = DWDFontContent;
    [btn addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchDown];
    return btn;
}

- (UILabel *)createLabel{
    UILabel *lab = [[UILabel alloc] init];
    lab.size = CGSizeMake(19, 16);
    lab.text = @"新";
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:11];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor redColor];
    
    lab.layer.masksToBounds = YES;
    lab.layer.cornerRadius = 8;
    
    return lab;
}
- (UIView *)createLine{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = DWDColorSeparator;
    line.size = CGSizeMake(DWDScreenW - 20, 0.5);
    return line;
}
@end
