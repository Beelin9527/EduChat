//
//  DWDPickUpCenterTimeLinePresentationController.m
//  EduChat
//
//  Created by KKK on 16/3/30.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLinePresentationController.h"

@implementation DWDPickUpCenterTimeLinePresentationController

{
//    UIView *dimingView;
    UIVisualEffectView *dimingView;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        dimingView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//        dimingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return CGRectInset(self.containerView.bounds, (DWDScreenW - pxToW(600)) / 2.0, (DWDScreenH - pxToW(900)) / 2.0);
//    return CGRectInset(self.containerView.bounds, 50, 100);
}

- (void)containerViewWillLayoutSubviews {
    
    dimingView.frame = self.containerView.bounds;
}

- (void)presentationTransitionWillBegin {
    UIView *containerView = self.containerView;
    UIView *presentedView = self.presentedView;
    id <UIViewControllerTransitionCoordinator> coordinator = self.presentingViewController.transitionCoordinator;
    
    dimingView.alpha = 0;
    [containerView addSubview:dimingView];
    [dimingView addSubview:presentedView];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        dimingView.alpha = 0.9;
        
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [dimingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        dimingView.alpha = 0;
        
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [dimingView removeFromSuperview];
    }
}

@end
