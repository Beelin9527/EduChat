//
//  DWDMultiSelectImageView.h
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//  选择多张图片 View

#import <UIKit/UIKit.h>
@class DWDMultiSelectImageView;
@protocol DWDMultiSelectImageViewDelegate <NSObject>

@required
- (void)multiSelectImageViewDidSelectAddButton:(DWDMultiSelectImageView *)multiSelectImageView;

@end

@interface DWDMultiSelectImageView : UIView

+ (instancetype)multiSelectImageView;

@property (strong, nonatomic) NSMutableArray *arrImages;
@property (nonatomic,weak) IBOutlet id<DWDMultiSelectImageViewDelegate> delegate;
@end
