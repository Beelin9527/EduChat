//
//  DWDChattingBaseCell.m
//  EduChat
//
//  Created by Superman on 16/11/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChattingBaseCell.h"

#import "DWDGrowingTextView.h"

#import "DWDChatBaseMsg.h"

#import <YYLabel.h>
#import <Masonry.h>

@implementation DWDChattingBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
        
        _nicknameLabel = [YYLabel new];
//        self.nicknameLabel.delegate = self;
        self.nicknameLabel.font = DWDFontMin;
        self.nicknameLabel.textColor = DWDColorContent;
//        self.nicknameLabel.linkAttributes = @{NSForegroundColorAttributeName:DWDColorContent};
        
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
        
//        _bubbleMyself = [UIImage imageNamed:@"BubbleMyself"];
//        _bubbleOther = [UIImage imageNamed:@"BubbleOther"];
        
        self.contentView.backgroundColor = DWDColorBackgroud;
        
        [self configConsForSubviews];
    }
    return self;
}

- (void)configConsForSubviews{
    
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
            long long longTypeCreateTime = (long long)[self.baseMsg.createTime longLongValue] /1000;
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

- (void)errorImageViewTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(chattingCellDidClickErrorImageViewAtIndexPath:)]) {
        [self.delegate chattingCellDidClickErrorImageViewAtIndexPath:self.indexPath];
    }
}

- (void)avatarTapHandler:(UITapGestureRecognizer *)sender {
//    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chattingCellDidClickAvatarAtIndexPath:)]) {
        [self.delegate chattingCellDidClickAvatarAtIndexPath:self.indexPath];
    }
}

- (void)editingTapHandler:(UITapGestureRecognizer *)sender {
//    [self throwWarningIfNeeded];
    if (!self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(chattingCellDidMutlEditingSelectedAtIndexPath:)]) {
        self.isMultEditingSelected = YES;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
        [self.delegate chattingCellDidMutlEditingSelectedAtIndexPath:self.indexPath];
    }
    else if (self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(chattingCellDidMutlEditingDisselectedAtIndexPath:)]) {
        self.isMultEditingSelected = NO;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        [self.delegate chattingCellDidMutlEditingDisselectedAtIndexPath:self.indexPath];
    }
}

@end
