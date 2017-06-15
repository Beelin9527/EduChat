//
//  DWDIntClassMenuView.h
//  EduChat
//
//  Created by Beelin on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntClassModel, DWDIntClassMenuView;

@protocol DWDIntClassMenuViewDelegate <NSObject>

/**
 select item delegate
 */
- (void)intClassMenuView:(DWDIntClassMenuView *)intClassMenuView selectItem:(DWDIntClassModel *)model;
@end


@interface DWDIntClassMenuView : UIView
+ (instancetype)IntClassMenuViewWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource;

@property (nonatomic,weak) id<DWDIntClassMenuViewDelegate> delegate;
@end
