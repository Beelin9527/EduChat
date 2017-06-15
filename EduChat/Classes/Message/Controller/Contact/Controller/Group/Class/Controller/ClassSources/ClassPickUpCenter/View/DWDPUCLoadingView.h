//
//  DWDPUCLoadingView.h
//  EduChat
//
//  Created by KKK on 16/9/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDPUCLoadingView;
@protocol DWDPUCLoadingViewDelegate <NSObject>

@required
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view;

@end

@interface DWDPUCLoadingView : UIView

@property (nonatomic, weak) UIImageView *loadingView;
@property (nonatomic, weak) UIImageView *blankImgView;
@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UIButton *reloadButton;

@property (nonatomic, weak) id<DWDPUCLoadingViewDelegate> delegate;

- (void)changeToFailedView;

- (void)changeToBlankView;

@end
