//
//  DWDIntClassItemView.m
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntClassItemView.h"

#import "DWDSchoolModel.h"

@interface DWDIntClassItemView()
@property (nonatomic, strong) UIScrollView *scr;
@property (nonatomic, strong) UIButton *selectBtnFalg;
@property (nonatomic, strong) UIButton *pulldownBtn;
@property (nonatomic, strong) UIView *menuClassView;

@property (nonatomic, strong) NSMutableArray <UIButton *> *arrayButton;//按钮数组

@end

static const CGFloat btnH = 40;
@implementation DWDIntClassItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _arrayButton = [NSMutableArray array];
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scr];
    }
    return self;
}


#pragma mark - Setter
- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    
    //remove all subview
    [self.scr.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //layout
    if (dataSource.count == 2 || dataSource.count == 3){
        [self layoutClassItemWithDataSource:dataSource];
        [self.scr setContentSize:self.scr.size];
        if([self.subviews containsObject:self.pulldownBtn]){
            [self.pulldownBtn removeFromSuperview];
        }
    }else{
        [self layoutClassItemWithDataSource:dataSource];
        [self.scr setContentSize:CGSizeMake(self.scr.w/3.0 * dataSource.count + 40, self.scr.h)];
        [self addSubview:self.pulldownBtn];
        
    }
}
#pragma mark - Getter
- (UIScrollView *)scr{
    if (!_scr) {
        _scr = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
        _scr.showsVerticalScrollIndicator = NO;
        _scr.showsHorizontalScrollIndicator = NO;
    }
    return _scr;
}
- (UIButton *)pulldownBtn{
    if (!_pulldownBtn) {
        _pulldownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pulldownBtn.frame = CGRectMake(self.scr.w - 40, 0, 40, 40);
        [_pulldownBtn setBackgroundColor:[UIColor whiteColor]];
        _pulldownBtn.selected = NO;
        [_pulldownBtn setImage:[UIImage imageNamed:@"icon_pulldown"] forState:UIControlStateNormal];
        [_pulldownBtn setBackgroundImage:[UIImage imageNamed:@"bg_pulldown"] forState:UIControlStateNormal];
        [_pulldownBtn addTarget:self action:@selector(pullMenuAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _pulldownBtn;
}

#pragma mark - Public Method
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
    CGFloat btnW = dataSource.count < 4 ? self.scr.w / dataSource.count : self.scr.w / 3;
    
    if (self.arrayButton.count > 0) {
        //clear
        [self.arrayButton removeAllObjects];
    }
//    NSString *btnTitle = nil;
    for (int i = 0; i < dataSource.count; i ++) {
        DWDIntClassModel *model =  dataSource[i];
        
//            btnTitle = [NSString stringWithFormat:@"%@", classModel.className];
    
        [self.scr addSubview:({
            UIButton *btn = [self createButton];
            btn.frame = CGRectMake(btnW * i, 0, btnW, btnH);
            [btn setTitle:model.className forState:UIControlStateNormal];
            btn.tag = i;
            [btn addTarget:self action:@selector(selectClassItem:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [self selectClassItem:btn];
            }
            
            //加入容器
            [self.arrayButton addObject:btn];
            btn;
        })];
        [self.scr addSubview:({
            if(i == 0) continue;
            UIView *line = [self createLine];
            line.origin = CGPointMake(btnW * i, 10);
            line;
        })];
    }
}
#pragma mark - Event Response
- (void)pullMenuAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(intClassItemViewClickMenuButton:)]) {
            [self.delegate intClassItemViewClickMenuButton:self];
            sender.selected = NO;
        }
    }
}
- (void)selectClassItem:(UIButton *)sender{
    self.selectBtnFalg.selected = NO;
    sender.selected = YES;
    self.selectBtnFalg = sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(intClassItemView:selectItem:)]) {
        [self.delegate intClassItemView:self selectItem:self.dataSource[sender.tag]];
    }
}

/**
 更新所选按钮
 */
- (void)updateSelectItemWithIndex:(NSInteger)index{
    UIButton *btn = self.arrayButton[index];
    
    self.selectBtnFalg.selected = NO;
    btn.selected = YES;
    self.selectBtnFalg = btn;
    
    //计算 index是0开始; 滑动self.scr元素按钮可见
    NSInteger i = index / 3;
    [self.scr setContentOffset:CGPointMake(self.scr.w * i, 0) animated:YES];
}
@end
