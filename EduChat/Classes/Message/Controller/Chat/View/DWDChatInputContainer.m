//
//  DWDChatInputContainer.m
//  EduChat
//
//  Created by Superman on 16/6/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatInputContainer.h"

#import "DWDChatMsgClient.h"
#import "DWDChatMsgDataClient.h"

#import "DWDMessageTimerManager.h"

#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDTimeChatMsg.h"

#import <Masonry.h>
#import <YYModel.h>

@interface DWDChatInputContainer() <UIGestureRecognizerDelegate , UITextViewDelegate , DWDChatEmotionContainerDelegate>

@property (nonatomic , strong) UIButton *changeToInputBtn;
@property (nonatomic , strong) UIButton *inputVoiceBtn;

@property (nonatomic , strong) UIButton *addFileBtn;
@property (nonatomic , strong) UIButton *faceBtn;
@property (nonatomic , strong) UIButton *changeBtn;
@property (nonatomic , strong) UIView *topSeperator;

@property (nonatomic , strong) DWDChatMsgClient *chatMsgClient;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerHeight;

@property (nonatomic , assign) CGFloat lastInputContainerHeight;
@property (assign, nonatomic) CGFloat textViewUpDownInset;

@property (nonatomic, assign) NSUInteger location;//光标位置

@end

@implementation DWDChatInputContainer

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self buildSubViews];
        _faceView = [[DWDChatEmotionContainer alloc]initWithFrame:CGRectMake(0,DWDScreenH - DWDTopHight , DWDScreenW, 200)];
//        [_faceView setDelegate:self];
        [self.chatVc.view addSubview:_faceView];
        [self addCons];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self buildSubViews];
    [self addCons];
    [self setUpSubViewsSpecify];
}

#pragma mark - 子控件
- (void)buildSubViews{
    [self addSubview:self.changeToInputBtn];
    [self addSubview:self.inputVoiceBtn];
    [self addSubview:self.growingTextView];
    [self addSubview:self.addFileBtn];
    [self addSubview:self.faceBtn];
    [self addSubview:self.speakBtn];
    [self addSubview:self.changeBtn];
    [self addSubview:self.topSeperator];
}

#pragma mark - 约束
- (void)addCons{
    [_topSeperator makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.height.equalTo(@1);
    }];
    
    [_changeToInputBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(2);
        make.centerY.equalTo(self.centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_inputVoiceBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(2);
        make.centerY.equalTo(self.centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_changeBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(2);
        make.centerY.equalTo(self.centerY);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [_faceBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-40);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(self.centerY);
    }];
    
    [_growingTextView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(47);
        make.centerY.equalTo(self.centerY);
        make.height.equalTo(@35);
        make.right.equalTo(_faceBtn.left);
    }];
    
    [_speakBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(47);
        make.height.equalTo(@49);
        make.right.equalTo(_faceBtn.left);
        make.centerY.equalTo(self.centerY);
    }];
    
    [_speakBtn.label makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_speakBtn.centerY);
        make.centerX.equalTo(_speakBtn.centerX);
    }];
    
    [_speakBtn.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_speakBtn.left);
        make.right.equalTo(_speakBtn.right);
        make.top.equalTo(_speakBtn.top).offset(6);
        make.bottom.equalTo(_speakBtn.bottom).offset(-6);
    }];
    
    [_addFileBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.right.equalTo(self.right).offset(-2);
        make.centerY.equalTo(self.centerY);
    }];
}

- (void)setUpSubViewsSpecify{
    if (self.chatType == DWDChatTypeFace) {
        
    }
}
#pragma mark - 事件监听
- (void)changeToInputBtnClick:(UIButton *)btn{  // 切换小键盘按钮点击
    [self dismissAddFileContainer];
    
    self.faceView.transform = CGAffineTransformIdentity;
    
//    self.h = self.inputContainerHeightBackup;
    
//    self.dismissKeyboardType = DWDDismissKeyboardFromSwitchToTextInput;
    self.changeToInputBtn.hidden = YES;
    
    self.growingTextView.hidden = NO;
    
    self.inputVoiceBtn.hidden = NO;
    self.speakBtn.hidden = YES;
    
    [self.growingTextView becomeFirstResponder];
}

- (void)inputVoiceBtnClick:(UIButton *)btn{
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeMicroPhone withController:_chatVc authorized:^{
        
        [self dismissAddFileContainer];
        
        self.faceView.transform = CGAffineTransformIdentity;
        
        //    self.inputContainerHeightBackup = self.inputContainerHeight.constant;
        self.inputContainerHeight.constant = DWDToolBarHeight;
        //    self.dismissKeyboardType = DWDDismissKeyboardFromSwitchToVocieInput;
        
        self.changeToInputBtn.hidden = NO;
        self.growingTextView.hidden = YES;
        
        self.inputVoiceBtn.hidden = YES;
        self.speakBtn.hidden = NO;
        
        if ([self.growingTextView isFirstResponder]) {
            [self.growingTextView resignFirstResponder];
        }
        else {
            self.inputContainerHeight.constant = DWDToolBarHeight;
            [self.delegate tableViewChangeBottomCons:DWDToolBarHeight];
        }
        
        [self.delegate tableViewScroll];
    }];
}

- (void)addFileBtnCkick:(UIButton *)btn{
    [self.growingTextView resignFirstResponder];
    
    self.faceView.transform = CGAffineTransformIdentity;
    
    [self.delegate addFileBtnClick];
    
}

- (void)faceBtnClick:(UIButton *)btn{
    [self.chatVc.view addSubview:self.faceView];
    [self.growingTextView resignFirstResponder];
    self.speakBtn.hidden = YES;
    self.growingTextView.hidden = NO;
    self.faceView.transform = CGAffineTransformMakeTranslation(0, -200);

    [self.delegate faceBtnClick];
}

#pragma mark - TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) { // 监听键盘点击return key
        [self sendTextMsg]; // 发送消息
        self.location = 0;
        textView.text = nil;
        // 恢复高度
        [self.growingTextView updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@35);
        }];
        self.inputContainerHeight.constant = DWDToolBarHeight;
        
        self.h = [self.growingTextView getHeightConstraint] + self.textViewUpDownInset;
        [self.delegate tableViewShouldChangeBottomConsAndReload:self.h];
        
        return NO;
    } else if (textView.text.length > 0 && [text isEqualToString:@""]) {
        /** 删除表情所做事件处理 **/
        if ([textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [textView.text characterAtIndex:location];
                if (c == '[') {
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    return NO;
                }
                else if (c == ']') {
                    return YES;
                }
            }
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    //    CGFloat preConstant = self.d.constant;
    _lastInputContainerHeight = self.h;
    
    self.h = [self.growingTextView getHeightConstraint] + self.textViewUpDownInset;
    
    if (self.h != _lastInputContainerHeight) {
        [self.growingTextView updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@([self.growingTextView getHeightConstraint]));
        }];
        _inputContainerHeight.constant = self.h;
        [self.delegate tableViewShouldChangeBottomConsAndReload:self.h];
    }
//    if (_lastInputContainerHeight != self.inputContainerHeight.constant) {
//        if (_lastInputContainerHeight - self.h > 0) {
//            
//            [self.delegate tableViewShouldChangeBottomConsAndReload:_lastInputContainerHeight - self.h];
//        }
//    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.faceView.transform = CGAffineTransformIdentity;
    
    //标记光标位置
    self.location = textView.selectedRange.location;
}

/** 光标事件 回调 */
- (void)textViewDidChangeSelection:(UITextView *)textView{
    if ([textView isFirstResponder]) {
        //标记光标位置
        self.location = textView.selectedRange.location;
    }
}

#pragma mark - <DWDChatEmotionContainerDelegate>
- (void)emotionContainerDidSelectImage:(UIImage *)image{
    [self.chatVc.addFileContainerView sendImage:image];
}

- (void)sendText{
    [self sendTextMsg];
    self.location = 0;
    self.growingTextView.text = nil;
    
    // 恢复高度
    [self.growingTextView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@35);
    }];
    self.inputContainerHeight.constant = DWDToolBarHeight;
    
    self.h = [self.growingTextView getHeightConstraint] + self.textViewUpDownInset;
    [self.delegate tableViewShouldChangeBottomConsAndReload:self.h];
   
}
/** 点击表情按钮事件 */

- (void)emotionContainerDidSelectDefaultEmotionWithEmotionString:(NSString *)emotionString{
    
    //防止删了文本，光标位置大于文本长度，导致蹦溃
    if(self.location > self.growingTextView.text.length){
        self.location = self.growingTextView.text.length;
    }
    
    NSMutableString *string = [[self.growingTextView text] mutableCopy];
    [string insertString:emotionString atIndex:self.location];
    
    self.growingTextView.text = string;
    self.growingTextView.selectedRange = NSMakeRange(self.location + emotionString.length, 0);
    
    //重新设置光标后加表情字符长度
    self.location += emotionString.length;
    
    [self textViewDidChange:self.growingTextView];

}

#pragma mark - <DWDFaceViewDelegate>
/** 删除表情按扭事件 **/
- (void)faceViewDidSelectDelete:(DWDFaceView *)faceView
{
    [self textView:self.growingTextView shouldChangeTextInRange:NSMakeRange(self.growingTextView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:self.growingTextView];
}

/** 发送表情按扭事件 **/
- (void)faceViewDidSelectSend:(DWDFaceView *)faceView
{
    [self sendTextMsg];
     self.location = 0;
    self.growingTextView.text = nil;
    
}

#pragma mark - <共有方法>
- (void)updateSubViewsConsForClassType{
    [self.changeToInputBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(32);
        make.width.equalTo(@30);
    }];
    
    [self.inputVoiceBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(32);
    }];
    
    [self.speakBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(77);
    }];
    
    [self.growingTextView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(77);
    }];
}

- (void)updateSubViewsConsForFaceAndGroupType{
    [self.changeToInputBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(2);
        make.width.equalTo(@44);
    }];
    
    [self.inputVoiceBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(2);
    }];
    
    [self.speakBtn updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(47);
    }];
    
    [self.growingTextView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(47);
    }];
}

#pragma mark - <私有方法>

- (void)changeBtnClick:(UIButton *)btn{
    [self.delegate inputContainerChangeBtnClick];
}

- (void)dismissAddFileContainer {
    
    [self.delegate addFileContainerDismiss];
    self.faceView.transform = CGAffineTransformIdentity;
    //    if (self.isNeedDismissAddFileContainer) {
    //
    //    }
}

- (void)sendTextMsg {
    //校验文本是否为空字符串,是则 return
    if ([self.growingTextView.text trim].length == 0) {
        
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"不能发送空白消息" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVc dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertVc addAction:action];
        
        [self.chatVc presentViewController:alertVc animated:YES completion:nil];
        return;
    }
    
    BOOL isMulChat = self.chatType == DWDChatTypeFace ? NO : YES;
    DWDTextChatMsg *newMsg = [self.chatMsgClient sendTextMsg:self.growingTextView.text from:[DWDCustInfo shared].custId  to:self.toUser observe:self.chatVc mutableChat:isMulChat chatType:self.chatType];
    
    // 通知代理刷新界面
    [self.delegate inputContainerSendTextMsg:[NSArray arrayWithObject:newMsg]];
    
    DWDLog(@"创建消息时的时间戳 : %lld" , [newMsg.createTime longLongValue]);
    
    [self saveMessageToDBWithMessage:newMsg];
    
    // 发送消息, 40s后判断超时时间
    // 缓存消息内容
    [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict setObject:@{@"content" : [newMsg yy_modelToJSONString], @"chatType" : @(_chatType) , @"toUser" : _toUser} forKey:newMsg.msgId];
    
    DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:40 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : newMsg.msgId , @"toId" : _toUser , @"chatType" : @(_chatType)} repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // 加入主运行循环
    
    [timerManager.timerCachDict setObject:timer forKey:newMsg.msgId];  // 缓存超时定时器
    
}

- (void)saveMessageToDBWithMessage:(DWDBaseChatMsg *)msg{
    // 存消息模型到本地
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        DWDLog(@"历史消息保存成功");
        NSNumber *friendId;
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发的
            friendId = msg.toUser;
        }else{  //  别人发的
            if (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup) {
                friendId = msg.toUser;
            }else{
                friendId = msg.fromUser;
            }
        }
        
        if (([msg.msgType isEqualToString:kDWDMsgTypeText] || [msg.msgType isEqualToString:kDWDMsgTypeAudio] || [msg.msgType isEqualToString:kDWDMsgTypeImage] || [msg.msgType isEqualToString:kDWDMsgTypeVideo]) && [msg.fromUser isEqual:[DWDCustInfo shared].custId]) {
            
            //插一个数据到会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:msg FriendCusId:friendId myCusId:[DWDCustInfo shared].custId success:^{
//                // 发通知 刷新会话控制器
//                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
             
            } failure:^{
                
            }];
        }
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

#pragma mark - <setters>
- (void)setChatType:(DWDChatType)chatType{
    _chatType = chatType;
    if (chatType == DWDChatTypeClass) {
        self.changeBtn.hidden = NO;
    }
}

#pragma mark - getters
- (UIButton *)changeToInputBtn{
    if (!_changeToInputBtn) {
        _changeToInputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeToInputBtn setImage:[UIImage imageNamed:@"ic_keyboard_normal"] forState:UIControlStateNormal];
        [_changeToInputBtn addTarget:self action:@selector(changeToInputBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _changeToInputBtn.hidden = YES;
    }
    return _changeToInputBtn;
}

- (UIButton *)inputVoiceBtn{
    if (!_inputVoiceBtn) {
        _inputVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inputVoiceBtn setBackgroundImage:[UIImage imageNamed:@"ic_voice_normal"] forState:UIControlStateNormal];
        [_inputVoiceBtn addTarget:self action:@selector(inputVoiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _inputVoiceBtn;
}

- (DWDGrowingTextView *)growingTextView{
    if (!_growingTextView) {
        _growingTextView = [[DWDGrowingTextView alloc] init];
        _growingTextView.delegate = self;
        [_growingTextView setFont:DWDFontContent];
        _growingTextView.returnKeyType = UIReturnKeySend;
        self.textViewUpDownInset = self.h - [_growingTextView getHeightConstraint];
    }
    return _growingTextView;
}

- (UIButton *)addFileBtn{
    if (!_addFileBtn) {
        _addFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addFileBtn setBackgroundImage:[UIImage imageNamed:@"ic_unfold_normal"] forState:UIControlStateNormal];
        [_addFileBtn addTarget:self action:@selector(addFileBtnCkick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addFileBtn;
}

- (UIButton *)faceBtn{
    if (!_faceBtn) {
        _faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceBtn setImage:[UIImage imageNamed:@"ic_expression"] forState:UIControlStateNormal];
        [_faceBtn setImage:[UIImage imageNamed:@"ic_expression_press"] forState:UIControlStateHighlighted];
        [_faceBtn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceBtn;
}

- (UIView *)speakBtn{
    if (!_speakBtn) {
        _speakBtn = [[DWDSpeakImageView alloc] init];
        _speakBtn.hidden = YES;
    }
    return _speakBtn;
}

- (UIButton *)changeBtn{
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeBtn setImage:[UIImage imageNamed:@"ic_switching_normal"] forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _changeBtn.hidden = YES;
    }
    return _changeBtn;
}

- (UIView *)topSeperator{
    if (!_topSeperator) {
        _topSeperator = [[UIView alloc] init];
        _topSeperator.backgroundColor = DWDColorBackgroud;
    }
    return _topSeperator;
}


- (DWDChatMsgClient *)chatMsgClient{
    if (!_chatMsgClient) {
        _chatMsgClient = [[DWDChatMsgClient alloc] init];
    }
    return _chatMsgClient;
}

- (DWDChatEmotionContainer *)faceView{
    if (!_faceView) {
        _faceView = [[DWDChatEmotionContainer alloc]initWithFrame:CGRectMake(0,DWDScreenH - DWDTopHight , DWDScreenW, 200)];
        _faceView.delegate = self;
//        [_faceView setDelegate:self];
    }
    return _faceView;
}
@end


