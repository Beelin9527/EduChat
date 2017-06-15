//
//  DWDPickUpCenterTimeLineTransitionDelegate.m
//  EduChat
//
//  Created by KKK on 16/3/30.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLineTransitionDelegate.h"

#import "DWDPickUpCenterTimeLinePresentationController.h"
#import "DWDPickUpCenterTimeLineTransition.h"

@implementation DWDPickUpCenterTimeLineTransitionDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[DWDPickUpCenterTimeLinePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    
    return [[DWDPickUpCenterTimeLineTransition alloc] init];
    
}

@end
