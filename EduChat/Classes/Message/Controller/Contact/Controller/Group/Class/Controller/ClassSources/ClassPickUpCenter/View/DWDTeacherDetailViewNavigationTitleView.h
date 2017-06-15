//
//  DWDTeacherDetailViewNavigationTitleView.h
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDTeacherDetailViewNavigationTitleView;
@protocol DWDTeacherDetailViewNavigationTitleViewDelegate <NSObject>

@optional
/**
 *  点击上学按钮
 *
 *  @param titleView titleView
 */
- (void)titleViewDidClickGoSchoolButton:(DWDTeacherDetailViewNavigationTitleView *)titleView;

/**
 *  点击放学按钮
 *
 *  @param titleView titleView
 */
- (void)titleViewDidClickLeaveSchoolButton:(DWDTeacherDetailViewNavigationTitleView *)titleView;

@end

@interface DWDTeacherDetailViewNavigationTitleView : UIView

@property(nonatomic, weak) id<DWDTeacherDetailViewNavigationTitleViewDelegate> delegate;

- (void)goSchoolButtonClick;

- (void)leaveSchoolButtonClick;

@end
