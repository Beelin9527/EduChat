//
//  DWDGroupSelectHeaderView.h
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSchoolGroupModel, DWDGroupSelectHeaderView;

@protocol DWDGroupSelectHeaderViewDelegate <NSObject>

@optional

/**
 header view 要全选当前section的所有members

 @param section 当前section
 */
- (void)groupSelectHeaderView:(DWDGroupSelectHeaderView *)view shouldAllSelectInSection:(NSInteger)section;

/**
 header view点击了扩展按钮, 当前section的row应该被展开/收起

 @param section 当前section
 */
- (void)groupSelectHeaderView:(DWDGroupSelectHeaderView *)view shouldChangeExpandStateInSection:(NSInteger)section;

@end


@interface DWDGroupSelectHeaderView : UITableViewHeaderFooterView

//current header view section
@property (nonatomic, assign) NSUInteger section;

@property (nonatomic, weak) id<DWDGroupSelectHeaderViewDelegate> eventDelegate;

// 在view for headerfooterview中设置数据
- (void)setHeaderData:(DWDSchoolGroupModel *)model;

// 刷新view
- (void)reloadView;

@end
