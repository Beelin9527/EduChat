//
//  DWDContactsInviteCell.m
//  EduChat
//
//  Created by KKK on 16/11/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactsInviteCell.h"

#import "DWDContactInviteModel.h"

#import <Masonry.h>
#import <SDVersion.h>

@import AddressBook;
@import Contacts;

@interface DWDContactsInviteCell ()

@property (nonatomic, weak) UIImageView *headerImgView;
@property (nonatomic, weak) UILabel *characterLabel;

@property (nonatomic, weak) UILabel *nameLabel;

@property (nonatomic, weak) UIButton *inviteButton;
@property (nonatomic, weak) UILabel *invitedLabel;

@property (nonatomic, strong) DWDContactInviteModel *model;

@end

/**
 
 
 ****************************
 *         name             *
 *                          *
 * img              invite  *
 *                          *
 *      introduce           *
 ****************************
 
 
 
 
 
 */


@implementation DWDContactsInviteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIImageView *imgView = [UIImageView new];
//    [imgView setImage:[UIImage imageNamed:@"guidepage_one"]];
    [self.contentView addSubview:imgView];
    [imgView makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    _headerImgView = imgView;
    
    UILabel *characterLabel = [UILabel new];
    characterLabel.textAlignment = NSTextAlignmentCenter;
    characterLabel.font = [UIFont systemFontOfSize:24];
    characterLabel.textColor = DWDColorMain;
    [self.contentView addSubview:characterLabel];
    [characterLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(imgView);
    }];
    _characterLabel = characterLabel;
    [_characterLabel setHidden:YES];
    
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = DWDColorBody;
    nameLabel.text = @"测试";
    [self.contentView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imgView.right).offset(19 * 0.5);
        make.top.mas_equalTo(self.contentView).offset(12);
//        make.centerY.mas_equalTo(self.contentView);
    }];
    _nameLabel = nameLabel;
    
    UILabel *introduceLabel = [UILabel new];
    introduceLabel.font = [UIFont systemFontOfSize:12];
    introduceLabel.textColor = DWDRGBColor(153, 153, 153);
    introduceLabel.text = @"来自手机通讯录好友";
    [self.contentView addSubview:introduceLabel];
    [introduceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.bottom.mas_equalTo(imgView);
    }];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton addTarget:self action:@selector(inviteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"邀请" attributes:@{
                                                                                          NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          }];
    inviteButton.backgroundColor = DWDColorMain;
    inviteButton.layer.cornerRadius = 4;
    inviteButton.clipsToBounds = YES;
    inviteButton.layer.masksToBounds = YES;
    [inviteButton setAttributedTitle:str forState:UIControlStateNormal];
    [self.contentView addSubview:inviteButton];
    [inviteButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [inviteButton setHidden:YES];
    _inviteButton = inviteButton;
    
    UILabel *invitedLabel = [UILabel new];
    invitedLabel.font = [UIFont systemFontOfSize:14];
    invitedLabel.textColor = UIColorFromRGB(0x999999);
    invitedLabel.text = @"已邀请";
    [self.contentView addSubview:invitedLabel];
    [invitedLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(inviteButton);
    }];
    [invitedLabel setHidden:YES];
    
    _invitedLabel = invitedLabel;
    
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = DWDRGBColor(221, 221, 221);
    [self.contentView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(0.5);
        
    }];
    
    return self;
}

#pragma mark - Private Method
- (void)setDataWithModel:(DWDContactInviteModel *)model {
    _model = model;
    [self setData];
}

- (void)setData {
    //set name
    _nameLabel.text = _model.name;
    
    //set image
    if (_model.image != nil) {
        _characterLabel.text = nil;
        [_characterLabel setHidden:YES];
        [_headerImgView setImage:_model.image];
    } else {
        static UIImage *placeHolderImage;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            placeHolderImage = [UIImage imageWithColor:UIColorFromRGB(0xe9f0ff)];
        });
        [_headerImgView setImage:placeHolderImage];
        
        _characterLabel.text = [[_model.name substringFromIndex:_model.name.length > 0 ? _model.name.length - 1 : 0] uppercaseString];
        [_characterLabel setHidden:NO];
    }
    
    //set status
    if (_model.invited) {
        [_invitedLabel setHidden:NO];
        [_inviteButton setHidden:YES];
    } else {
        [_invitedLabel setHidden:YES];
        [_inviteButton setHidden:NO];
    }
}


#pragma mark - Event Response
- (void)inviteButtonDidClick {
    if (_delegate && [_delegate respondsToSelector:@selector(inviteCell:didClickInviteButtonWithModel:)]) {
        [_delegate inviteCell:self didClickInviteButtonWithModel:_model];
    }
}

@end
