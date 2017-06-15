//
//  DWDSegmentedControl.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSegmentedControl.h"
#define IndexLineW 80

@implementation DWDSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}



/**
 *  文字
 **/
-(void)setArrayTitles:(NSArray *)arrayTitles
{
    if (arrayTitles==nil) {
        return;
    }
    
    self.IndexLineX = self.bounds.size.width/arrayTitles.count/2-IndexLineW/2;
    
    for (int i = 0; i < arrayTitles.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.titleLabel.font = DWDFontBody;
        [btn setTitle:arrayTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [btn setTitleColor:DWDColorMain forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(licked:) forControlEvents:UIControlEventTouchDown];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.frame = CGRectMake(i*DWDScreenW/arrayTitles.count, 0, DWDScreenW/arrayTitles.count, self.bounds.size.height);
        [self addSubview:btn];
        
        if (i==0) {
            [self licked:btn];
        }
        
        
        //竖分隔线
        UIView *lineS = [[UIView alloc]init];
        lineS.frame = CGRectMake(self.bounds.size.width/arrayTitles.count*i , 12, 0.5, 20);
        lineS.backgroundColor  = DWDColorSeparator;
        [self addSubview:lineS];
    }
    
    //下标线
    UIView *indexLine = [[UIView alloc]init];
    self.indexLine = indexLine;
    self.indexLine.frame = CGRectMake(self.IndexLineX, self.bounds.size.height-3,IndexLineW, 3);
    indexLine.backgroundColor  = DWDColorMain;
    [self addSubview:indexLine];
    
    
    //横分隔线
    UIView *line = [[UIView alloc]init];
    line.frame = CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width,0.5);
    line.backgroundColor  = DWDColorSeparator;
    [self addSubview:line];
    
    
    
    
}

-(void)licked:(UIButton*)sender
{
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    
    [UIView animateWithDuration:.25 animations:^{
        [self.indexLine setX:CGRectGetMidX(sender.frame)-IndexLineW/2];
    }];
    
    if ([self.delegate respondsToSelector:@selector(segmentedControlIndexButtonView:lickBtn:)]) {
        [self.delegate segmentedControlIndexButtonView:self lickBtn:sender];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedControlIndexButtonView:index:)]) {
        [self.delegate segmentedControlIndexButtonView:self index:sender.tag];
    }
}


@end
