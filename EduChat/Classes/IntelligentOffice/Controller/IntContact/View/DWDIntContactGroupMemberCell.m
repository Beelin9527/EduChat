//
//  DWDIntContactGroupMemberCell.m
//  EduChat
//
//  Created by KKK on 16/12/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntContactGroupMemberCell.h"
#import "DWDSchoolGroupModel.h"

#import <Masonry.h>

@interface DWDIntContactGroupMemberCell ()
//模型属性
@property (nonatomic, strong) DWDSchoolGroupMemberModel *model;
// 姓名label
@property (nonatomic, weak) UILabel *nameLabel;
// 身份label
@property (nonatomic, weak) UILabel *identifierLabel;
// 是否是好友label
@property (nonatomic, weak) UILabel *isFriendLabel;
// 电话号码Label
@property (nonatomic, weak) UILabel *phoneLabel;
// 打电话button
@property (nonatomic, weak) UIButton *phoneCallButton;
// 聊天button
@property (nonatomic, weak) UIButton *messageButton;

@end

@implementation DWDIntContactGroupMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self.contentView updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //初始化子view
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @" ";
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = DWDRGBColor(51, 51, 51);
    [self.contentView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(29 * 0.5);
        make.top.mas_equalTo(30 * 0.5);
    }];
    _nameLabel = nameLabel;

    
    
    UILabel *isFriendLabel = [UILabel new];
    isFriendLabel.font = [UIFont systemFontOfSize:10];
    isFriendLabel.textColor = [UIColor whiteColor];
    isFriendLabel.backgroundColor = UIColorFromRGB(0xfeb358);
    isFriendLabel.text = @"好友";
    [isFriendLabel setHidden:YES];
    [self.contentView addSubview:isFriendLabel];
    [isFriendLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(nameLabel);
        make.left.mas_equalTo(nameLabel.right).offset(18 * 0.5);
    }];
    _isFriendLabel = isFriendLabel;
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton addTarget:self
                      action:@selector(messageButtonDidClick)
            forControlEvents:UIControlEventTouchUpInside];
    [messageButton setImage:[UIImage imageNamed:@"icon_information_nomal"] forState:UIControlStateNormal];
    [self.contentView addSubview:messageButton];
    [messageButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(6 * 0.5));
        make.bottom.mas_equalTo(-1);
    }];
    _messageButton = messageButton;
    
    UIButton *phoneCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneCallButton addTarget:self
                      action:@selector(phoneCallButtonDidClick)
            forControlEvents:UIControlEventTouchUpInside];
    [phoneCallButton setImage:[UIImage imageNamed:@"icon_phone_normal"] forState:UIControlStateNormal];
    [self.contentView addSubview:phoneCallButton];
    [phoneCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(messageButton.left);
        make.top.mas_equalTo(messageButton);
    }];
    _phoneCallButton = phoneCallButton;
    
    UILabel *phoneLabel = [UILabel new];
    phoneLabel.text = @" ";
    phoneLabel.font = [UIFont  systemFontOfSize:24 * 0.5f];
    phoneLabel.textColor = DWDColorContent;
    [self.contentView addSubview:phoneLabel];
    [phoneLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameLabel.bottom).offset(16 * 0.5);
        make.right.mas_equalTo(phoneCallButton.left);
        make.bottom.mas_equalTo(-(30 * 0.5));
    }];
    _phoneLabel = phoneLabel;
    
    UILabel *identifierLabel = [UILabel new];
    identifierLabel.text = @" ";
    identifierLabel.font = [UIFont systemFontOfSize:12];
    identifierLabel.textColor = DWDColorSecondary;
    [self.contentView addSubview:identifierLabel];
    [identifierLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
//        make.top.mas_equalTo(nameLabel.bottom).offset(20 * 0.5);
        make.centerY.mas_equalTo(phoneLabel);
        make.right.mas_lessThanOrEqualTo(phoneLabel.left).offset(-(60 * 0.5));
    }];
    _identifierLabel = identifierLabel;
    // 分割线
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorFromRGB(0xdddddd);
    [self.contentView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    
    return self;
}

- (void)layoutWithModel:(DWDSchoolGroupMemberModel *)model {
    _model = model;
//    // 姓名label
//    @property (nonatomic, weak) UILabel *nameLabel;
//    // 身份label
//    @property (nonatomic, weak) UILabel *identifierLabel;
//    // 是否是好友label
//    @property (nonatomic, weak) UILabel *isFriendLabel;
//    // 电话号码Label
//    @property (nonatomic, weak) UILabel *phoneLabel;
    NSString *nameString = model.memberName;
#if DEBUG
    if (nameString.length == 0 || nameString == nil) {
        nameString = @"返回数据没有名字!";
    }
#else
#endif
    _nameLabel.text = nameString;
    _identifierLabel.text = model.characterName;
//    _identifierLabel.text = @"离开房间水电费了空间扫到了看发送了肯德基考了多少就弗雷德卡局领导看建档立卡建档立卡建档立卡";
    [_isFriendLabel setHidden:!model.isFriend];
    _phoneLabel.text = model.telPhone;
}

#pragma mark - Event Response
//memberCellDidClickMessageButton
- (void)phoneCallButtonDidClick {
    if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(memberCellDidClickPhoneCallButton:)]) {
        [_eventDelegate memberCellDidClickPhoneCallButton:self];
    }
}

- (void)messageButtonDidClick {
    if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(memberCellDidClickMessageButton:)]) {
        [_eventDelegate memberCellDidClickMessageButton:self];
    }
}


@end
