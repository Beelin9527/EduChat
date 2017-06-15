//
//  DWDChatPreViewCell.h
//  EduChat
//
//  Created by Superman on 16/9/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDImageChatMsg;
@protocol DWDChatPreViewCellDelegate <NSObject>

@required
- (void)preViewCellImageViewTap;
- (void)preViewCellImageRelayToSomeOne;
@end

@interface DWDChatPreViewCell : UICollectionViewCell
@property (nonatomic , weak) UIImageView *imageView;
@property (nonatomic , weak) UIScrollView *scrollView;
@property (nonatomic , weak) id<DWDChatPreViewCellDelegate> preViewCellDelegate;

@property (nonatomic , strong) NSIndexPath *indexPath;
@property (nonatomic , strong) DWDImageChatMsg *imageMsg;
@end
