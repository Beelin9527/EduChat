//
//  DWDChatInputContainer.h
//  EduChat
//
//  Created by Superman on 16/6/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWDSpeakImageView.h"
#import "DWDGrowingTextView.h"
#import "DWDFaceView.h"

#import "DWDChatController.h"

#import "DWDChatEmotionContainer.h"

#import "DWDTextChatMsg.h"

@protocol DWDChatInputContainerDelegate <NSObject>
@required
- (void)tableViewChangeBottomCons:(CGFloat)cons;
- (void)tableViewScroll;
- (void)tableViewShouldChangeBottomConsAndReload:(CGFloat)changeCons;

- (void)addFileBtnClick;
- (void)addFileContainerDismiss;

- (void)faceBtnClick;

- (void)inputContainerChangeBtnClick;

- (void)inputContainerSendTextMsg:(NSArray *)msgs;
@end

@interface DWDChatInputContainer : UIView

@property (nonatomic , strong) DWDSpeakImageView *speakBtn;

@property (nonatomic , strong) DWDGrowingTextView *growingTextView;

//@property (nonatomic , strong) DWDFaceView *faceView;
@property (nonatomic , strong) DWDChatEmotionContainer *faceView;


@property (nonatomic , weak) DWDChatController *chatVc;
@property (nonatomic , assign) NSNumber *toUser;
@property (nonatomic , assign) DWDChatType chatType;


@property (nonatomic , weak) id<DWDChatInputContainerDelegate> delegate;

- (void)updateSubViewsConsForClassType;
- (void)updateSubViewsConsForFaceAndGroupType;

@end
