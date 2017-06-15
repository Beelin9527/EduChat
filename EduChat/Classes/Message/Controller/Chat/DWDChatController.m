//
//  DWDChatController.m
//  EduChat
//
//  Created by apple on 11/5/15.
//  Copyright © 2015 dwd. All rights reserved.
//  聊天界面控制器

#import <AudioToolbox/AudioToolbox.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYModel.h>
#import <YYText.h>
#import <AVFoundation/AVFoundation.h>
#import <MJRefresh.h>

#import "UIImage+Utils.h"
#import "UIViewController+kkk_status_bar_swizzling.h"

#import "DWDChatMsgDataClient.h"
#import "DWDAudioClient.h"
#import "DWDChatMsgClient.h"
#import "DWDChatClient.h"
#import "DWDMessageTimerManager.h"

#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDContactsDatabaseTool.h"

#import "DWDChatMsgReceipt.h"
#import "DWDTextChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDTimeChatMsg.h"
#import "DWDNoteChatMsg.h"
#import "DWDLastNoteModel.h"
#import "DWDSysMsg.h"

#import "DWDGroupInfoViewController.h"
#import "DWDChatController.h"
#import "DWDClassMainViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDClassNotificationDetailController.h"
#import "DWDRelayOnChatController.h"
#import "DWDNavViewController.h"
#import "DWDClassInfoViewController.h"

#import "DWDChatTextCell.h"
#import "DWDChatImageCell.h"
#import "DWDChatAudioCell.h"
#import "DWDChatTimeCell.h"
#import "DWDChatNoteCell.h"
#import "DWDChatVideoCell.h"

#import "DWDClassChatBottomView.h"
#import "DWDClassMenu.h"
#import "DWDClassChatTopView.h"
#import "DWDChatInputContainer.h"

#import "DWDButton.h"
#import "DWDChatPreView.h"
#import "DWDChatPreViewCell.h"

#import "DWDChatDataHandler.h"

#import "NSString+extend.h"

#define DWDMsgCachFilePath [NSHomeDirectory() stringByAppendingString:@"/Documents/errorMsgCach.dwd"]
#define DWDMessagePageCount 20

typedef NS_ENUM(NSInteger, DWDDismissKeyboardType) {
    DWDDismissKeyboardDefault,
    DWDDismissKeyboardFromReturnKey,
    DWDDismissKeyboardFromSwitchToVocieInput,
    DWDDismissKeyboardFromSwitchToTextInput,
};

@interface DWDChatController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UIScrollViewDelegate,
UITextViewDelegate, DWDAudioClientDelegate, DWDInteractiveChatCellDelegate,UIAlertViewDelegate , DWDSpeakImageViewDelegate , DWDChatInputContainerDelegate , DWDChatAddFileContainerDelegate , DWDChatImageCellTapContentDelegate , DWDGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet DWDClassChatTopView *topNoteContainer;

@property (weak, nonatomic) IBOutlet DWDChatInputContainer *bottomContainer;

@property (nonatomic , weak) DWDClassChatBottomView *myClassChatBottomView;


//mutl edting views
@property (weak, nonatomic) IBOutlet UIView *multiEditingPanel;

//layout values
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerToBottom;  // 输入框对底部guide的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addFileToBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addFileHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopCons;

@property (assign, nonatomic) CGFloat inputContainerHeightBackup;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multiEditingPanelToBottom;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *multiEditingItemPaddings;

//logic vlause
@property (assign, nonatomic) BOOL isNeedDismissKeyboard;
@property (assign, nonatomic) BOOL isNeedDismissAddFileContainer;
@property (assign, nonatomic) BOOL isScrollByUser;
@property (assign, nonatomic) BOOL isNeedLayoutAddFilePanelItmes;
@property (assign, nonatomic) BOOL isNeedLayoutMultiEditingPanelItems;

@property (assign, nonatomic) DWDDismissKeyboardType dismissKeyboardType;
@property (strong, nonatomic) UIBarButtonItem *returnItem;

//clients
@property (assign, nonatomic) DWDAudioClient *audioClient;
@property (strong, nonatomic) DWDChatMsgClient *chatClient;

//datas
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) NSMutableArray *cellHeightCache;
@property (nonatomic , strong) NSMutableArray *multSelectMessages;
@property (nonatomic , strong) NSCache *placeHolderCach;


@property (strong, nonatomic) MBProgressHUD *hud;

//mock views, must delete when model is implemented. // 缓存图片

@property (nonatomic , strong) DWDChatAudioCell *playingAudioCell;

@property (nonatomic , strong) AVAudioPlayer *audioPlayer;
@property (nonatomic , strong) NSTimer *timer;

@property (nonatomic, copy) NSString *alertMessage;  //提示消息，，群组、班级解散 。。。
@property (nonatomic , assign) CGFloat currentToolBarHeight;
@property (nonatomic , assign) CGFloat currentInputContainerHeight;

@property (nonatomic , strong) NSArray *deleteMsgs;
@property (nonatomic , assign) NSUInteger cyclicMessageCounter;

@property (nonatomic , strong) UIView *temporaryView;   //临时对话窗口提示View
//@property (nonatomic , strong) UILabel *temporaryLabel; //临时对话窗口提示Label

@end

@implementation DWDChatController

- (void)setUpBottomContainer{
    
    _bottomContainer.toUser = self.toUserId;  // 基础属性
    _bottomContainer.chatType = self.chatType;
    _bottomContainer.chatVc = self;
    
    _bottomContainer.speakBtn.chatVc = self;
    _bottomContainer.speakBtn.chatType = self.chatType;
    _bottomContainer.speakBtn.toUser = self.toUserId;
    
    _addFileContainerView.toUserId = self.toUserId;
    _addFileContainerView.chatType = self.chatType;
    _addFileContainerView.chatVc = self;
    
    _bottomContainer.delegate = self;    // 代理
    _bottomContainer.speakBtn.delegate = self;
    _bottomContainer.growingTextView.growingTextViewDelegate = self;
    
    _addFileContainerView.addFileDelegate = self;
    
}

#pragma mark - <DWDChatAddFileContainerDelegate>
- (void)chatAddFileContainerDidStoreImageToDiskWithMsg:(NSArray *)msgs placeHolderImage:(UIImage *)placeHolderImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < msgs.count; i++) {
            DWDBaseChatMsg *base = msgs[i];
            
            [self.chatData addObject:base];
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0];
            
            [self insertNewCellHeightAtIndex:insertIndexPath];
            [self.tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationNone]; // 刷新表格
            [self scrollContentToBottomWithAnimated:YES revise:0 delay:0.4];
        }
    });
    
}
- (void)chatAddFileContainerUploadImageFailureWithMsg:(DWDImageChatMsg *)imageMsg{
    NSUInteger index = [self.chatData indexOfObject:imageMsg];
    NSIndexPath *imageMsgIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[imageMsgIndexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)chatAddFileContainerDidTakePictureFromCameraWithMsg:(NSArray *)msgs{
    // 判断是否需要插入时间
    for (int i = 0; i < msgs.count; i++) {
        DWDBaseChatMsg *base = msgs[i];
        [self insertChatDataAndReload:base animate:YES isScroll:YES];
    }
}

- (void)videoBtnClick{
    [self dismissAddFileContainer];
    [self scrollContentToBottomWithAnimated:YES revise:0 delay:0.05];
}

- (void)videoRecordCompleteWithMsg:(DWDVideoChatMsg *)videoMsg ThumbImage:(UIImage *)thumbImage{
    [self insertChatDataAndReload:videoMsg animate:YES isScroll:YES];
    [self sendVideoMsgWithMsg:videoMsg thumbImage:thumbImage];
}

#pragma mark - <DWDChatBottomInputContaiunerDelegate>

- (void)tableViewChangeBottomCons:(CGFloat)cons{
    self.tableViewToBottom.constant = cons;
}

- (void)tableViewShouldChangeBottomConsAndReload:(CGFloat)changeCons{
    _tableViewToBottom.constant += (changeCons - _currentToolBarHeight);
    if (self.chatData.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
    _currentToolBarHeight = changeCons;
}
- (void)tableViewScroll{
    [self scrollContentToBottomWithAnimated:YES revise:0 delay:.05];
}
- (void)faceBtnClick{
    self.addFileToBottom.constant = 0;
    self.inputContainerToBottom.constant = self.addFileHeight.constant;
    self.tableViewToBottom.constant = self.addFileHeight.constant + DWDToolBarHeight;
    [self scrollContentToBottomWithAnimated:YES revise:0 delay:.05];
}
- (void)inputContainerChangeBtnClick{
    [self changeBtnClick:nil];
}
- (void)addFileBtnClick{
    self.isNeedDismissAddFileContainer = YES;
    self.addFileContainerView.hidden = NO;
    self.addFileToBottom.constant = 0;
    self.inputContainerToBottom.constant = self.addFileHeight.constant;
    self.tableViewToBottom.constant = self.addFileHeight.constant + DWDToolBarHeight;
    [self scrollContentToBottomWithAnimated:YES revise:0 delay:.05];
    if (self.isNeedLayoutAddFilePanelItmes) {
        self.isNeedLayoutAddFilePanelItmes = NO;
    }
}
- (void)addFileContainerDismiss{
    self.isNeedDismissAddFileContainer = NO;
    self.addFileContainerView.hidden = YES;
    self.addFileToBottom.constant = self.addFileHeight.constant;
    self.inputContainerToBottom.constant = 0;
    self.tableViewToBottom.constant = DWDToolBarHeight;
}
- (void)inputContainerSendTextMsg:(NSArray *)msgs{
    
    [self insertChatDataAndReload:msgs[0] animate:YES isScroll:0.4];
}

//  ****************    录音相关   ******************
#pragma mark - <SpeakImageViewDelegate>
- (void)speakImageViewStartRecordAudio{  // 刚开始录音 touch down
    if (_playingAudioCell) {
        if (_playingAudioCell.audioMsg.playing) {
            _playingAudioCell.audioMsg.playing = NO;
            [_playingAudioCell.animateImageView stopAnimating];
            [_audioPlayer stop];
        }
    }
}

- (void)speakImageViewLongpressActionWithMsg:(NSArray *)msgs{  // 长按触发 插入数据 刷新界面
    for (int i = 0; i < msgs.count; i++) {
        DWDBaseChatMsg *base = msgs[i];
        [self insertChatDataAndReload:base animate:YES isScroll:YES];
    }
    //    [self insertMessageAndJudgeInsertTimeNoteToInterfaceAndStoreToDatabaseWithMsg:audioMsg];
}

- (void)cancelRecordAndDeleteDatasActionsWithMsg:(DWDAudioChatMsg *)cancelAudioMsg{
    NSUInteger index = [self.chatData indexOfObject:cancelAudioMsg];
    if (index != 0 && [self.chatData[index - 1] isKindOfClass:[DWDTimeChatMsg class]]) {
        DWDTimeChatMsg *timeMsg = self.chatData[index-1];
        [self.chatData removeObject:timeMsg];
        [self.chatData removeObject:cancelAudioMsg];
        
        NSIndexPath *deleteIndex1 = [NSIndexPath indexPathForRow:index-1 inSection:0];
        NSIndexPath *deleteIndex2 = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndex1,deleteIndex2] withRowAnimation:UITableViewRowAnimationNone];
        
    }else{
        [self.chatData removeObject:cancelAudioMsg];
        NSIndexPath *deleteIndex2 = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndex2] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)uploadAudioMsgFailedWithMsg:(DWDAudioChatMsg *)audioMsg{
    NSInteger index = [self.chatData indexOfObject:audioMsg];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - <DWDChatImageCellTapContentDelegate>
- (void)imageCellTapContentToScaleWithImageCell:(DWDChatImageCell *)cell{  // 点击图片的cell
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.bottomContainer.growingTextView resignFirstResponder];
    // 点击cell时  把控制器所有image传入preview
    NSUInteger index = 0;
    NSMutableArray *imageMsgArray = [NSMutableArray array];
    for (int i = 0; i < self.chatData.count; i++) {
        DWDBaseChatMsg *base = self.chatData[i];
        if ([base.msgType isEqualToString:kDWDMsgTypeImage]) {
            [imageMsgArray addObject:base];
            if (indexPath.row == i) {
                index = imageMsgArray.count - 1;
            }
        }
    }
    
    [self exchangeStatusBar];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [DWDChatPreView showPreViewWithImageMsgs:imageMsgArray tapIndex:index inView:self.view];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - <system method>
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpBottomContainer];

    _currentToolBarHeight = 49;
    
    _topNoteContainer.userInteractionEnabled = YES;
    [_topNoteContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topContainerTap:)]];
    self.view.backgroundColor = DWDColorBackgroud;
    
    
    if (self.chatType == DWDChatTypeGroup ){//若groupEntity为nil,从本地库获取，获取若为nil,请求服务器接口更新本地通讯录，再重新从本地库获取
        if (!self.groupEntity) {
            self.groupEntity = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:self.toUserId];
            if(!self.groupEntity){
                [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                    self.groupEntity = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:self.toUserId];
                    self.title = self.groupEntity.groupName;
                    [self loadHistoryMessage];  //  加载历史消息记录
                } failure:^(NSError *error) {
                    
                }];
            }
        }
        self.title = self.groupEntity.groupName;
    }else if(self.chatType == DWDChatTypeClass){
        if(!self.myClass){
            self.myClass = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.toUserId myCustId:[DWDCustInfo shared].custId];
            if(!self.myClass){
                [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                    self.myClass = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.toUserId myCustId:[DWDCustInfo shared].custId];
                    self.title = self.myClass.className;
                    [self loadHistoryMessage];  //  加载历史消息记录
                } failure:^(NSError *error) {
                    
                }];
            }
        }
        self.title = self.myClass.className;
    }

    if (self.recentChatModel) self.title = [[DWDPersonDataBiz new] checkoutExistRemarkName:self.recentChatModel.remarkName nickname:self.recentChatModel.nickname];
    
    [self setUpBottomBarCons];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //input view setting
    
    self.isNeedDismissKeyboard = NO;
    self.isNeedDismissAddFileContainer = NO;
    self.isScrollByUser = NO;
    self.isNeedLayoutAddFilePanelItmes = YES;
    self.isNeedLayoutMultiEditingPanelItems = YES;
    self.addFileContainerView.hidden = YES;
    
    [self setUpTableView];
    [self registCell];
    
    if (![[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:_toUserId]) {
        [self setTemporaryChat];
    }
    
    // 临时对话窗口提示点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick:)];
    [self.temporaryView addGestureRecognizer:tap];
    
    
    // 监听通知
    [self observeNotification];
    
    _cellHeightCache = [NSMutableArray array];
    
    //data settings
    if (!self.chatClient) {
        _chatClient = [[DWDChatMsgClient alloc] init];
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadHistoryMessage];  //  加载历史消息记录
//    });
    
    [self setUpNavItem];
    
    // 先把发送错误的图片 从本地取出 加载到字典中 , 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict = [NSKeyedUnarchiver unarchiveObjectWithFile:DWDMsgCachFilePath];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriendSystemMessage:) name:kDWDSysmsgDeleteFriendChatKey object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self dismissAddFileContainer];
    [self setUpClassSpecify];
  
    _topNoteContainer.hidden = YES;
    //when first in, need revise scroll content offset   第一次加载view 让scrollview往下滚动一个导航栏距离
    if (self.tableView.contentSize.height >= DWDScreenH - self.bottomContainer.h - 64) {
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }
    
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId = [DWDCustInfo shared].custId;
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = _toUserId;
    // 清空badgeCount
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:_toUserId myCusId:[DWDCustInfo shared].custId success:^{
        
    } failure:^{
        
    }];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"ISCHAT":@1,@"SESSIONID":_toUserId} forKey:@"ISONCHAT"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [_bottomContainer.speakBtn.audioClient endPlay];
    [self.audioPlayer stop];
    
    if (_playingAudioCell) {
        [_playingAudioCell.animateImageView stopAnimating];
    }
    
    _playingAudioCell = nil;
    
    // 清空之前操作ID置为nil 表示已经执行过清空操作 , 退出程序时不需要再次处理
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId = nil;
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
    // 清空badgeCount
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:_toUserId myCusId:[DWDCustInfo shared].custId success:^{
        DWDLog(@"在chat controller 中 清除了%@ 的badgeCount" , _toUserId);
    } failure:^{
        
    }];
     [[NSUserDefaults standardUserDefaults] setObject:@{@"ISCHAT":@0,@"SESSIONID":@""} forKey:@"ISONCHAT"];
}

- (void)dealloc {
    // ios8 bug, use this code to fix this
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DWDLog(@"%@控制器销毁了",self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 清空之前操作ID置为nil 表示已经执行过清空操作 , 退出程序时不需要再次处理
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId = nil;
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
    // 清空badgeCount
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:_toUserId myCusId:[DWDCustInfo shared].custId success:^{
        DWDLog(@"在chat controller 中 清除了%@ 的badgeCount" , _toUserId);
    } failure:^{
        
    }];
}

#pragma mark - <cell点击代理>

- (void)interactiveChatCellDidClickContentWithCell:(DWDInteractiveChatCell *)cell{ // 点击语音cell 播放语音文件
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDBaseChatMsg *msg = self.chatData[indexPath.row];
    if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]) {
        DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
        
        if (audioMsg.read == NO) {
            audioMsg.read = YES;
            // 更新语音消息为已读  , 保存到数据库
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateAudioMessageTbWithMsg:audioMsg success:^{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSError *error) {
                DWDLog(@"更新语音消息失败");
            }];
        }
        
        DWDChatAudioCell *audioCell = (DWDChatAudioCell *)[self.tableView  cellForRowAtIndexPath:indexPath];
        NSURL __block *source;
        
        // 直接播放
        source = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", audioMsg.fileKey]]];
        
        [self animateAudioImageWithAudioCell:audioCell stopAnimatingWithTimeInterval:[audioMsg.duration doubleValue] currentIndexPath:indexPath audioURL:source];
    }
}
// 长按cell出现的menu点击
- (void)interactiveChatCellDidCopyWithCell:(DWDInteractiveChatCell *)cell{ // 拷贝
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (![self.chatData[indexPath.row] isKindOfClass:[DWDTextChatMsg class]]) return;
    
    DWDTextChatMsg *textMsg = self.chatData[indexPath.row];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = textMsg.content;
}

- (void)interactiveChatCellDidRelayWithCell:(DWDInteractiveChatCell *)cell{ // 转发
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg = self.chatData[indexPath.row];
    
//    DWDVideoChatMsg *viedo = (DWDVideoChatMsg *)self.chatData[indexPath.row];
//    
//    DWDLog(@"%@ " , viedo);
    
    DWDRelayOnChatController *relayOnChatVc = [[DWDRelayOnChatController alloc] init];
    relayOnChatVc.hidesBottomBarWhenPushed = YES;
    
    DWDNavViewController *navVc = [[DWDNavViewController alloc] initWithRootViewController:relayOnChatVc];
    
    [self presentViewController:navVc animated:YES completion:nil];
}

- (void)interactiveChatCellDidCollectWithCell:(DWDInteractiveChatCell *)cell{ // 收藏
    
}

- (void)interactiveChatCellDidDeleteWithCell:(DWDInteractiveChatCell *)cell{ // 删除消息
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self deleteMsgAndTimeNoteWithIndex:indexPath.row];  // 给deletedMsgs赋值
    
    NSString *title = nil;
    if (self.chatType == DWDChatTypeClass && [self.myClass.isMian isEqualToNumber:@1]) {  // 班主任删除班级中某条消息
        title = @"班主任删除消息将会把所有班级成员的该条消息删除";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除该条消息" message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 98;
    [alertView show];
}

- (void)interactiveChatCellDidRevokeWithCell:(DWDInteractiveChatCell *)cell{ // 主动撤回消息
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDLog(@"点击撤销");
    DWDBaseChatMsg *base = self.chatData[indexPath.row];
    
    // 语音撤回停止播放
    [_audioPlayer stop];
    
    [DWDChatDataHandler revokeMsgWithMsg:base touser:self.toUserId chatType:self.chatType success:^(NSString *note) {
        DWDNoteChatMsg *revokeNote = [DWDNoteChatMsg new];
        revokeNote.msgType = kDWDMsgTypeNote;
        revokeNote.fromUser = [DWDCustInfo shared].custId; // 全部构造为自己发的
        revokeNote.toUser = _toUserId;
        revokeNote.createTime = base.createTime;
        revokeNote.msgId = base.msgId;
        revokeNote.chatType = self.chatType;
        revokeNote.noteString = note;
        
        [self.chatData removeObject:base];
        
        [self.chatData insertObject:revokeNote atIndex:indexPath.row];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if (indexPath.row == self.chatData.count - 1) {  // 被撤回的是最后一条消息
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : note, @"type" : @2 , @"isAllMsgDeleted" : @0 , @"tid" : _toUserId}];
        }
    } failure:^(NSError *error) {
        [DWDProgressHUD showText:[NSString stringWithFormat:@"%@",[error localizedDescription]]];
    }];
    
}

- (void)interactiveChatCellDidClickMoreWithCell:(DWDInteractiveChatCell *)cell{ // 更多
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView setEditing:YES animated:YES];
    
    if (self.chatType == DWDChatTypeClass) {
        [self changeBtnClick];
    }
    
    if (self.isNeedLayoutMultiEditingPanelItems) {
        self.isNeedLayoutMultiEditingPanelItems = NO;
        const CGFloat newVlaue = (DWDScreenW - 4 * 60 - 2 * 20) / 3;
        for (NSLayoutConstraint *constraint in self.multiEditingItemPaddings) {
            constraint.constant = newVlaue;
        }
    }
    self.multiEditingPanelToBottom.constant = 0;
    self.returnItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"取消"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(cancleTableviewEditingModel:)];
}

/** 多选状态底部工具条 */
- (IBAction)multiShare:(id)sender {  // 分享
    DWDLog(@"do multi share here");
    [self cancleTableviewEditingModel:sender]; // 退出多选状态
}

- (IBAction)multiCollect:(id)sender {  // 收藏
    DWDLog(@"do multi share here");
    [self cancleTableviewEditingModel:sender];
}

- (IBAction)multiUpload:(id)sender {  // 上传
    DWDLog(@"do multi share here");
    [self cancleTableviewEditingModel:sender];
}

- (IBAction)multiDelete:(id)sender {  // 删除
    DWDLog(@"do multi share here");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"123" message:@"456" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 99;
    [alertView show];
}

- (void)animateAudioImageWithAudioCell:(DWDChatAudioCell *)currentAudioCell stopAnimatingWithTimeInterval:(NSTimeInterval )time currentIndexPath:(NSIndexPath *)currentIndexPath audioURL:(NSURL *)url{
    
    DWDChatAudioCell *lastAudioCell = _playingAudioCell;  // 上一个点击的语音cell
    DWDAudioChatMsg *lastAudioMsg = _playingAudioCell.audioMsg;
    DWDAudioChatMsg *currentAudioMsg = self.chatData[currentIndexPath.row];
    NSIndexPath *playAudioCellIndexPath = [self.tableView indexPathForCell:_playingAudioCell];
    
    if ([playAudioCellIndexPath isEqual:currentIndexPath]) { // 上一个 和 现在点的 是同一个
        if (lastAudioMsg.isPlaying) {
            [_audioPlayer stop];  // 结束上个语音的播放
            [lastAudioCell.animateImageView stopAnimating];
            lastAudioMsg.playing = NO;
            
            return;
        }
    }
    
    [_audioPlayer stop];
    [lastAudioCell.animateImageView stopAnimating];
    [_timer invalidate];
    _timer = nil;
    
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSError *playerError;
    
//    [self.audioClient playAudioWithURL:url];
    AVAudioPlayer *currentPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&playerError];
    
    if (playerError) {
        DWDLog(@"error creating player : %@", [playerError localizedDescription]);
        return;
    }
    
    [currentPlayer prepareToPlay];  // 播放当前的语音
    [currentPlayer play];
    
    currentAudioMsg.playing = YES;
    
    currentAudioCell.animateImageView.animationRepeatCount = 0;
    currentAudioCell.animateImageView.animationDuration = 0.5;
    [currentAudioCell.animateImageView startAnimating];
    
    NSDictionary *dict = @{@"currentAudioCell" : currentAudioCell,
                           @"currentPlayer" : currentPlayer,
                           @"currentAudioMsg" : currentAudioMsg};
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(stopAnimatingAndPlayAudio) userInfo:dict repeats:NO];
    
    // 修改播放的语音cell为当前的index
    _audioPlayer = currentPlayer;
    _playingAudioCell = currentAudioCell;
    
}

- (void)stopAnimatingAndPlayAudio{
    
    DWDChatAudioCell *currentAudioCell = _timer.userInfo[@"currentAudioCell"];
    AVAudioPlayer *currentPlayer = _timer.userInfo[@"currentPlayer"];
    DWDAudioChatMsg *currentAudioMsg = _timer.userInfo[@"currentAudioMsg"];
    
    [currentAudioCell.animateImageView stopAnimating];
    [currentPlayer stop];   // 结束上个语音的播放
    currentAudioMsg.playing = NO;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [_timer invalidate];
    _timer = nil;
}

// 当前响应者是inputTextView
- (void)growingTextViewIsFirstResponderWithCell:(DWDInteractiveChatCell *)cell{
    CGRect convertRect = [cell.menuTargetView convertRect:cell.menuTargetView.bounds toView:self.tableView];
    [self.bottomContainer.growingTextView showMenuWithTitles:cell.menuTitles rect:convertRect tableView:self.tableView cell:cell];
}

// 点击头像
- (void)interactiveChatCellDidClickAvatarWithCell:(DWDInteractiveChatCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDLog(@"click avatar at cell %ld", (long)indexPath.row);
    
    DWDBaseChatMsg *baseMsg = self.chatData[indexPath.row];
    if ([baseMsg.fromUser isEqual:[DWDCustInfo shared].custId]) {
        DWDPersonDataViewController *personVc = [[DWDPersonDataViewController alloc] init];
        personVc.custId = baseMsg.fromUser;
        personVc.personType = DWDPersonTypeMySelf;
        [self.navigationController pushViewController:personVc animated:YES];
    }else{
        DWDPersonDataViewController *personVc = [[DWDPersonDataViewController alloc] init];
        if (self.chatType == DWDChatTypeClass && [self.myClass.isMian isEqualToNumber:@1]) {
            personVc.needShowSetGag = YES;
            personVc.classId = self.myClass.classId;
        }
        personVc.custId = baseMsg.fromUser;
        [self.navigationController pushViewController:personVc animated:YES];
    }
}

- (void)interactiveChatCellDidMutlEditingSelectedWithCell:(DWDInteractiveChatCell *)cell{ // 多选状态下代理方法  修改每个被多选的模型属性
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDLog(@"mutl selected at %ld", (long)indexPath.row);
    DWDBaseChatMsg *msg = self.chatData[indexPath.row];
    msg.isMutlSelected = YES;
    [self.multSelectMessages addObject:msg];
}

- (void)interactiveChatCellDidMutlEditingDisselectedWithCell:(DWDInteractiveChatCell *)cell{ // 多选状态下代理方法   取消每个被多选的模型 , 设置属性
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDLog(@"mutl disselected at %ld", (long)indexPath.row);
    DWDBaseChatMsg *msg = self.chatData[indexPath.row];
    msg.isMutlSelected = NO;
    [self.multSelectMessages removeObject:msg];
}

// 重新发送
- (void)interactiveChatCellDidClickErrorImageViewWithCell:(DWDInteractiveChatCell *)cell{ // 点击了错误提示的image
    DWDLogFunc;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"是否要重新发送?" message:@"请选择:" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"重新发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        DWDBaseChatMsg *msg = self.chatData[indexPath.row];
        msg.state = DWDChatMsgStateSending;
        msg.errorToSending = YES;
        // 更新UI 和 数据库
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:DWDChatMsgStateSending WithMsgId:msg.msgId toUserId:_toUserId chatType:self.chatType success:^{
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        } failure:^(NSError *error) {
            
        }];
        
        NSTimeInterval timeinterval;
        // 发送消息
        if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
            DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
            [self sendTextMsgWithMsg:textMsg];
            
            timeinterval = 40.0;
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
            DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
            
            BOOL isMulChat = self.chatType == DWDChatTypeFace ? NO : YES;
            [_bottomContainer.speakBtn uploadAndSendAudioMsg:audioMsg mutableChat:isMulChat];
            
            timeinterval = 40.0;
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
            DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
            
            // 异步上传
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.addFileContainerView uploadImageToAliyunWithImageMsg:imageMsg];
            });
            
            timeinterval = 300.0;
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]){
            
            DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)msg;
            NSString * path = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder"] stringByAppendingPathComponent:videoMsg.thumbFileKey];
            UIImage *thumbImage = [UIImage imageWithContentsOfFile:path];
            [self sendVideoMsgWithMsg:videoMsg thumbImage:thumbImage];
            timeinterval = 300.0;
        }
        
        // 重启计时器
        // 消息内容缓存过了 不再需要缓存内容
        
        DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:timeinterval target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : msg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // 加入主运行循环
        [timerManager.timerCachDict setObject:timer forKey:msg.msgId];  // 缓存超时定时器
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - <数据源和代理>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    DWDBaseChatMsg *msg = self.chatData[indexPath.row];
    
    if ([msg.msgType isEqualToString:kDWDMsgTypeTime]) {  // 时间的cell
        
        DWDTimeChatMsg *timeMsg = (DWDTimeChatMsg *)msg;
        
        DWDChatTimeCell *timeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatTimeCell class])];
        
        NSString *timeString = [NSString judgeTimeStringWithStringForChatTimeNote:timeMsg.createTime];
        
        timeCell.contentLabel.text = timeString;//msg.createTime;
        
        timeCell.indexPath = indexPath;
        
        cell = timeCell;
        
    }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){  // 提示的Label
        
        DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
        
        DWDChatNoteCell *noteCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatNoteCell class])];
        
        noteCell.contentLabel.text = noteMsg.noteString;
        
        noteCell.indexPath = indexPath;
        
        cell = noteCell;
    }else {  // 传模型获取消息的cell
        
        DWDInteractiveChatCell *chatCell = [self getCellWithData:msg indePath:indexPath];
        
        chatCell.growingTextView = self.bottomContainer.growingTextView;
        chatCell.chatType = self.chatType;
        chatCell.createTime = msg.createTime;
        
        cell = chatCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chatType == DWDChatTypeClass) {
        if (_myClassChatBottomView.menu) {
            [_myClassChatBottomView.menu dismiss];
        }
        [self.view endEditing:YES];
    }
}

// 这里也调了一次 getcell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cellHeightCache.count > indexPath.row) {
        NSNumber *heightNum = self.cellHeightCache[indexPath.row];
        if (heightNum && [heightNum floatValue] != 0) return [heightNum floatValue];
    }
    
    CGFloat height;
    DWDBaseChatMsg *msg = self.chatData[indexPath.row];
    
    if ([msg.msgType isEqualToString:kDWDMsgTypeTime]) {  // 时间的cell
        
        DWDChatTimeCell *timeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatTimeCell class])];
        timeCell.contentLabel.text = @"time cell";//msg.receiveDate;
        height = [timeCell getHeight];
        
    }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){
        
        DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
        
        DWDChatNoteCell *noteCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatNoteCell class])];
        noteCell.contentLabel.text = noteMsg.noteString;//msg.receiveDate;
        
        height = [noteCell getHeight];
    
    }else {  //  聊天cell
        
        DWDInteractiveChatCell *prototypeCell = [self getCellWithData:msg indePath:indexPath];
        height = [prototypeCell getHeight];
        
    }
    
    [self insertNewCellHeightAtIndex:indexPath];
    
    return height;
}

// 编辑模式时该row背景是否锯齿状
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - scrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    if (_myClassChatBottomView.menu) {
        [_myClassChatBottomView.menu dismiss];
    }
    self.isScrollByUser = YES;
    if (self.isNeedDismissKeyboard && scrollView == self.tableView) {
        self.dismissKeyboardType = DWDDismissKeyboardDefault;
        [self.bottomContainer.growingTextView resignFirstResponder];
    }
    
    [self dismissAddFileContainer];
    
    [self.addFileContainerView.videoRecordView dismissCamera];
}

//发送视频
- (void)sendVideoMsgWithMsg:(DWDVideoChatMsg *)videoMsg thumbImage:(UIImage *)thumbImage
{
    [_addFileContainerView uploadVideoWithMsg:videoMsg thumbImage:thumbImage];
}

#pragma mark - notification holder
- (void)keyboardAppearance:(NSNotification *)notification {
    
    self.isNeedDismissKeyboard = YES;
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyBoardFrame =  [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.inputContainerToBottom.constant = keyBoardFrame.size.height;

    self.tableViewToBottom.constant = keyBoardFrame.size.height + self.bottomContainer.h;
    
    [self scrollContentToBottomWithAnimated:YES revise:0 delay:.05];
}

- (void)keyboardDismiss:(NSNotification *)notification {
    
    self.isNeedDismissKeyboard = NO;
    self.inputContainerToBottom.constant = 0;
    
    CGFloat containerHeightConstant;
    CGFloat tableViewToBottomConstant;
    
    switch (self.dismissKeyboardType) {
        
        case DWDDismissKeyboardFromReturnKey:
            
            containerHeightConstant = DWDToolBarHeight;
            tableViewToBottomConstant = DWDToolBarHeight;
            
            break;
            
        case DWDDismissKeyboardFromSwitchToTextInput:
            
            containerHeightConstant = self.inputContainerHeightBackup;
            tableViewToBottomConstant = self.inputContainerHeightBackup - DWDToolBarHeight;
            break;
            
        case DWDDismissKeyboardFromSwitchToVocieInput:
            
            containerHeightConstant = DWDToolBarHeight;
            tableViewToBottomConstant = DWDToolBarHeight;
            
            break;
            
        default:
            
            containerHeightConstant = self.bottomContainer.h;
            tableViewToBottomConstant = DWDToolBarHeight;
            break;
    }
    
    self.bottomContainer.h = containerHeightConstant;
    self.tableViewToBottom.constant = tableViewToBottomConstant;
    
}

/** 更改聊天Title */
- (void)updateChatTitle:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    
    if (self.toUserId == dict[@"custId"]) {
         self.title = dict[@"title"];
    }
   
}

/** 更改显示 IsShowNick */
- (void)updateChatIsShowNick:(NSNotification *)noti
{
   self.myClass.isShowNick = noti.userInfo[@"isShowNick"];
    self.groupEntity.isShowNick = noti.userInfo[@"isShowNick"];
    
    //更改会话列表中的isShowNick
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateRecentWithMyCustId:[DWDCustInfo shared].custId custId:self.toUserId isShowNick:noti.userInfo[@"isShowNick"]];
    
    [self.tableView reloadData];
}

/** 刷新数据 显示系统消息 谁谁加入群组、班级 */
- (void)reloadSystemMessage:(NSNotification *)noti
{
    DWDNoteChatMsg *noteChatMsg = noti.userInfo[@"msg"];
    
    if (noteChatMsg.chatType == self.chatType && [self.toUserId isEqual:noteChatMsg.toUser])
    {
        DWDNoteChatMsg *noteChatMsg = noti.userInfo[@"msg"];
        BOOL isInsert = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFindOutTimeMsgDESCOrderByCreateTimeLessThanTimeStamp:noteChatMsg.createTime tableName:noteChatMsg];
        if (isInsert) {
            DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:noteChatMsg.createTime chatType:self.chatType];
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:timeMsg success:^{
                
            } failure:^(NSError *error) {
                
            }];
            [self insertChatDatasAndReload:@[timeMsg , noteChatMsg]];
        }else{
            [self insertChatDataAndReload:noteChatMsg animate:YES isScroll:YES];
        }
    }
    
}
// 通知
- (void)reloadTableData{
    [self.tableView reloadData];
}

/** 更改 实时更新 群主更改群名称 */
- (void)updateGroupName:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    //判断是否为 需要更新的id
    if([dict[@"operationId"] isEqual:self.toUserId])
    {
        self.title = dict[@"changeNickname"];
        if (self.chatType == DWDChatTypeGroup) {
            self.groupEntity.groupName = dict[@"changeNickname"];
        }
    }
}

- (void)updateContactName:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    //判断是否为 需要更新的id
    if([dict[@"operationId"] isEqual:self.toUserId])
    {
        self.title = dict[@"changeNickname"];
    }
}

/** 更改 实时更新 群主更改联系人头像 */
- (void)updateContactPhotoKey:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    //判断是否为 需要更新的id
    if([dict[@"operationId"] isEqual:self.toUserId])
    {
        for (DWDBaseChatMsg *msg in self.chatData) {
            ![msg.fromUser isEqual:[DWDCustInfo shared].custId] ? msg.photohead.photoKey = dict[@"changePhotoKey"] : nil;
        }
        [self.tableView reloadData];
    }
}

//处理监听听筒、扬声器触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else  // 离开面部
    {
        if (_playingAudioCell) {
            DWDAudioChatMsg *audioMsg = _playingAudioCell.audioMsg;
            if (audioMsg.playing == NO) {
                //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
        }
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

/** 点击预览大图,返回聊天界面,恢复状态栏 */
- (void)preViewImageViewTap{
    [self exchangeStatusBar];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)preViewImageViewRelayToSomeone{
    // 预览大图时转发给朋友
    DWDRelayOnChatController *relayOnChatVc = [[DWDRelayOnChatController alloc] init];
    relayOnChatVc.hidesBottomBarWhenPushed = YES;
    
    DWDNavViewController *navVc = [[DWDNavViewController alloc] initWithRootViewController:relayOnChatVc];
    
    [self presentViewController:navVc animated:YES completion:nil];
}

#pragma mark - UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        [self cancleTableviewEditingModel:nil];
        if (buttonIndex == 1) {
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:_toUserId msgs:self.multSelectMessages chatType:_chatType success:^{
                [self.chatData removeObjectsInArray:self.multSelectMessages];
                [self.tableView reloadData];
                
                [DWDProgressHUD showText:@"已删除选中消息" afterDelay:1.5];
            } failure:^(NSError *error) {
                
            }];
        }
    }else if (alertView.tag == 98) {
        if (buttonIndex == 1) {
            DWDBaseChatMsg *deleteRealMsg;
            
            NSMutableArray *deleteIndexPaths = [NSMutableArray array];
            for (DWDBaseChatMsg *base in self.deleteMsgs) {
                NSUInteger index = [self.chatData indexOfObject:base];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [deleteIndexPaths addObject:indexPath];
                
                if (![base isKindOfClass:[DWDTimeChatMsg class]]) {
                    deleteRealMsg = base;
                }
                
                // 判断主动删除的是否最后一条消息
                if (index == self.chatData.count - 1) {
                    DWDBaseChatMsg *backForwardMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchChatMsgWithMsg:base toUser:_toUserId chatType:_chatType];
                    
                    
                    // 向上取不出消息 , 删除的就是所有历史消息的第一条 同时是最后一条
                    if (backForwardMsg == nil) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : @"" , @"type" : @1 , @"isAllMsgDeleted" : @1 , @"tid" : _toUserId}];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : backForwardMsg , @"type" : @1 , @"isAllMsgDeleted" : @0 , @"tid" : _toUserId}];
                    }
                    
                }
            }
            
            [DWDProgressHUD showText:@"已删除消息" afterDelay:1.5];
            
            // 班主任删除班级中某条消息 (当前用户为班主任时)
            if (self.chatType == DWDChatTypeClass && [self.myClass.isMian isEqualToNumber:@1]) {
                NSDictionary *params = @{@"msgIds" : @[deleteRealMsg.msgId],
                                         @"tid" : _toUserId,
                                         @"cid" : [DWDCustInfo shared].custId,
                                         @"type" : @1,
                                         @"chatType" : @(self.chatType)};
                
                [[HttpClient sharedClient] postApi:@"short/groupchat/deleteMsg" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                    
                    if ([responseObject[@"result"] isEqualToString:@"1"]) {
                        [DWDProgressHUD showText:@"所有班级成员已删除此消息"];
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:_toUserId msgs:self.deleteMsgs chatType:_chatType success:^{
                            [self.chatData removeObjectsInArray:self.deleteMsgs];
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //reload 这样性能不太好，但为了不闪退只能这样写了。后继会重构，期待！
                               // [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView reloadData];
                            }); 
                         
                        } failure:^(NSError *error) {
                            
                        }];
                    }
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [DWDProgressHUD showText:@"删除失败"];
                }];
            }else{
                [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:_toUserId msgs:self.deleteMsgs chatType:_chatType success:^{
                    [self.chatData removeObjectsInArray:self.deleteMsgs];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                    });
                    
                } failure:^(NSError *error) {
                    
                }];
            }
            
        }
    }else{
        if (buttonIndex == 0) {
            [self backViewController];
        }
    }
}

#pragma mark - push groupInfoViewController
- (void)pushCustInfoViewControllerAction
{
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    if ([[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:_toUserId]) {
        vc.personType = DWDPersonTypeIsFriend;
    } else {
        vc.personType = DWDPersonTypeIsStrangerAdd;
    }
    vc.custId = self.toUserId;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)pushGroupInfoViewControllerAction
{
    DWDGroupInfoViewController *vc = [[DWDGroupInfoViewController alloc]init];
    vc.groupModel = self.groupEntity;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushClassInfoViewControllerAction{
    
    DWDClassMainViewController *vc = [[DWDClassMainViewController alloc] init];
    vc.classModel = self.myClass;
    [self.navigationController pushViewController:vc animated:YES];
    
    if (_myClassChatBottomView.menu) {
        _myClassChatBottomView.menu.hidden = YES;
    }
    if (_myClassChatBottomView) {
        _myClassChatBottomView.hidden = YES;
    }
}

#pragma mark - <私有方法>
- (void)deleteFriendSystemMessage:(NSNotification *)noti {
    DWDSysMsg *sysMsg = noti.userInfo[@"kDWDSysmsgDeleteFriendChatKey"];
    if ([sysMsg.entity.custId isEqualToNumber:_toUserId]) {
        if (sysMsg.entity.smartUserRef) {
            [self setTemporaryChat];
        }
    }
}

// 插入数据模型并刷新表格
- (void)insertChatDataAndReload:(DWDBaseChatMsg *)msg animate:(BOOL)animated isScroll:(BOOL)isScroll{  // 传进来的是新建的msg  时间是新的
    [self.chatData addObject:msg];
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0];
    [self insertNewCellHeightAtIndex:insertIndexPath];
    [self.tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationNone]; // 刷新表格
    
    if (isScroll) {
      [self scrollContentToBottomWithAnimated:animated revise:0 delay:0.4];
    }
}

- (void)addRefreshMsgsAndReload:(NSArray *)datas{
    for (int i = (int)(datas.count - 1); i >= 0; i--) {
        DWDBaseChatMsg *msg = datas[i];
        // 插入高度0的值到数组
        [self.chatData addObject:msg];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0];
        [self insertNewCellHeightAtIndex:insertIndexPath];
    }
    [self sortArrayByCreateTime];
    [self.tableView reloadData];
    if (self.tableView.contentOffset.y >= self.tableView.contentSize.height - DWDScreenH - self.bottomContainer.h - 50) {
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }
}

- (void)insertChatDatasAndReload:(NSArray *)datas{
    for (int i = 0; i < datas.count; i++) {
        DWDBaseChatMsg *msg = datas[i];
        // 插入高度0的值到数组
        [self.chatData addObject:msg];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0];
        [self insertNewCellHeightAtIndex:insertIndexPath];
    }
    [self sortArrayByCreateTime];
    [self.tableView reloadData];
    
    DWDInteractiveChatCell *cell = [[self.tableView visibleCells] lastObject];
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    if (datas.count == 2 && cellIndexPath.row == self.chatData.count - 3) {
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }else if (datas.count == 2 && cellIndexPath.row == self.chatData.count - 2){
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }else if (datas.count == 1 && cellIndexPath.row == self.chatData.count - 2){
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }else if (datas.count == 1 && cellIndexPath.row == self.chatData.count - 1){
        [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
    }
}

- (void)insertEnterAppChatDatasAndReload:(NSArray *)datas{
    for (int i = 0; i < datas.count; i++) {
        DWDBaseChatMsg *msg = datas[i];
        // 插入高度0的值到数组
        [self.chatData addObject:msg];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0];
        [self insertNewCellHeightAtIndex:insertIndexPath];
    }
    [self sortArrayByCreateTime];
    [self.tableView reloadData];
    
    [self scrollContentToBottomWithAnimated:NO revise:0 delay:0.4];
}

- (void)dismissAddFileContainer {
    
    self.isNeedDismissAddFileContainer = NO;
    self.addFileContainerView.hidden = YES;
    self.addFileToBottom.constant = self.addFileHeight.constant;
    self.inputContainerToBottom.constant = 0;
    self.bottomContainer.faceView.transform = CGAffineTransformIdentity;
    self.tableViewToBottom.constant = DWDToolBarHeight;
}
- (void)backViewController
{
    //发送通知、是否刷新 会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
    if (self.lastVCisClassInfoVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
//.35 is correct minmua number, i do not konw why
- (void)scrollContentToBottomWithAnimated:(BOOL)animated revise:(CGFloat)revise delay:(CGFloat)delay{
    
    // 延迟 0.1 因为三方键盘弹出的时候 会有3个通知 , scrollview 会短时间多次滚动 , 其他模块的滚动不延迟也没有问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2),
                   
                   dispatch_get_main_queue(), ^(){
    
                       if (self.chatData.count >= 1) {
                           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                       }
                   });
}

//切换status bar的hidden 状态
- (void)exchangeStatusBar {
    UIViewController *vc = self;
    Class class = object_getClass((id)vc);
    SEL originSEL;
    SEL swizzlingSEL = @selector(kk_hideStatusBar);
    if (class_respondsToSelector(class, @selector(prefersStatusBarHidden))) {
        originSEL = @selector(prefersStatusBarHidden);
    } else {
        return;
    }
    Method originMethod = class_getInstanceMethod(class, originSEL);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSEL);
    
    BOOL addMethod = class_addMethod(class, originSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    
    if (addMethod) {
        class_replaceMethod(class, swizzlingSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzlingMethod);
    }
}

// 下拉刷新
- (void)headerRefresh{
//    [DWDChatDataHandler handlerUnreadMessageWithTouser:_toUserId chatType:_chatType tableView:self.tableView chatDatas:self.chatData success:^(NSArray *handleDatas) {
//        [self addRefreshMsgsAndReload:handleDatas];
//    }];
    DWDBaseChatMsg *first = [self.chatData firstObject];
    [self fetchMsgsWithBeginningTime:first.createTime];
}

// 加载历史消息记录
- (void)loadHistoryMessage{
//    [DWDChatDataHandler handlerHistoryMessageWithtoUser:_toUserId chatType:_chatType success:^(NSArray *handleDatas) {
//        [self insertChatDatasAndReload:handleDatas];
//    }];
//    NSMutableArray *historyArr = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchHistoryMessageWithToId:_toUserId chatType:_chatType fetchCount:10];
    [self fetchMsgsWithBeginningTime:nil];
    
}

- (void)fetchMsgsWithBeginningTime:(NSNumber *)beginningCreateTime{
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:beginningCreateTime friendId:_toUserId chatType:_chatType fetchCount:@10 success:^(NSMutableArray *chatSessions) {
        
        if (chatSessions.count == 0) { // 数据库没有数据
            MJRefreshHeader *header = (MJRefreshHeader *)self.tableView.tableHeaderView;
            [header endRefreshing];
            self.cyclicMessageCounter = 0;
            return;
        }
        
        NSMutableArray *allMsgs = [NSMutableArray array];
        
        NSMutableArray *visulableArray = [self visulableArrayAboutDeletedMsgWithOriginArray:chatSessions];
        [allMsgs addObjectsFromArray:visulableArray];
        [self sortArrayByCreateTimeWithArray:chatSessions];
        
        DWDBaseChatMsg *base = [chatSessions firstObject];
        if ([base.unreadMsgCount integerValue] > 0) { // 不管有多少 全部请求下来
            
            // 请求未读消息
            [DWDChatDataHandler fetchUnreadMsgFromServerWithTid:_toUserId chatType:_chatType msgId:base.msgId fetchCount:[base.unreadMsgCount integerValue] success:^(NSMutableArray *handleDatas) {
                [allMsgs addObjectsFromArray:handleDatas];
                [self sortArrayByCreateTimeWithArray:allMsgs];
                // 构建时间提示到界面显示
                NSArray *arr = [self insertTimeNoteToVisulableDatas:allMsgs];
                [self insertChatDatasAndReload:arr];
                MJRefreshHeader *header = (MJRefreshHeader *)self.tableView.tableHeaderView;
                [header endRefreshing];
                self.cyclicMessageCounter = 0;
            }];
            
        }else{ // 没有遇到标记 直接可以显示  如果有10条以上 , 连续10条被删除了 就会有bug 不重构则不处理
            
            if (visulableArray.count == 0) { // 表示既没有未读 而且连续多条被删除 , 只有连续1000条消息都被删除了 且中间没有未读 会出现bug <<后台不重构则不改>>
                if (self.cyclicMessageCounter == 100) {
                    return;
                }
                [self fetchMsgsWithBeginningTime:base.createTime]; //递归获取
                self.cyclicMessageCounter++;
                MJRefreshHeader *header = (MJRefreshHeader *)self.tableView.tableHeaderView;
                [header endRefreshing];
                
            }else{
                // 构建时间提示到界面显示
                [self sortArrayByCreateTimeWithArray:allMsgs];
                NSArray *arr = [self insertTimeNoteToVisulableDatas:allMsgs];
                [self insertChatDatasAndReload:arr];
                MJRefreshHeader *header = (MJRefreshHeader *)self.tableView.tableHeaderView;
                [header endRefreshing];
                self.cyclicMessageCounter = 0;
            }
            
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (NSMutableArray *)visulableArrayAboutDeletedMsgWithOriginArray:(NSArray *)originArray{
    NSMutableArray *results = [NSMutableArray array];
    for (int i = 0; i < originArray.count; i++) {
        DWDBaseChatMsg *base = originArray[i];
        if (base.state != DWDChatMsgStateDeleted) {
            [results addObject:base];
        }
    }
    return results;
}

- (NSArray *)insertTimeNoteToVisulableDatas:(NSArray *)chatdatas{
    NSMutableArray *allMsgs = [NSMutableArray array];
    long long timeInterval = self.chatType == DWDChatTypeFace ? 180 : 120;
    
    for (int i = 0; i < chatdatas.count; i++) {
        if (i == chatdatas.count - 1 && i != 0) {  // 如果一共只有一个 也要加时间
            break;
        }
        
        DWDBaseChatMsg *current = chatdatas[i];
        DWDBaseChatMsg *next = chatdatas.count == 1 ? nil : chatdatas[i+1];
        
        long long currentTime = [current.createTime longLongValue] / 1000;
        long long nextTime = chatdatas.count == 1 ? MAXFLOAT : [next.createTime longLongValue] / 1000;
        
        if (nextTime - currentTime > timeInterval && chatdatas.count != 1) {
            DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:next.createTime chatType:_chatType];
            [allMsgs addObject:timeMsg];
        }
        
        if (i == 0) {
            DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:current.createTime chatType:_chatType];
            [allMsgs addObject:timeMsg];
        }
    }
    [allMsgs addObjectsFromArray:chatdatas];
    [self sortArrayByCreateTimeWithArray:allMsgs];
    return allMsgs;
}

- (DWDTimeChatMsg *)createTimeMsgWithFromId:(NSNumber *)from toId:(NSNumber *)toId aboveCreateTime:(NSNumber *)createTime chatType:(DWDChatType)chatType{
    DWDTimeChatMsg *timeMsg = [[DWDTimeChatMsg alloc] init];
    timeMsg.fromUser = from;
    timeMsg.toUser = toId;
    timeMsg.msgType = kDWDMsgTypeTime;
    timeMsg.createTime = @([createTime longLongValue] - 1);
    timeMsg.chatType = chatType;
    return timeMsg;
}

- (void)sortArrayByCreateTime{
    [self.chatData sortUsingComparator:^NSComparisonResult(DWDBaseChatMsg *obj1, DWDBaseChatMsg *obj2) {
        
        if ([obj1.createTime compare:obj2.createTime] == NSOrderedAscending) {
            return NSOrderedAscending;
        }else if ([obj1.createTime compare:obj2.createTime] == NSOrderedSame){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
}

- (void)sortArrayByCreateTimeWithArray:(NSMutableArray *)array{
    [array sortUsingComparator:^NSComparisonResult(DWDBaseChatMsg *obj1, DWDBaseChatMsg *obj2) {
        
        if ([obj1.createTime compare:obj2.createTime] == NSOrderedAscending) {
            return NSOrderedAscending;
        }else if ([obj1.createTime compare:obj2.createTime] == NSOrderedSame){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
}

- (void)insertNewCellHeightAtIndex:(NSIndexPath *)insertIndex {
    [self.cellHeightCache insertObject:@0.0 atIndex:insertIndex.row];
}

- (void)cancleTableviewEditingModel:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    self.multiEditingPanelToBottom.constant = - self.multiEditingPanel.frame.size.height;
    self.navigationItem.leftBarButtonItem = self.returnItem;
}

// 根据给定模型  获取消息的cell  同时给cell设置数据
- (DWDInteractiveChatCell *)getCellWithData:(DWDBaseChatMsg *)msg indePath:(NSIndexPath *) indexPath{
    
    DWDInteractiveChatCell *result;
    if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {  //  文本
        
        DWDTextChatMsg *real = (DWDTextChatMsg *)msg;
        
        DWDChatTextCell *currentCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatTextCell class])];
        currentCell.userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;  // 给cell设置发送者状态
        currentCell.chatType = self.chatType;

        //文本转表情
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:real.content attributes:@{NSFontAttributeName : DWDFontBody,
                                                                             NSForegroundColorAttributeName : DWDColorContent}];
        
//        NSRange urlRange = [NSString urlRangeWithString:attStr.string];
//        NSRange phoneRange = [NSString phoneNumberRangeWithString:attStr.string];
        
        // 要改 不能在这里设置
        
//        if (urlRange.length > 0 && urlRange.length < 1000 && urlRange.location < 10000 && urlRange.length > 3) {
//            [attStr yy_setTextHighlightRange:urlRange color:DWDColorMain backgroundColor:[UIColor redColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//                
//                DWDLog(@"heheda heheda oooo");
//                
//            }];
//        }
        
//        if (phoneRange.length > 0 && phoneRange.length < 20 && phoneRange.location < 10000 && phoneRange.length > 10) {
//            [attStr yy_setTextHighlightRange:phoneRange color:DWDColorMain backgroundColor:[UIColor redColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//                
//                DWDLog(@"heheda heheda oooo");
//                
//            }];
//            
//        }
        
        currentCell.contentLabel.attributedText = attStr;
        
        result = currentCell;
        
    } else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]) {  //  图片
        
        DWDImageChatMsg *real = (DWDImageChatMsg *)msg;
        
        DWDChatCellUserType userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;
        
        DWDChatImageCell *currentCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatImageCell class])];
        currentCell.imageCellDelegate = self;
        currentCell.userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;  // 给cell设置发送者状态
         currentCell.chatType = self.chatType;
        currentCell.status = DWDChatCellStatusNormal;
        
        if (real.photo.chatThumbSize.height / real.photo.chatThumbSize.width > 4) {
            
            currentCell.imageSize = (CGSize){40, 160};
            
        } else if (real.photo.chatThumbSize.width / real.photo.chatThumbSize.height > 4) {
            
            currentCell.imageSize = (CGSize){160, 40};
            
        } else {
            currentCell.imageSize = [real.photo chatThumbSize];
        }
        
        currentCell.photo = real.photo;
        
        UIImage *origin;
        
        if (userType == DWDChatCellUserTypeMyself) {
            
            origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal"];
            UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
            
            currentCell.backgroundImageView.image = backgimg;
            
        }else{
            
            origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal_other"];
            UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
            
            currentCell.backgroundImageView.image = backgimg;
            
        }
        
        // 已下载过
        __block UIImage *placeHolderImage;
        
        if (!placeHolderImage) {
            placeHolderImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[real.photo chatThumbPhotoKey]];
        }
        
        if (!placeHolderImage) {
            placeHolderImage = [UIImage growUpRecordPlaceholderImageWithSize:[real.photo chatThumbSize]];
        }
        
        if (real.state == DWDChatMsgStateSending) {
            currentCell.contentImageView.image = placeHolderImage;
            currentCell.contentImageView.alpha = 0.6;
        }else{
            currentCell.contentImageView.alpha = 1.0;
            
            // 只能根据 240px * 240 来判断是不是"所谓的表情"
            NSString *imageOrEmotionKey = (real.photo.width == 120 && real.photo.height == 120) || (real.photo.width == 180 && real.photo.height == 180) ? [real.photo originKey] : [real.photo chatThumbPhotoKey];
            
            [currentCell.contentImageView sd_setImageWithURL:[NSURL URLWithString:imageOrEmotionKey] placeholderImage:placeHolderImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (!image) {
                    DWDMarkLog(@"imageFialed:%@ error : %@", [imageURL absoluteString] , error.localizedDescription);
                }
//                currentCell.contentImageView.userInteractionEnabled = YES;
            }];
        
        }
        currentCell.contentImageView.userInteractionEnabled = YES;
        result = currentCell;
        
    } else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]) {  //  语音
        
        DWDAudioChatMsg *real = (DWDAudioChatMsg *)msg;
        
        DWDChatCellUserType userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;
        
        DWDChatAudioCell *currentCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatAudioCell class])];
        
        currentCell.audioMsg = real;
        
        currentCell.userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;  // 给cell设置发送者状态
        
        currentCell.userType = userType;  // 给cell设置发送者状态
         currentCell.chatType = self.chatType;
        UIImage *origin;
        
        if (userType == DWDChatCellUserTypeMyself) {
            
            origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal"];
            UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
            
            currentCell.backgroundImageView.image = backgimg;
            
            currentCell.animateImageView.image = [UIImage imageNamed:@"ic_voice_me_normal"];
            
            currentCell.animateImageView.animationImages = [NSArray arrayWithObjects:
                                                            [UIImage imageNamed:@"ic_voice_me_normalone"],
                                                            [UIImage imageNamed:@"ic_voice_me_normaltwo"],
                                                            [UIImage imageNamed:@"ic_voice_me_normal"],nil];
        }else{
            
            origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal_other"];
            UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
            
            currentCell.backgroundImageView.image = backgimg;
            
            currentCell.animateImageView.image = [UIImage imageNamed:@"ic_voice_other_normal"];
            
            currentCell.animateImageView.animationImages = [NSArray arrayWithObjects:
                                                            [UIImage imageNamed:@"ic_voice_other_normalone"],
                                                            [UIImage imageNamed:@"ic_voice_other_normaltwo"],
                                                            [UIImage imageNamed:@"ic_voice_other_normal"],nil];
            
        }
        
        if (real.isRead) {
            currentCell.redCircleView.hidden = YES;
        }else{
            currentCell.redCircleView.hidden = NO;
        }
        
        if ([real.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发的语音
            if (real.state == DWDChatMsgStateSending) {
                currentCell.status = DWDChatCellStatusSending;
            }else{
                currentCell.status = DWDChatCellStatusNormal;
            }
        }else{
            currentCell.status = DWDChatCellStatusNormal;
        }
        
        
        CGFloat duration = [real.duration floatValue];
        int a = (int)(duration + 0.5);
        currentCell.audioDuration = a;
        
        currentCell.desLabel.text = [NSString stringWithFormat:@"%d″", a];
        
        result = currentCell;
        
    } else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]) {
        
        DWDVideoChatMsg *real = (DWDVideoChatMsg *)msg;
        
        DWDChatVideoCell *currentCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatVideoCell class])];
        currentCell.videoChatMsg = real;
        
        DWDChatCellUserType userType = [msg.fromUser isEqual: [DWDCustInfo shared].custId] ? DWDChatCellUserTypeMyself : DWDChatCellUserTypeOther;
        currentCell.userType = userType;
         currentCell.chatType = self.chatType;
        result = currentCell;
    }
    
    //   对模型的状态   进行再判断   给cell的状态赋值
    if (msg.state == DWDChatMsgStateSended) {  // 已发送
        result.status = DWDChatCellStatusNormal;
        [result UIPrepareForNormalStatus];
    }
    
    else if (msg.state == DWDChatMsgStateSending) {  // 正在发送
        result.status = DWDChatCellStatusSending;
        [result UIPrepareForSendingDataStatus];
    }
    
    else if (msg.state == DWDChatMsgStateError){  // 发送错误
        result.status = DWDChatCellStatusError;
        [result UIPrepareForErrorStatus];
    }
    
    result.delegate = self;
    //  result.isShowNickname = (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup);  // 是否是群聊 决定 是否展示nikename
    result.isMultEditingSelected = msg.isMutlSelected;  // 是否多选
    
    //    NSRange range = [result.nicknameLabel.text rangeOfString:@"frank"];  // 给昵称设置响应事件
    //    [result.nicknameLabel addLinkToURL:[NSURL  URLWithString:@"user://frank"] withRange:range];
    
    if (result.userType == DWDChatCellUserTypeMyself) {
        [result.avatarImgView sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:DWDDefault_MeBoyImage];
        
        //自己是不显示昵称的
        result.isShowNickname = NO;
    } else {
        [result.avatarImgView sd_setImageWithURL:[NSURL URLWithString:msg.photohead.photoKey] placeholderImage:DWDDefault_MeBoyImage];
        
        if (msg.remarkName.length > 0) {
            [result.nicknameLabel setText:msg.remarkName];
        }else{
            [result.nicknameLabel setText:msg.nickname];
        }
        
    }
    
    //群组、班级 成员设置是否显示群昵称
    if (self.chatType == DWDChatTypeGroup && result.userType == DWDChatCellUserTypeOther){
        result.isShowNickname = [self.groupEntity.isShowNick boolValue];
    }else if(self.chatType == DWDChatTypeClass && result.userType == DWDChatCellUserTypeOther){
        result.isShowNickname = [self.myClass.isShowNick boolValue];
    }
    return result;
}

- (void)deleteMsgAndTimeNoteWithIndex:(NSUInteger )index{
    
    DWDBaseChatMsg *current = self.chatData[index];
    if (index == self.chatData.count - 1) { // 当前界面最后一条
        
        if (index == 0) { // 也是当前界面的第一条
            self.deleteMsgs = @[current];
            return;
        }
        DWDBaseChatMsg *backMsg = self.chatData[index - 1];
        
        if ([backMsg isKindOfClass:[DWDTimeChatMsg class]]) { // 如果上一条是时间提示
            self.deleteMsgs = @[backMsg,current];
        }else{
            self.deleteMsgs = @[current];
        }
    }else{ // 删除的不是当前界面最后一条
        if (index == 0) { // 是当前界面的第一条
            self.deleteMsgs = @[current];
            return;
        }
        DWDBaseChatMsg *backMsg = self.chatData[index - 1];
        DWDBaseChatMsg *next = self.chatData[index + 1];
        if ([backMsg isKindOfClass:[DWDTimeChatMsg class]]) { // 如果前一条是时间
            if ([next isKindOfClass:[DWDTimeChatMsg class]]) { // 后一条也是时间
                self.deleteMsgs = @[backMsg , current];
            }else{ // 后一条不是时间 , 则判断该不该删
                long long nextTime = [next.createTime longLongValue] / 1000;
                long long currentMsgTime = [current.createTime longLongValue] / 1000;
                NSTimeInterval timeInterval = self.chatType == DWDChatTypeFace ? 180 : 120;
                
                if (nextTime - currentMsgTime < timeInterval) { // 短时间内发的消息 不删时间
                    self.deleteMsgs = @[current];
                }else{
                    self.deleteMsgs = @[backMsg , current];
                }
            }
        }else{ // 前一条不是时间
            self.deleteMsgs = @[current];
        }
    }
    
}

#pragma mark - <通知>

/** 有聊天消息被撤回 */
- (void)haveMsgRevoke:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DWDBaseChatMsg *msg = userInfo[@"revokeMsg"];
    NSString *note = userInfo[@"revokeNote"];
    
    if (msg.chatType != self.chatType) return;
    
    if (self.chatType == DWDChatTypeFace) {
        if (![msg.fromUser isEqual:_toUserId]) {
            return;
        }
    }else{
        if (![msg.toUser isEqual:_toUserId]){
            return;
        }
    }
    
    for (int i = (int)(self.chatData.count - 1); i >= 0; i--) {
        DWDBaseChatMsg *base = self.chatData[i];
        if ([base.msgId isEqualToString:msg.msgId]) {
            NSUInteger index = [self.chatData indexOfObject:base];
            [self.chatData removeObject:base];
            DWDNoteChatMsg *revokeNote = [DWDNoteChatMsg new];
            revokeNote.msgType = kDWDMsgTypeNote;
            revokeNote.fromUser = [DWDCustInfo shared].custId; // 全部构造为自己发的
            revokeNote.toUser = _toUserId;
            revokeNote.createTime = base.createTime;
            revokeNote.msgId = base.msgId;
            revokeNote.chatType = self.chatType;
            revokeNote.noteString = note;
            [self.chatData insertObject:revokeNote atIndex:index];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

/** 班级中聊天消息被班主任删除 */
- (void)deleteMsgByClassManager:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DWDBaseChatMsg *msg = userInfo[@"deletedMsg"];
    if (msg.chatType != self.chatType) return;
    
    if (self.chatType == DWDChatTypeFace) {
        if (![msg.fromUser isEqual:_toUserId]) {
            return;
        }
    }else{
        if (![msg.toUser isEqual:_toUserId]){
            return;
        }
    }
    // 寻找并删除界面中的这条消息
    for (int i = 0; i < self.chatData.count; i++) {
        DWDBaseChatMsg *base = self.chatData[i];
        if ([base.msgId isEqualToString:msg.msgId]) {
            NSUInteger deleteIndex = [self.chatData indexOfObject:base];
            
            [self deleteMsgAndTimeNoteWithIndex:deleteIndex];  // 给 deleteMsgs 赋值
            
            // 2. 删除界面数据
            [self.chatData removeObjectsInArray:self.deleteMsgs];
            
            // 3. 刷新界面
            NSMutableArray *deleteIndexPaths = [NSMutableArray arrayWithCapacity:2];
            for (DWDBaseChatMsg *base in self.deleteMsgs) {
                NSUInteger index = [self.chatData indexOfObject:base];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [deleteIndexPaths addObject:indexPath];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            });
            
        }
    }
}

// 收到新消息时的通知
- (void)receivedNewMsg:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    DWDBaseChatMsg *msg = userInfo[DWDReceiveNewChatMsgKey];
    
    if (msg.chatType != self.chatType) return;
    
    if (self.chatType == DWDChatTypeFace) {
        if (![msg.fromUser isEqual:_toUserId]) {
            return;
        }
    }else{
        if (![msg.toUser isEqual:_toUserId]){
            return;
        }
    }
//    DWDTimeChatMsg *timeMsg = userInfo[@"timeMsg"];
    if (self.chatData.count == 0) {
        DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:msg.createTime chatType:_chatType];
        [self insertChatDatasAndReload:@[timeMsg , msg]];
    }else{
        DWDBaseChatMsg *lastOnScreen = [self.chatData lastObject];
        long long timeInterval = self.chatType == DWDChatTypeFace ? 180 : 120;
        
        long long currentTime = [msg.createTime longLongValue] / 1000;
        long long nextTime = [lastOnScreen.createTime longLongValue] / 1000;
        
        if (nextTime - currentTime > timeInterval) {
            DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:msg.createTime chatType:_chatType];
            [self insertChatDatasAndReload:@[timeMsg , msg]];
        }else{
            [self insertChatDatasAndReload:@[msg]];
        }
    }
    
}

// 收到消息回执更改好了数据库  接到的通知  修改模型状态刷新UI
- (void)reveiveNewMsgReceipt:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    DWDChatMsgReceipt *msgReceipt = userInfo[DWDReceiveNewChatMsgKey];
    
    if (![msgReceipt.toUser isEqual:_toUserId]) return;  // 如果在班级成员中点入单人聊天 , 则内存中存在两个聊天控制器
    // 发送消息, 回执为1 , 保存消息到本地  7是禁言正常发送
    if ([msgReceipt.status isEqualToNumber:@1] || [msgReceipt.status isEqualToNumber:@7]){
        DWDBaseChatMsg *Msg;
        for (int i = (int)(self.chatData.count - 1); i >= 0; i--) {   //  最后一条消息有可能是别人发过来的
            Msg = self.chatData[i];
            if ([Msg.msgId isEqualToString:msgReceipt.msgId]) {
                Msg.state = DWDChatMsgStateSended;
                
                DWDLog(@"回执返回的时间戳 : %lld" , [msgReceipt.createTime longLongValue]);
                Msg.createTime = msgReceipt.createTime;
                
                /*******       时间提示的判断      ********/
                if (self.chatData.count <= 1) { // 直接插时间
                    DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:Msg.createTime chatType:_chatType];
                    [self insertChatDatasAndReload:@[timeMsg]];
                }else{ // 界面上至少有一条成功的消息
                   DWDBaseChatMsg *lastMsg = self.chatData[i-1];
                    long long timeInterval = self.chatType == DWDChatTypeFace ? 180 : 120;
                    
                    long long currentTime = [lastMsg.createTime longLongValue] / 1000;
                    long long nextTime = [Msg.createTime longLongValue] / 1000;
                    if (nextTime - currentTime > timeInterval) {
                        DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:_toUserId aboveCreateTime:Msg.createTime chatType:_chatType];
                        [self insertChatDatasAndReload:@[timeMsg]];
                    }
                }
                /*******       时间提示的判断      ********/
                
                if (Msg.errorToSending == YES) {
                    [self sortArrayByCreateTime];
                }
                break;
            }
        }
        
        NSUInteger index = [self.chatData indexOfObject:Msg];
        if (Msg.errorToSending) {
            [self.tableView reloadData];
            Msg.errorToSending = NO;
        }else{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        Msg.observing = NO;

        [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict removeObjectForKey:Msg.msgId];
        DWDLog(@"删除了缓存中的placeholder一次");
        
    }else if (![msgReceipt.status isEqualToNumber:@1]){  // 如果回执不是1 需要改成错误
        for (int i = (int)(self.chatData.count - 1); i >= 0; i--){
            DWDBaseChatMsg *Msg = self.chatData[i];
            
            if ([Msg.msgId isEqualToString:msgReceipt.msgId]) {
                
                Msg.state = DWDChatMsgStateError;
                NSUInteger index = [self.chatData indexOfObject:Msg];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
        }
        
        //如果回执是3，重新登录Xcom
        if([msgReceipt.status isEqualToNumber:@3])
        {
            //连接Scoket
            [[DWDChatClient sharedDWDChatClient] getConnect];
        }
        
        //如果回执是5， 对方之间不再是好友关系或不在群组里、班级里
        if([msgReceipt.status isEqualToNumber:@5])
        {
            
            NSString *errMsg = nil;
            if (self.chatType == DWDChatTypeFace)
            {
                errMsg = @"对方已不再是你好友";
            }
            else if (self.chatType == DWDChatTypeGroup)
            {
                errMsg = @"你已不在该群组";
            }
            else
            {
                errMsg = @"你已不在该班级";
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:errMsg
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //2.删除会话列表
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:self.toUserId  success:^{
                    // 发通知 刷新会话列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad
                                                                        object:nil
                                                                      userInfo:@{@"custId": self.toUserId}];
                    
                    //3. 删除会话历史聊天记录
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:self.toUserId
                                                                                              chatType:self.chatType
                                                                                               success:^{
                                                                                               }
                                                                                               failure:^(NSError *error) {
                                                                                               }];
                } failure:^{
                    
                }];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    }
}

/** 单例中收到回执 判断是否需要插入时间提示消息 */
- (void)needInsertTimeChatMsg:(NSNotification *)note{
    DWDTimeChatMsg *timeMsg = note.userInfo[@"timeMsg"];
    if ([timeMsg.toUser isEqual:_toUserId]) {
        [self insertChatDatasAndReload:[NSArray arrayWithObject:timeMsg]];
    }
}

/** 消息超时处理 能收到通知 即是发送超时*/
- (void)messageTimeOut:(NSNotification *)note{
    NSDictionary *userinfo = note.userInfo;
    if (![_toUserId isEqual:userinfo[@"toId"]]) return;
    for (int i = (int)(self.chatData.count - 1); i >= 0; i--){
        DWDBaseChatMsg *msg = self.chatData[i];
        if ([msg.msgId isEqualToString:userinfo[@"msgId"]]) {
            msg.state = DWDChatMsgStateError;
            NSUInteger index = [self.chatData indexOfObject:msg];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)insertUnreadMsg
{
    DWDBaseChatMsg *base = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchLastMsgWithToUser:_toUserId chatType:_chatType];
    
    if (base) {
        if ([base.unreadMsgCount integerValue] > 0) {
            
            [DWDChatDataHandler handlerUnreadMessageForEnterAppWithMsg:base success:^(NSArray *handleDatas) {
                [self insertEnterAppChatDatasAndReload:handleDatas];
            }];
        }else{
            [self insertChatDataAndReload:base animate:YES isScroll:YES];
        }
    }
    
}

- (void)changeBtnClick:(UIButton *)btn{
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view endEditing:YES];
        _myClassChatBottomView.y = DWDScreenH - _myClassChatBottomView.h - 64;
        _bottomContainer.hidden = YES;
        _tableViewToBottom.constant = self.myClassChatBottomView.h;
        [self dismissAddFileContainer];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.chatData.count >= 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

// 收到弹出菜单按钮点击时发出的通知,隐藏菜单
- (void)bottomViewHide{
    
    if (_myClassChatBottomView.menu) {
        _myClassChatBottomView.menu.hidden = YES;
    }
    if (_myClassChatBottomView) {
        _myClassChatBottomView.hidden = YES;
    }
}

// 在转发界面转发成功一条消息 , 判断是否转发给当前的toUser
- (void)relayControllerJudgeCurrentTouser:(NSNotification *)note{
    DWDBaseChatMsg *msg = note.userInfo[@"msg"];
    if (![msg.toUser isEqual:_toUserId]) return;
    
    [self insertChatDataAndReload:msg animate:YES isScroll:0.4];
}

#pragma mark - <DWDClassChatBottomViewDelegate>
// 弹出菜单的change按钮就点击发出的通知   让输入框view回正常状态
- (void)changeBtnClick{
    
//    if (![DWDCustInfo shared].isTeacher){  // 给幼儿园特殊处理
//        return;
//    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _myClassChatBottomView.y += pxToH(100);
        _bottomContainer.hidden = NO;
        self.tableViewToBottom.constant = self.bottomContainer.h;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.chatData.count >= 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatData.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });

}

#pragma mark - <Event Response>
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (_myClassChatBottomView.menu) {
        [_myClassChatBottomView.menu dismiss];
    }
}

- (void)topContainerTap:(UITapGestureRecognizer *)tap{
    DWDClassNotificationDetailController *notificationVc = [[DWDClassNotificationDetailController alloc] init];
    notificationVc.myClass = self.myClass;
    notificationVc.readed = _topNoteContainer.lastNote.last.readed;
    notificationVc.noticeId = _topNoteContainer.lastNote.last.noticeId;
    [self.navigationController pushViewController:notificationVc animated:YES];
}

- (void)sendTextMsgWithMsg:(DWDTextChatMsg *)textMsg{
    
    if (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup) {
        
        [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makePlainTextForO2M:textMsg]];
        
    }else{
        [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makePlainTextForO2O:textMsg]];
    }
}
#pragma mark - <getters>
- (NSMutableArray *)chatData{
    if (!_chatData) {
        _chatData = [NSMutableArray array];
    }
    return _chatData;
}

- (NSMutableArray *)multSelectMessages{
    if (_multSelectMessages == nil) {
        _multSelectMessages = [NSMutableArray array];
    }
    return _multSelectMessages;
}

- (NSCache *)placeHolderCach{
    if (!_placeHolderCach) {
        _placeHolderCach = [NSCache new];
    }
    return _placeHolderCach;
}
#pragma mark - <初始化>
- (void)registCell{
    [self.tableView registerClass:[DWDChatTextCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatTextCell class])];
    [self.tableView registerClass:[DWDChatImageCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatImageCell class])];
    [self.tableView registerClass:[DWDChatAudioCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatAudioCell class])];
    [self.tableView registerClass:[DWDChatTimeCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatTimeCell class])];
    [self.tableView registerClass:[DWDChatNoteCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatNoteCell class])];
    [self.tableView registerClass:[DWDChatVideoCell class] forCellReuseIdentifier:NSStringFromClass([DWDChatVideoCell class])];
}

- (void)setUpTableView{
    MJRefreshNormalHeader *refresh = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    [refresh setTitle:@"加载中.." forState:MJRefreshStateRefreshing];
    refresh.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.tableHeaderView = refresh;
    self.tableView.contentInset = UIEdgeInsetsMake(-refresh.h + 5 , 0, 0, 0);
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = DWDColorSeparator;
}

/** 设置导航栏按钮 */
- (void)setUpNavItem{
    
    //自定义导航栏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_return_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(backViewController)];
    
    //by Gatlin code
    if (self.chatType == DWDChatTypeFace) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(pushCustInfoViewControllerAction)];
        
    }else if(self.chatType == DWDChatTypeGroup) {
        
        //更改会话列表中的isShowNick
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateRecentWithMyCustId:[DWDCustInfo shared].custId custId:self.toUserId isShowNick:self.groupEntity.isShowNick];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(pushGroupInfoViewControllerAction)];
        
    } else if (self.chatType == DWDChatTypeClass){
        //更改会话列表中的isShowNick
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateRecentWithMyCustId:[DWDCustInfo shared].custId custId:self.toUserId isShowNick:self.myClass.isShowNick];
        
        if (self.lastVCisClassInfoVC) {
        }else{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"主页" style:UIBarButtonItemStylePlain target:self action:@selector(pushClassInfoViewControllerAction)];
        }
    }
}

// 如果是临时聊天就显示临时对话窗口提示
- (void)setTemporaryChat{
    if (self.chatType == DWDChatTypeFace) {
        [self.view insertSubview:self.temporaryView aboveSubview:self.tableView];
        self.tableViewTopCons.constant = 40;
    }
}

- (void)setUpBottomBarCons{
    if (self.chatType == DWDChatTypeClass) {
        [self.bottomContainer updateSubViewsConsForClassType];
    }else{
        [self.bottomContainer updateSubViewsConsForFaceAndGroupType];
        self.tableViewTopCons.constant = 0;
        self.topNoteContainer.hidden = YES;   // 如果是班级聊天, 控制顶部通知栏的显示
    }
}

- (void)setUpClassSpecify{
    if (self.chatType == DWDChatTypeClass) {
        if (_myClassChatBottomView.menu) {
            _myClassChatBottomView.menu.hidden = NO;
        }
        
        if (!_myClassChatBottomView) {
            DWDClassChatBottomView *bottomView = [[DWDClassChatBottomView alloc] initWithFrame:CGRectMake(0, DWDScreenH - pxToW(100) - 64, DWDScreenW, pxToW(100))];
            _myClassChatBottomView = bottomView;
            _myClassChatBottomView.myClass = self.myClass;
            bottomView.conversationVc = self;
            [self.view addSubview:bottomView];
        }else{
            _myClassChatBottomView.hidden = NO;
        }
        [[HttpClient sharedClient] getApi:@"NoticeRestService/getLast" params:@{@"custId" : [DWDCustInfo shared].custId, @"classId" : self.myClass.classId} success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDLastNoteModel *lastNote = [DWDLastNoteModel yy_modelWithJSON:responseObject[@"data"]];
            if (lastNote.last.creatTime.length > 0) {
                _topNoteContainer.lastNote = lastNote;
                _topNoteContainer.hidden = NO;
                _tableViewTopCons.constant = 100;
            }else{
                _topNoteContainer.hidden = YES;
                _tableViewTopCons.constant = 0;
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
}

- (void)observeNotification{
    // 弹出菜单的change按钮就点击发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBtnClick) name:DWDClassInfoBottomViewChangeBtnClick object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewHide) name:DWDClassInfoBottomViewAndMenuShouldHide object:nil];
    
    //handle notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppearance:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismiss:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMsg:) name:DWDReceiveNewChatMsgNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reveiveNewMsgReceipt:) name:DWDReceiveNewChatMsgReceiptNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageTimeOut:) name:@"message_timeout_notification" object:nil];
    
    //监听更改聊天Title
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatTitle:) name:@"updateChatTitle" object:nil];
    
    //监听是否显示昵称  // (哈哈哈)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatIsShowNick:) name:@"showNickNotification" object:@"chatShowNick"];
    
    //刷新控制器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"reloadTableData" object:nil];
    
    
    //监听 系统消息 谁谁加入、
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSystemMessage:)name:DWDNotificationSystemMessageReload object:nil];
    
    //监听 实时更新 群主更新群名称
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupName:) name:kDWDChangeGroupNicknameNotification object:nil];
    
    //添加监听 听筒与扬声器听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    //监听 实时更新 联系人昵称
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactName:) name:kDWDChangeContactNicknameNotification object:nil];
    
    //监听 实时更新 联系人头像
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactPhotoKey:) name:kDWDChangeContactPhotoKeyNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterAppHaveUnreadMsg:) name:kDWDNotificationEnterAppReloadUnreadMsg object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertUnreadMsg) name:kDWDNotificationInsertUnreadMsgToChatVC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preViewImageViewTap) name:kDWDNotificationChatPreViewCellImageViewTap object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preViewImageViewRelayToSomeone) name:kDWDNotificationChatPreViewCellDidRelayToSomeone object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayControllerJudgeCurrentTouser:) name:kDWDNotificationChatRelayJudgeCurrentTouser object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needInsertTimeChatMsg:) name:kDWDNotificationChatNeedInsertTimeMsg object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboardForVideoPlay) name:kDWDNotificationChatVideoPlay object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveMsgRevoke:) name:DWDNotificationHaveMsgRevoked object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMsgByClassManager:) name:DWDNotificationClassManagerDeleteMsg object:nil];
    
}

// 视频放大时收起键盘--fzg
- (void)dismissKeyboardForVideoPlay
{
    if (_myClassChatBottomView.menu) {
        [_myClassChatBottomView.menu dismiss];
    }
    if (self.isNeedDismissKeyboard) {
        self.dismissKeyboardType = DWDDismissKeyboardDefault;
        [self.bottomContainer.growingTextView resignFirstResponder];
    }
    
    [self dismissAddFileContainer];
    
    [self.addFileContainerView.videoRecordView dismissCamera];
}

// 临时聊天窗口提示View-
- (UIView *)temporaryView
{
    if (!_temporaryView) {
        _temporaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
        _temporaryView.backgroundColor = DWDRGBColor(255, 241, 200);
        _temporaryView.userInteractionEnabled = YES;
        
        // subview
        UILabel *tmpDescriptionLeftLabel = [UILabel new];
        tmpDescriptionLeftLabel.text = @"临时对话窗口,  快加TA为好友畅聊吧!";
        tmpDescriptionLeftLabel.textAlignment = NSTextAlignmentLeft;
        tmpDescriptionLeftLabel.font = [UIFont systemFontOfSize:13.0f];
        tmpDescriptionLeftLabel.textColor = DWDRGBColor(102, 102, 102);
        [tmpDescriptionLeftLabel sizeToFit];
        CGRect frame = tmpDescriptionLeftLabel.frame;
        frame.origin = CGPointMake(10, (40 - CGRectGetHeight(tmpDescriptionLeftLabel.frame)) * 0.5);
        tmpDescriptionLeftLabel.frame = frame;
        [_temporaryView addSubview:tmpDescriptionLeftLabel];
        
        // subview
        UILabel *tmpDescriptionRightLabel = [UILabel new];
        tmpDescriptionRightLabel.text = @"添加好友 >";
        tmpDescriptionRightLabel.textAlignment = NSTextAlignmentLeft;
        tmpDescriptionRightLabel.font = [UIFont systemFontOfSize:13.0f];
        tmpDescriptionRightLabel.textColor = DWDRGBColor(102, 102, 102);
        [tmpDescriptionRightLabel sizeToFit];
        CGRect rightFrame = tmpDescriptionRightLabel.frame;
        rightFrame.origin = CGPointMake(DWDScreenW - CGRectGetWidth(rightFrame) - 10, (40 - CGRectGetHeight(tmpDescriptionLeftLabel.frame)) * 0.5);
        tmpDescriptionRightLabel.frame = rightFrame;
        [_temporaryView addSubview:tmpDescriptionRightLabel];
    }
    return _temporaryView;
}
//
//// 临时聊天窗口提示Label--xiekaidi
//-(UILabel *)temporaryLabel
//{
//    if (!_temporaryLabel) {
//        _temporaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, DWDScreenW-40, 20)];
//        _temporaryLabel.text = @"临时对话窗口,  快加TA为好友畅聊吧!       添加好友 >";
//        _temporaryLabel.textAlignment = NSTextAlignmentLeft;
//        _temporaryLabel.font = [UIFont systemFontOfSize:14.0f];
//        _temporaryLabel.textColor = DWDRGBColor(102, 102, 102);
//    }
//    return _temporaryLabel;
//}

// 如果是临时聊天提示 则点击跳转到 用户信息资料页面--xiekaidi
- (void)tapDidClick:(UITapGestureRecognizer *)gesture
{
    /** 跳转到'用户信息资料'页面 */
    DWDPersonDataViewController *personalVC = [[DWDPersonDataViewController alloc] init];
    personalVC.custId = _toUserId;
    personalVC.personType = DWDPersonTypeIsStrangerAdd; //非好友
//    personalVC.personType = DWDPersonTypeMySelf;   //好友
    personalVC.showPhoneNumber = YES; //只有通讯录才有这个属性
    personalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personalVC animated:YES];
    
}

@end


