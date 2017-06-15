//
//  DWDChatImageCell.h
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDInteractiveChatCell.h"
@class DWDPhotoMetaModel , DWDChatImageCell;

@protocol DWDChatImageCellTapContentDelegate <NSObject>
@optional
- (void)imageCellTapContentToScaleWithImageCell:(DWDChatImageCell *)cell;

@end

@interface DWDChatImageCell : DWDInteractiveChatCell

@property (strong, nonatomic) UIImageView *contentImageView;
@property (nonatomic , strong) UIImageView *backgroundImageView;
@property (strong, nonatomic) UILabel *desLabel;

@property (nonatomic) CGSize imageSize;
@property (nonatomic , strong) DWDPhotoMetaModel *photo;

@property (nonatomic , weak) id<DWDChatImageCellTapContentDelegate> imageCellDelegate;

@end
