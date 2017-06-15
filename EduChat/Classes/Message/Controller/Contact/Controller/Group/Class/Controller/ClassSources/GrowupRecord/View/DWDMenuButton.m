//
//  DWDMenuButton.m
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMenuButton.h"
#import "DWDMenuController.h"
#import "DWDClassGrowUpCell.h"
#import "DWDGrowUpRecordFrame.h"
@implementation DWDMenuButton



#warning over method 
- (void)menuButtonClick:(DWDMenuButton *)button {
    UIMenuController *menuVc = [UIMenuController sharedMenuController];
    [button becomeFirstResponder];
    UIMenuItem *zan = [[UIMenuItem alloc] initWithTitle:@"点赞" action:@selector(zanClick:)];
    UIMenuItem *comment = [[UIMenuItem alloc] initWithTitle:@"评论" action:@selector(commentClick:)];
    
    [menuVc setMenuItems:[NSArray arrayWithObjects:zan,comment, nil]];
    
    CGRect rect = CGRectMake(0, button.h * 0.9, button.w, button.h * 0.5);
    [menuVc setTargetRect:rect inView:button];
    [menuVc setMenuVisible:YES animated:YES];
    
}

- (void)menuButtonDidClick {
    UIMenuController *menuVc = [UIMenuController sharedMenuController];
    [self becomeFirstResponder];
    UIMenuItem *zan = [[UIMenuItem alloc] initWithTitle:@"点赞" action:@selector(zanClick:)];
    UIMenuItem *comment = [[UIMenuItem alloc] initWithTitle:@"评论" action:@selector(commentClick:)];
    
    [menuVc setMenuItems:[NSArray arrayWithObjects:zan,comment, nil]];
    
    CGRect rect = CGRectMake(0, self.h * 0.25, self.w, self.h * 0.5);
    [menuVc setTargetRect:rect inView:self];
    [menuVc setMenuVisible:YES animated:YES];
}

/**
 扩大点击区域
 */

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect hitRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-11, -11, -11, -11));
    
    if (CGRectContainsPoint(hitRect, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(zanClick:) || action == @selector(commentClick:));
}


- (void)zanClick:(UIMenuController *)menuVc{
    if ([self.delegate respondsToSelector:@selector(menuButtonDidClickZanButton:)]) {
        [self.delegate menuButtonDidClickZanButton:self];
    }
}

- (void)commentClick:(UIMenuController *)menuVc{
    DWDLogFunc;
    if ([self.delegate respondsToSelector:@selector(menuButtonDidclickCommitButton:)]) {
        [self.delegate menuButtonDidclickCommitButton:self];
    }
}
@end
