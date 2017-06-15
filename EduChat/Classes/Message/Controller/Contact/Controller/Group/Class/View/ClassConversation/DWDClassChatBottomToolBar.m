//
//  DWDClassChatBottomToolBar.m
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassChatBottomToolBar.h"
#import <Masonry.h>
@interface DWDClassChatBottomToolBar()
@property (nonatomic , weak) UIButton *talkBtn;
@property (nonatomic , weak) UITextField *field;
@end

@implementation DWDClassChatBottomToolBar

- (void)functionBtnClick:(id)sender{
    DWDLogFunc;
    if ([self.bottomToolBarDelegate respondsToSelector:@selector(functionBtnClick)]) {
        [self.bottomToolBarDelegate functionBtnClick];
    }
}


- (void)awakeFromNib{
    DWDLogFunc;
    UIButton *talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    talkBtn.layer.borderWidth = 1;
    talkBtn.layer.cornerRadius = 5;
    talkBtn.hidden = YES;
    _talkBtn = talkBtn;
    [talkBtn addTarget:self action:@selector(beginPCMRecod) forControlEvents:UIControlEventTouchDown];
    [talkBtn addTarget:self action:@selector(endPCMRecord) forControlEvents:UIControlEventTouchUpInside];
    [talkBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [talkBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
    
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [changeBtn setImage:[UIImage imageNamed:@"ic_switching_normal@3x"] forState:UIControlStateNormal];
    [changeBtn setImage:[UIImage imageNamed:@"ic_switching_press@3x"] forState:UIControlStateHighlighted];
    
    UIButton *soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [soundBtn setImage:[UIImage imageNamed:@"ic_voice_normal@3x"] forState:UIControlStateNormal];
    [soundBtn setImage:[UIImage imageNamed:@"ic_voice_press@3x"] forState:UIControlStateHighlighted];
    [soundBtn addTarget:self action:@selector(soundBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *field = [[UITextField alloc] init];
    field.borderStyle = UITextBorderStyleRoundedRect;
    _field = field;
    
    UIButton *emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionBtn setImage:[UIImage imageNamed:@"ic_expression_normal@3x"] forState:UIControlStateNormal];
    [emotionBtn setImage:[UIImage imageNamed:@"ic_expression_press@3x"] forState:UIControlStateHighlighted];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:[UIImage imageNamed:@"ic_unfold_normal@3x"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"ic_unfold_press@3x"] forState:UIControlStateHighlighted];
    
    [self addSubview:talkBtn];
    [self addSubview:changeBtn];
    [self addSubview:soundBtn];
    [self addSubview:field];
    [self addSubview:emotionBtn];
    [self addSubview: addBtn];

    [changeBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(changeBtn.superview.left);
        make.top.equalTo(changeBtn.superview.top);
        make.bottom.equalTo(changeBtn.superview.bottom);
        make.width.equalTo(@(pxToW(94)));
    }];
    
    [soundBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(changeBtn.right);
        make.top.equalTo(soundBtn.superview.top);
        make.bottom.equalTo(soundBtn.superview.bottom);
        make.width.equalTo(@(pxToW(84)));
    }];
    
    [field makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(soundBtn.right).offset(pxToW(10));
        make.top.equalTo(field.superview.top).offset(pxToH(20));
        make.bottom.equalTo(field.superview.bottom).offset(pxToH(-20));
        make.right.equalTo(emotionBtn.left).offset(-(pxToW(10)));
    }];
    
    [talkBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(field.left);
        make.right.equalTo(field.right);
        make.top.equalTo(field.top);
        make.bottom.equalTo(field.bottom);
    }];
    
    [emotionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addBtn.left);
        make.top.equalTo(emotionBtn.superview.top);
        make.bottom.equalTo(emotionBtn.superview.bottom);
        make.width.equalTo(@(pxToW(84)));
    }];
    
    [addBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emotionBtn.superview.top);
        make.bottom.equalTo(addBtn.superview.bottom);
        make.right.equalTo(addBtn.superview.right).offset(pxToW(-30));
        make.width.equalTo(@(pxToW(84)));
    }];
    
    
}

- (void)soundBtnClick:(UIButton *)btn{
    _talkBtn.hidden = !_talkBtn.hidden;
    _field.hidden = !_field.hidden;
}

/**
 *  开始录音
 */
- (void)beginPCMRecod{
    DWDLogFunc;
}
/**
 *  结束录音
 */
- (void)endPCMRecord{
    DWDLogFunc;
}
@end
