//
//  ZPSegmentedControl.m
//  EduChat
//
//  Created by Beelin on 15/12/8.
//  Copyright © 2015年 ZP. All rights reserved.
//

#import "DWDIntSegmentedButton.h"


@interface DWDIntSegmentedButton ()
@property (nonatomic,strong) UIView *indexLine;
@property (assign, nonatomic) CGFloat indexLineW;
@property (nonatomic,strong) UIButton *selectBtn;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, assign) NSInteger index;//指定选中哪个按钮
@end
@implementation DWDIntSegmentedButton

+ (instancetype)segmentedControlWithFrame:(CGRect)frame Titles:(NSArray *)titles index:(NSInteger)index{
    DWDIntSegmentedButton *control = [[DWDIntSegmentedButton alloc] initWithFrame:frame];
    control.index = index;
    control.titles = titles;
    control.backgroundColor = [UIColor whiteColor];
    //setup
    [control setupUI:titles];
    return control;
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}


-(void)setupUI:(NSArray *)titles
{
    if (titles==nil) {
        return;
    }
    
    _indexLineW = 85;
    
    //下标线
    [self addSubview:({
        self.indexLine = ({
            UIView *indexLine = [[UIView alloc]init];
            indexLine.backgroundColor  = self.tintColor ? self.tintColor : DWDColorMain;
            indexLine.frame = CGRectMake(0, self.bounds.size.height- 1.5,0,1.5);;
            indexLine;
        });
    })];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [btn setTitleColor:self.tintColor ? self.tintColor : DWDColorMain forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchDown];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.frame = CGRectMake(i*DWDScreenW/titles.count, 0, DWDScreenW/titles.count, self.bounds.size.height);
        [self insertSubview:btn belowSubview:self.indexLine];
        
        [self.btnArray addObject:btn];
        
        if (self.index == -1) continue;//-1将表示初始化不需要默认下标
        if (i == self.index) [self didSelect:btn];
        
        //竖分隔线
        /*
        UIView *lineS = [[UIView alloc]init];
        lineS.frame = CGRectMake(self.bounds.size.width/titles.count*i , 5, 0.5,self.bounds.size.height-10);
        lineS.backgroundColor  = Color_Separator;
        [self addSubview:lineS];
         */
    }
    
    //横分隔线
    [self insertSubview:({
        UIView *line = [[UIView alloc]init];
        line.frame = CGRectMake(0, self.bounds.size.height- 1.5, self.bounds.size.width,0.7);
        line.backgroundColor  = DWDColorSeparator;
        line;
        
    }) belowSubview:self.indexLine];
    
   
}

-(void)didSelect:(UIButton*)sender
{
    //防止点击已选按钮再次执行事件。 初始化时，self.selectBtn为nil,因此事件会执行
    if (self.selectBtn.tag == sender.tag && self.selectBtn) return;
    
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    
    [UIView animateWithDuration:.25 animations:^{
        CGFloat x = DWDScreenW/self.titles.count * self.selectBtn.tag + DWDScreenW/self.titles.count/2.0 - self.indexLineW/2.0;
        self.indexLine.frame = CGRectMake(x, self.bounds.size.height-1.5,_indexLineW, 1.5);
    }];
    
    //call back
    !self.clickButtonBlock ?: self.clickButtonBlock(sender.tag);
    //delegate
    if ([self.delegate respondsToSelector:@selector(segmentedControlIndexButtonView:lickBtnAtTag:)]) {
        [self.delegate segmentedControlIndexButtonView:self lickBtnAtTag:sender.tag];
    }
}


#pragma mark - Public Method
- (void)setupSelectButtonIndex:(NSInteger)index{
    [self.btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            UIButton *sender = obj;
            self.selectBtn.selected = NO;
            sender.selected = YES;
            self.selectBtn = sender;
            
            [UIView animateWithDuration:.25 animations:^{
                 CGFloat x = DWDScreenW/self.btnArray.count * self.selectBtn.tag + DWDScreenW/self.btnArray.count/2.0 - self.indexLineW/2.0;
                self.indexLine.frame = CGRectMake(x, self.bounds.size.height-1.5,_indexLineW, 1.5);
            }];
            *stop = YES;
        }
    }];
}

@end
