//
//  DWDInfoExpertChart.m
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpertChart.h"
#import "DWDInfoExpertCartView.h"

@implementation DWDInfoExpertChart

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    NSArray *images = @[@"ic_tag_one",@"ic_tag_two",@"ic_tag_three"];
    CGFloat itemWB = (DWDScreenW - 4 * 15.0)/3;
    CGFloat itemHB = itemWB * 1.53;
    
    CGFloat itemWS = 90.0 * DWDScreenW/375;
    CGFloat itemHS = itemWS * 1.53;
    
    for (int i = 0; i < 3; i ++) {
        
        DWDInfoExpertCartView *expView = [[DWDInfoExpertCartView alloc] init];
        expView.frame = CGRectMake(i * (itemWB + 15.0) + 15.0, 18.0, itemWB, itemHB);
        [expView setTopImage:[UIImage imageNamed:images[i]]];
        [expView setRank:i + 1];
        [expView setTag:999 + i];
        [expView setTapBlock:^(NSInteger index) {
            self.block ? self.block(index) : nil;
        }];
        [self addSubview:expView];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 45.0 + itemHB, DWDScreenW, itemHS);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake((itemWS + 15.0) * 7 + 15.0, itemHS);
    [self addSubview:scrollView];
    
    for (int i = 0; i < 7; i ++) {
        DWDInfoExpertCartView *expView = [[DWDInfoExpertCartView alloc] init];
        expView.frame = CGRectMake(i * (itemWS + 15.0) + 15.0, 0, itemWS, itemHS);
        [expView setTopImage:[UIImage imageNamed:@"ic_tag_gray"]];
        [expView setRank:i + 4];
        [expView setTag:999 + i + 3];
        [expView setTapBlock:^(NSInteger index) {
            self.block ? self.block(index) : nil;
        }];
        [scrollView addSubview:expView];
    }
}

- (void)setExperts:(NSArray<DWDInfoExpertModel *> *)experts
{
    _experts = experts;
    for (int i = 0; i < 10; i ++) {
        
        DWDInfoExpertCartView *expView = [self viewWithTag:999 + i];
        if (i < experts.count) {
            expView.expert = experts[i];
        }else {
            expView.hidden = YES;
        }
    }
}

+ (CGFloat)getExpertChartHeight
{
    CGFloat itemWB = (DWDScreenW - 4 * 15.0)/3;
    CGFloat itemHB = itemWB * 1.53;
    
    CGFloat itemWS = 90.0 * DWDScreenW/375;
    CGFloat itemHS = itemWS * 1.53;
    
    CGFloat height = itemHB + itemHS + 18.0 + 50.0;
    return height;
}

@end
