//
//  DWDIntClassMenuView.m
//  EduChat
//
//  Created by Beelin on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntClassMenuView.h"

#import "DWDSchoolModel.h"
@interface DWDIntClassMenuView ()
@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) UIScrollView *scrView;
@property (nonatomic, strong) UIButton *putBtn;

@property (nonatomic, strong) NSArray *dataSource;
@end

static const CGFloat btnH = 40;
@implementation DWDIntClassMenuView

+ (instancetype)IntClassMenuViewWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource{
    DWDIntClassMenuView *menu = [[DWDIntClassMenuView alloc] initWithFrame:frame];
    menu.dataSource = dataSource;
    return menu;
}
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
    
    if (dataSource.count == 0) {
        return;
    }else if(dataSource.count < 12){
        [self layoutClassItemWithDataSource:dataSource];
    }else{
        [self layoutClassItemScrollerViewWithDataSource:dataSource];
    }
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

/** 个数超过12个，才需要用到scrollerView */
- (UIView *)scrView{
    if (!_scrView) {
        //scrview height is 180(四行半，一行为40)
        _scrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 180)];
    }
    return _scrView;
}

- (UIButton *)putBtn{
    if (!_putBtn) {
        _putBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_putBtn setImage:[UIImage imageNamed:@"icon_packup"] forState:UIControlStateNormal];
        [_putBtn addTarget:self action:@selector(putAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _putBtn;
}

#pragma mark - Private Method
- (UIButton *)createButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:DWDColorBody forState:UIControlStateNormal];
    [btn setTitleColor:DWDColorMain forState:UIControlStateSelected];
    btn.titleLabel.font = DWDFontContent;
    return btn;
}

- (UIView *)createLine{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = DWDColorSeparator;
    line.size = CGSizeMake(0.5, 20);
    return line;
}

- (void)layoutClassItemWithDataSource:(NSArray *)dataSource{
    CGFloat btnW =  self.w / 3;

    for (int i = 0; i < dataSource.count; i ++) {
        DWDIntClassModel *model =  dataSource[i];

        [self.boxView addSubview:({
            CGFloat btnX = btnW * (i%3);
            CGFloat btnY = btnH * (i/3);
            
            UIButton *btn = [self createButton];
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            [btn setTitle:model.className forState:UIControlStateNormal];
            btn.tag = i;
            [btn addTarget:self action:@selector(selectClassItem:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *line = [self createLine];
            line.origin = CGPointMake(btnW -0.5, 10);
            if(i % 3 !=2 ){
                [btn addSubview:line];
            }
            btn;
        })];
    }
    
    ///calculate boxView height  40 *row(不过4行)  + 30(putButtonHeight)
    NSInteger row = dataSource.count % 3 == 0 ? dataSource.count / 3 : dataSource.count /3 + 1;
    CGFloat boxViewH = 40 * row + 30;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.frame = CGRectMake(0, 0, self.w, boxViewH);
    }];
    
    //calculate putbutton frame
    self.putBtn.frame = CGRectMake(self.boxView.cenX - 30, 40 * row, 60, 30);
    [self.boxView addSubview:self.putBtn];
}

- (void)layoutClassItemScrollerViewWithDataSource:(NSArray *)dataSource{
    CGFloat btnW =  self.w / 3;
    
    for (int i = 0; i < dataSource.count; i ++) {
         DWDIntClassModel *model =  dataSource[i];
        
        [self.scrView addSubview:({
            CGFloat btnX = btnW * (i%3);
            CGFloat btnY = btnH * (i/3);
            
            UIButton *btn = [self createButton];
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            [btn setTitle:model.className forState:UIControlStateNormal];
            btn.tag = i;
            [btn addTarget:self action:@selector(selectClassItem:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *line = [self createLine];
            line.origin = CGPointMake(btnW -0.5, 10);
            if(i % 3 != 2){
                [btn addSubview:line];
            }
            btn;
        })];
    }
    
    //calculate boxView height  40 *4 + 20(一行半高度) + 30(putButtonHeight)
     CGFloat boxViewH = 40 * 4 + 20 + 30;
  
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.frame = CGRectMake(0, 0, self.w, boxViewH);
    }];


    //calculate scrView height  40 *row + 20(一行半高度)
    NSInteger row = dataSource.count % 3 == 0 ? dataSource.count / 3 : dataSource.count /3 + 1;
    CGFloat scrViewH = 40 * row + 20 ;
    [self.scrView setContentSize:CGSizeMake(self.scrView.w, scrViewH)];
    [self.boxView addSubview:self.scrView];
    
    //calculate putbutton frame
    self.putBtn.frame = CGRectMake(self.boxView.cenX - 30, 40 * 4 + 20, 60, 30);
    [self.boxView addSubview:self.putBtn];
}

#pragma mark - Event Response
- (void)selectClassItem:(UIButton *)sender{
    [self putAction:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(intClassMenuView:selectItem:)]) {
        [self.delegate intClassMenuView:self selectItem:self.dataSource[sender.tag]];
    }
}

/** remove from superview */
- (void)putAction:(UIButton *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.frame = CGRectMake(0, 0, self.w, 0);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    } completion:^(BOOL finished) {
         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
         [self removeFromSuperview];
    }];
   
}
@end
