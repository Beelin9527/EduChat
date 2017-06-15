//
//  DWDClassChatBottomView.m
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//



#import "DWDClassChatBottomView.h"
#import "KxMenu.h"
#import "DWDClassMenu.h"
#import "DWDClassModel.h"
#import <Masonry.h>
@interface DWDClassChatBottomView()
@property (nonatomic , assign) BOOL flag;

@end

@implementation DWDClassChatBottomView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _flag = NO;
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"bg_show_menu_class_dialogue_pages_normal"];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (_flag == NO) {
        [self setUpBottomViewSubviews];
    }
    _flag = YES;
}

- (void)setUpBottomViewSubviews{
    UIButton *changeBtn = [[UIButton alloc] init];
    
//    if (![DWDCustInfo shared].isTeacher) {
//        [changeBtn setImage:[UIImage imageNamed:@"ic_switching_disable"] forState:UIControlStateNormal];
        [changeBtn setImage:[UIImage imageNamed:@"ic_switching_disable"] forState:UIControlStateHighlighted];
//    }else{
        [changeBtn setImage:[UIImage imageNamed:@"ic_switching_normal"] forState:UIControlStateNormal];
//    }
    
    _changeBtn = changeBtn;
    UIButton *classGrowupBtn = [[UIButton alloc] init];
    [classGrowupBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
    
    UIButton *classManageBtn = [[UIButton alloc] init];
    [classManageBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
    
    [classGrowupBtn setTitle:@"班级成长" forState:UIControlStateNormal];
    [classManageBtn setTitle:@"班级管理" forState:UIControlStateNormal];
    
    [changeBtn addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [classGrowupBtn addTarget:self action:@selector(classGrowupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [classManageBtn addTarget:self action:@selector(classManagementBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:changeBtn];
    [self addSubview:classGrowupBtn];
    [self addSubview:classManageBtn];

    [changeBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(changeBtn.superview.left);
        make.top.equalTo(changeBtn.superview.top);
        make.bottom.equalTo(changeBtn.superview.bottom);
        make.width.equalTo(@(pxToW(96)));
    }];
    
    [classGrowupBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(changeBtn.right);
        make.top.equalTo(changeBtn.top);
        make.bottom.equalTo(changeBtn.bottom);
        make.width.equalTo(@((DWDScreenW - (pxToW(96)))/2));
    }];
    
    [classManageBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(classGrowupBtn.right);
        make.top.equalTo(classGrowupBtn.top);
        make.bottom.equalTo(classGrowupBtn.bottom);
        make.width.equalTo(classGrowupBtn.width);
    }];
    
}

- (void)changeBtnClick:(id)sender{
    if (_menu) {
        [_menu dismiss];
    }
    
    NSNotification *note = [NSNotification notificationWithName:DWDClassInfoBottomViewChangeBtnClick object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)classGrowupBtnClick:(UIButton *)btn{
    if (!_menu) {
        DWDClassMenu *menu = [[DWDClassMenu alloc] init];
        menu.btn = btn;
        menu.conversationVc = _conversationVc;
        menu.titles = @[@"成长记录",@"作业",@"接送中心"];
        CGRect fromRect = [btn convertRect:btn.bounds toView:self.superview];
        [self.superview insertSubview:menu belowSubview:self];
        [menu showFormView:fromRect];
        menu.myClass = self.myClass;
        _menu = menu;
    }else{
        if (_menu.btn != btn) { // 正在展示的,和点的按钮不是同一个位置
            [_menu dismiss];
            DWDClassMenu *menu = [[DWDClassMenu alloc] init];
            menu.btn = btn;
            menu.conversationVc = _conversationVc;
            menu.myClass = self.myClass;
            menu.titles = @[@"成长记录",@"作业",@"接送中心"];
            CGRect fromRect = [btn convertRect:btn.bounds toView:self.superview];
            [self.superview insertSubview:menu belowSubview:self];
            [menu showFormView:fromRect];
            _menu = menu;
            return;
        }
        [_menu dismiss];
        _menu = nil;
    }
}

- (void)classManagementBtnClick:(UIButton *)btn{
    if (!_menu) {
        DWDClassMenu *menu = [[DWDClassMenu alloc] init];
        menu.btn = btn;
        menu.conversationVc = _conversationVc;
        menu.myClass = self.myClass;
        menu.titles = @[@"通知",@"假条"];
        [self.superview insertSubview:menu belowSubview:self];
        CGRect fromRect = [btn convertRect:btn.bounds toView:self.superview];
        [menu showFormView:fromRect];
        _menu = menu;
    }else{
        if (_menu.btn != btn) { // 正在展示的,和点的按钮不是同一个位置
            [_menu dismiss];
            DWDClassMenu *menu = [[DWDClassMenu alloc] init];
            menu.btn = btn;
            menu.conversationVc = _conversationVc;
            menu.myClass = self.myClass;
            menu.titles = @[@"通知",@"假条"];
            [self.superview insertSubview:menu belowSubview:self];
            CGRect fromRect = [btn convertRect:btn.bounds toView:self.superview];
            [menu showFormView:fromRect];
            _menu = menu;
            return;
        }
        [_menu dismiss];
        _menu = nil;
    }
}


@end
