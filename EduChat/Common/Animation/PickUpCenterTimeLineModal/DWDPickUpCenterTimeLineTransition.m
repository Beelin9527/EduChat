//
//  DWDPickUpCenterTimeLineTransition.m
//  EduChat
//
//  Created by KKK on 16/3/30.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLineTransition.h"

@implementation DWDPickUpCenterTimeLineTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    toView.frame = finalFrame;
    
    toView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    toView.alpha = 0.0f;
    [containerView addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^{
                         toView.transform = CGAffineTransformIdentity;
                         toView.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:finished];
                     }];
    
    
}

@end
