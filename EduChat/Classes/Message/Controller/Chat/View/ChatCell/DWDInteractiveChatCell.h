//
//  DWDInteractiveChatCell.h
//  EduChat
//
//  Created by apple on 11/17/15.
//  Copyright © 2015 dwd. All rights reserved.
//
//  Super chat cell.
//  In message model, All chat cell can interactive with user must inherit from this class.
//  Edit by Fanly

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

#define DWDCellEditingEdgeLength 20
#define DWDCellPadding 10
#define DWDAvatarEdgeLength 40
#define DWDIndicatorWidth 20
#define DWDContentUpDownPadding 5
#define DWDContentLeftRightPaddingMax 25
#define DWDBubbleArrowWidth 10
#define DWDContentLeftRightPaddingMin 15
#define DWDErrorEdgeLength 20

@class DWDGrowingTextView;

typedef NS_ENUM(NSInteger, DWDChatCellUserType) {
    DWDChatCellUserTypeMyself,
    DWDChatCellUserTypeOther,
};

typedef NS_ENUM(NSInteger, DWDChatCellStatus) {
    DWDChatCellStatusNormal,
    DWDChatCellStatusSending,
    DWDChatCellStatusError,
};

@class DWDInteractiveChatCell;

@protocol DWDInteractiveChatCellDelegate <NSObject>

@required
- (void)interactiveChatCellDidCopyWithCell:(DWDInteractiveChatCell *)cell;      // 复制
- (void)interactiveChatCellDidRelayWithCell:(DWDInteractiveChatCell *)cell;     // 转发
- (void)interactiveChatCellDidCollectWithCell:(DWDInteractiveChatCell *)cell;   // 收藏
- (void)interactiveChatCellDidDeleteWithCell:(DWDInteractiveChatCell *)cell;    // 删除
- (void)interactiveChatCellDidRevokeWithCell:(DWDInteractiveChatCell *)cell;    // 撤销
- (void)interactiveChatCellDidClickMoreWithCell:(DWDInteractiveChatCell *)cell; // 更多

- (void)interactiveChatCellDidMutlEditingSelectedWithCell:(DWDInteractiveChatCell *)cell;    // 结束多选
- (void)interactiveChatCellDidMutlEditingDisselectedWithCell:(DWDInteractiveChatCell *)cell; // 取消结束多选

- (void)growingTextViewIsFirstResponderWithCell:(DWDInteractiveChatCell *)cell;

@optional
- (void)interactiveChatCellDidUploadWithCell:(DWDInteractiveChatCell *)cell;
- (void)interactiveChatCellDidClickAvatarWithCell:(DWDInteractiveChatCell *)cell;
- (void)interactiveChatCellDidClickContentWithCell:(DWDInteractiveChatCell *)cell;
- (void)interactiveChatCellDidClickURL:(NSURL *)url WithCell:(DWDInteractiveChatCell *)cell;
- (void)interactiveChatCellDidClickErrorImageViewWithCell:(DWDInteractiveChatCell *)cell;

@end

@interface DWDInteractiveChatCell : UITableViewCell <TTTAttributedLabelDelegate> {
        CGRect avatareFrame, nicknameFrame, sendingFrame, errorFrame, editingFrame;
}

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@property (strong, nonatomic) UIActivityIndicatorView *sendingIndicator;
@property (strong, nonatomic) UIImageView *errorImgView;

@property (strong, nonatomic) UIImage *bubbleMyself;
@property (strong, nonatomic) UIImage *bubbleOther;

//define where the uimenuview can display
@property (strong, nonatomic) UIView *menuTargetView;

@property (nonatomic) BOOL isShowNickname;

@property (nonatomic) BOOL isMultEditingSelected;

@property (nonatomic) DWDChatCellUserType userType;

@property (nonatomic) DWDChatCellStatus status;

@property (nonatomic , assign) DWDChatType chatType;

@property (nonatomic , strong) NSArray *menuTitles;

@property (nonatomic , strong) NSNumber *createTime;


@property (weak, nonatomic) id<DWDInteractiveChatCellDelegate> delegate;

//views proteries
@property (strong, nonatomic) UIImageView *avatarImgView;
@property (strong, nonatomic) UIImageView *editingView;
@property (strong, nonatomic) TTTAttributedLabel *nicknameLabel;
@property (nonatomic , weak) DWDGrowingTextView *growingTextView;


- (void)commitInitWithTitles;
//why thos methods are public?
//custom subclass can invoke directly
- (void)longPressHandler:(UILongPressGestureRecognizer *)sender;

- (void)buildMyselfAvatarFrame;
- (CGSize)buildMyselfNicknameFrame;

- (void)buildOtherAvatarFrame;
- (CGSize)buildOtherNicknameFrame;

- (CGSize)getNicknameSize;

//sometimes you want add your gesture recognizer, so you need remove super calss's.
- (void)upload:(id)sender;

//subclass need to override those methods
- (void)UIPrepareForSendingDataStatus;
- (void)UIPrepareForCreateStatus;
- (void)UIPrepareForNormalStatus;
- (void)UIPrepareForErrorStatus;
- (CGFloat)getHeight;

@end
