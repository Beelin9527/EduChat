//
//  DWDChattingBaseCell.h
//  EduChat
//
//  Created by Superman on 16/11/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYLabel,DWDGrowingTextView,DWDChattingBaseCell,DWDChatBaseMsg;

typedef NS_ENUM(NSInteger, DWDChatCellStatus) {
    DWDChatCellStatusNormal,
    DWDChatCellStatusSending,
    DWDChatCellStatusError,
};

@protocol DWDChattingCellDelegate <NSObject>
@required
- (void)chatCellDidCopyAtIndexPath:(NSIndexPath *)indexPath; // 复制
- (void)chattingCellDidRelayAtIndexPath:(NSIndexPath *)indexPath; // 转发
- (void)chattingCellDidCollectAtIndexPath:(NSIndexPath *)indexPath; // 收藏
- (void)chattingCellDidDeleteAtIndexPath:(NSIndexPath *)indexPath; // 删除
- (void)chattingCellDidRevokeAtIndexPath:(NSIndexPath *)indexPath; // 撤销
- (void)chattingCellDidClickMoreAtIndexPath:(NSIndexPath *)indexPath; // 更多

- (void)chattingCellDidMutlEditingSelectedAtIndexPath:(NSIndexPath *)indexPath; // 结束多选
- (void)chattingCellDidMutlEditingDisselectedAtIndexPath:(NSIndexPath *)indexPath; // 取消结束多选

- (void)growingTextViewIsFirstResponderWithCell:(DWDChattingBaseCell *)cell;

@optional
- (void)chattingCellDidUploadAtIndexPath:(NSIndexPath *)indexPath;
- (void)chattingCellDidClickAvatarAtIndexPath:(NSIndexPath *)indexPath;
- (void)chattingCellDidClickContentAtIndexPath:(NSIndexPath *)indexPath;
- (void)chattingCellDidClickURL:(NSURL *)url AtIndexPath:(NSIndexPath *)indexPath;
- (void)chattingCellDidClickErrorImageViewAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DWDChattingBaseCell : UITableViewCell
// subViews
@property (strong, nonatomic) UIActivityIndicatorView *sendingIndicator;
@property (strong, nonatomic) UIImageView *errorImgView;
@property (strong, nonatomic) UIImageView *avatarImgView;
@property (strong, nonatomic) UIImageView *editingView;
@property (strong, nonatomic) YYLabel *nicknameLabel;


@property (strong, nonatomic) UIView *menuTargetView;
@property (nonatomic , weak) DWDGrowingTextView *growingTextView;

// gestureRecognizer
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

// delegate
@property (weak, nonatomic) id<DWDChattingCellDelegate> delegate;

// datas
@property (nonatomic , strong) DWDChatBaseMsg *baseMsg;

@property (nonatomic , strong) NSArray *menuTitles;

// cell config
@property (nonatomic) DWDChatCellStatus status;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isShowNickname;
@property (nonatomic) BOOL isMultEditingSelected;
@end
