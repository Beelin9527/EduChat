//
//  DWDIntClassItemView.h
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntClassModel, DWDIntClassItemView;

@protocol DWDIntClassItemViewDelegate <NSObject>
/** 
 show menu delegate
 */
- (void)intClassItemViewClickMenuButton:(DWDIntClassItemView *)intClassItemView;

/** 
 select item delegate
 */
- (void)intClassItemView:(DWDIntClassItemView *)intClassItemView selectItem:(DWDIntClassModel *)model;
@end


@interface DWDIntClassItemView : UIView

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic,weak) id<DWDIntClassItemViewDelegate> delegate;

/** 
 更新所选按钮
 */
- (void)updateSelectItemWithIndex:(NSInteger)index;
@end
