//
//  DWDTeacherDetailViewNavigationTitleView.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherDetailViewNavigationTitleView.h"

@interface DWDTeacherDetailViewNavigationTitleView ()

@property (nonatomic, strong) UIButton *goSchoolButton;
@property (nonatomic, strong) UIButton *leaveSchoolButton;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation DWDTeacherDetailViewNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    //go school button
    UIButton *goSchoolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goSchoolButton setTitle:@"上学" forState:UIControlStateNormal];
    [goSchoolButton setTitleColor:DWDRGBColor(186, 209, 255) forState:UIControlStateNormal];
    [goSchoolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [goSchoolButton addTarget:self action:@selector(goSchoolButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [goSchoolButton sizeToFit];
    [goSchoolButton setCenter:CGPointMake(frame.size.width * 0.25, frame.size.height * 0.5)];
    
    [self addSubview:goSchoolButton];
    self.goSchoolButton = goSchoolButton;
    
    //leave school button
    UIButton *leaveSchoolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leaveSchoolButton setTitle:@"放学" forState:UIControlStateNormal];
    [leaveSchoolButton setTitleColor:DWDRGBColor(186, 209, 255) forState:UIControlStateNormal];
    [leaveSchoolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [leaveSchoolButton addTarget:self action:@selector(leaveSchoolButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leaveSchoolButton sizeToFit];
    [leaveSchoolButton setCenter:CGPointMake(frame.size.width * 0.75, frame.size.height * 0.5)];
    
    [self addSubview:leaveSchoolButton];
    self.leaveSchoolButton = leaveSchoolButton;
    
    //spreator line
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
    self.lineView = lineView;
    self.lineView.frame = CGRectMake(goSchoolButton.origin.x, frame.size.height - 4, goSchoolButton.size.width, 2);
    
    
    [self goSchoolButtonClick];
    return self;
}

#pragma mark - private method


#pragma mark - event response
- (void)goSchoolButtonClick {
    self.goSchoolButton.selected = YES;
    self.leaveSchoolButton.selected = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.lineView.frame;
        frame.origin.x = self.goSchoolButton.frame.origin.x;
        self.lineView.frame = frame;
    }];
    
    if ([self.delegate respondsToSelector:@selector(titleViewDidClickGoSchoolButton:)]) {
        [self.delegate titleViewDidClickGoSchoolButton:self];
    }
  
}

- (void)leaveSchoolButtonClick {
    self.goSchoolButton.selected = NO;
    self.leaveSchoolButton.selected = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.lineView.frame;
        frame.origin.x = self.leaveSchoolButton.frame.origin.x;
        self.lineView.frame = frame;
    }];
    
    if ([self.delegate respondsToSelector:@selector(titleViewDidClickLeaveSchoolButton:)]) {
        [self.delegate titleViewDidClickLeaveSchoolButton:self];
    }
}

@end
