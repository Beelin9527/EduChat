//
//  DWDInteractiveChatCell.m
//  EduChat
//
//  Created by apple on 11/17/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDInteractiveChatCell.h"
#import "DWDGrowingTextView.h"

@interface DWDInteractiveChatCell ()

@end

@implementation DWDInteractiveChatCell

#pragma mark - override methods
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (editing) {
        [self buildEidtingFrame];
    }
    else {
        editingFrame = CGRectZero;
    }
    [super setEditing:editing animated:animated];
}
#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickURL:WithCell:)]) {
        [self.delegate interactiveChatCellDidClickURL:url WithCell:self];
    }
}

#pragma mark - publice methods
- (void)commitInitWithTitles {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //long press recognizer need subclass to determine which view should be add, not do add action here
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    _longPress.allowableMovement = 0.05;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
//    [self addGestureRecognizer:tap];  // 在继承体系中添加这样的手势 , 很容易影响子类的事件响应
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapHandler:)];
    _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarImgView.userInteractionEnabled = YES;
    [self.avatarImgView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *editingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editingTapHandler:)];
    _editingView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.editingView.userInteractionEnabled = YES;
    self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
    [self.editingView addGestureRecognizer:editingTap];
    
    _nicknameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.nicknameLabel.delegate = self;
    self.nicknameLabel.font = DWDFontMin;
    self.nicknameLabel.textColor = DWDColorContent;
    self.nicknameLabel.linkAttributes = @{NSForegroundColorAttributeName:DWDColorContent};
    _sendingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _errorImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _errorImgView.userInteractionEnabled = YES;
    _errorImgView.image = [UIImage imageNamed:@"ic_network_failure"];
    [_errorImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorImageViewTap:)]];
    
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.editingView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.sendingIndicator];
    [self.contentView addSubview:self.errorImgView];
    
    _bubbleMyself = [UIImage imageNamed:@"BubbleMyself"];
    _bubbleOther = [UIImage imageNamed:@"BubbleOther"];
    
    self.contentView.backgroundColor = DWDColorBackgroud;
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state != UIGestureRecognizerStateBegan && sender != nil) return;
    
    if (self.growingTextView.isFirstResponder) {
        // 通知代理 让textView 响应menu
        if (self.delegate && [self.delegate respondsToSelector:@selector(growingTextViewIsFirstResponderWithCell:)]) {
            [self.delegate growingTextViewIsFirstResponderWithCell:self];
        }
        return;
    }
    
    DWDLog(@"longpress : %@" , sender);
    [self becomeFirstResponder];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < _menuTitles.count; i++) {
        NSString *title = _menuTitles[i];
        
        if ([title isEqualToString:@"Revoke"]) { // 满足条件则显示撤销
            double abc = [NSDate date].timeIntervalSince1970;
            long long interval = (long long)abc;
            long long longTypeCreateTime = (long long)[self.createTime longLongValue] /1000;
            if ((interval - longTypeCreateTime <= 120) && self.status == DWDChatCellStatusNormal) {
                NSString *selName = [title stringByAppendingString:@":"];
                SEL sel = NSSelectorFromString(selName);
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(title, nil) action:sel];
                [items addObject:item];
            }else{
                continue;
            }
        }else{
            NSString *selName = [title stringByAppendingString:@":"];
            SEL sel = NSSelectorFromString(selName);
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(title, nil) action:sel];
            [items addObject:item];
        }
        
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:items];
    
    [menu setTargetRect:self.menuTargetView.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
    
    [menu setMenuItems:nil];
}

- (void)buildEidtingFrame {
    editingFrame = CGRectMake(DWDCellPadding, DWDCellPadding, DWDCellEditingEdgeLength, DWDCellEditingEdgeLength);
}

- (void)buildMyselfAvatarFrame {
    //avatar frame
    avatareFrame = CGRectMake(DWDScreenW - DWDCellPadding - DWDAvatarEdgeLength,
                              DWDCellPadding, DWDAvatarEdgeLength, DWDAvatarEdgeLength);
}

- (CGSize)buildMyselfNicknameFrame {
    //nickname frame
    CGSize nicknameSize = CGSizeZero;
    if (self.isShowNickname) {
        self.nicknameLabel.textAlignment = NSTextAlignmentRight;
        nicknameSize = [self getNicknameSize];
        
        nicknameFrame = CGRectMake(DWDScreenW - DWDAvatarEdgeLength - 2 * DWDCellPadding - nicknameSize.width - DWDBubbleArrowWidth,
                                   DWDCellPadding, nicknameSize.width, nicknameSize.height);
    } else {
        nicknameFrame = CGRectZero;
    }
    return nicknameSize;
}

- (void)buildOtherAvatarFrame {
    
    avatareFrame = CGRectMake(DWDCellPadding, DWDCellPadding, DWDAvatarEdgeLength, DWDAvatarEdgeLength);
    if (self.isEditing) avatareFrame = CGRectMake(avatareFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding, DWDCellPadding, DWDAvatarEdgeLength, DWDAvatarEdgeLength);
  
}

- (CGSize)buildOtherNicknameFrame {
    //nickname frame
    CGSize nicknameSize = CGSizeZero;
    if (self.isShowNickname) {
        self.nicknameLabel.textAlignment = NSTextAlignmentRight;
        nicknameSize = [self getNicknameSize];
        
        nicknameFrame = CGRectMake(DWDAvatarEdgeLength + 2 * DWDCellPadding + DWDBubbleArrowWidth,
                                   DWDCellPadding, nicknameSize.width, nicknameSize.height);
        if (self.isEditing) nicknameFrame = CGRectMake(nicknameFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding, nicknameFrame.origin.y, nicknameFrame.size.width, nicknameFrame.size.height);
    } else {
        nicknameFrame = CGRectZero;
    }
    return nicknameSize;
}

// 根据自己的文字计算真实宽高(含属性文本)
- (CGSize)getNicknameSize {
    CGSize result = [TTTAttributedLabel sizeThatFitsAttributedString:self.nicknameLabel.attributedText withConstraints:CGSizeMake(DWDScreenW - DWDAvatarEdgeLength - 2 * DWDCellPadding, 99999) limitedToNumberOfLines:99999];
    result = CGSizeMake(ceil(result.width), ceil(result.height));
    
    return result;
}

#pragma mark - private methods

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(Copy:) ||
            action == @selector(Relay:) ||
            action == @selector(Collect:)||
            action == @selector(Delete:) ||
            action == @selector(Revoke:) ||
            action == @selector(More:));
}

- (void)Copy:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidCopyWithCell:)]) {
        [self.delegate interactiveChatCellDidCopyWithCell:self];
    }
}

- (void)Relay:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidRelayWithCell:)]) {
        [self.delegate interactiveChatCellDidRelayWithCell:self];
    }
}

- (void)Collect:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidCollectWithCell:)]) {
        [self.delegate interactiveChatCellDidCollectWithCell:self];
    }
}

- (void)Delete:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidDeleteWithCell:)]) {
        [self.delegate interactiveChatCellDidDeleteWithCell:self];
        
    }
}

- (void)Revoke:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidRevokeWithCell:)]) {
        [self.delegate interactiveChatCellDidRevokeWithCell:self];
    }
}

- (void)More:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickMoreWithCell:)]) {
        [self.delegate interactiveChatCellDidClickMoreWithCell:self];
    }
}

- (void)throwWarningIfNeeded {
}

#pragma mark - public methods
- (void)upload:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidUploadWithCell:)]) {
        [self.delegate interactiveChatCellDidUploadWithCell:self];
    }
}

- (void)avatarTapHandler:(UITapGestureRecognizer *)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickAvatarWithCell:)]) {
        [self.delegate interactiveChatCellDidClickAvatarWithCell:self];
    }
}

- (void)editingTapHandler:(UITapGestureRecognizer *)sender {
    [self throwWarningIfNeeded];
    if (!self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidMutlEditingSelectedWithCell:)]) {
        self.isMultEditingSelected = YES;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
        [self.delegate interactiveChatCellDidMutlEditingSelectedWithCell:self];
    }
    else if (self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidMutlEditingDisselectedWithCell:)]) {
        self.isMultEditingSelected = NO;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        [self.delegate interactiveChatCellDidMutlEditingDisselectedWithCell:self];
    }
}

- (void)UIPrepareForSendingDataStatus {
    DWDLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForCreateStatus; {
    DWDLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForNormalStatus {
    DWDLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForErrorStatus {
    DWDLog(@"super void implement, you must override this method!!");
}

- (CGFloat)getHeight {
    DWDLog(@"super void implement, you must override this method!!");
    return 0;
}

- (void)errorImageViewTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(interactiveChatCellDidClickErrorImageViewWithCell:)]) {
        [self.delegate interactiveChatCellDidClickErrorImageViewWithCell:self];
    }
}

- (void)setIsMultEditingSelected:(BOOL)isMultEditingSelected{
    _isMultEditingSelected = isMultEditingSelected;
    
}

@end
