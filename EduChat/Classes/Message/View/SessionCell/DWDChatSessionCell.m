//
//  DWDChatSessionCell.m
//  EduChat
//
//  Created by apple on 11/4/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDChatSessionCell.h"
#import "DWDRecentChatModel.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "NSDictionary+dwd_extend.h"
#import "NSString+extend.h"
@interface DWDChatSessionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;        //头像
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;                //昵称
@property (weak, nonatomic) IBOutlet YYLabel *digestLabel;              //消息
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;                //接收时间
@property (weak, nonatomic) IBOutlet UILabel *unreadBadgeLabel;         //消息条数
@end

@implementation DWDChatSessionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.unreadBadgeLabel.layer.cornerRadius = 10;
    
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    _digestLabel.textParser = parser;
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = DWDRGBColor(228, 228, 228).CGColor;
    layer.hidden = YES;
    _seperatorLayer = layer;
    [self.layer addSublayer:layer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _seperatorLayer.frame = CGRectMake(0, self.h - 0.5, DWDScreenW, 0.5);
   
}

- (void)setRecentChatModel:(DWDRecentChatModel *)recentChatModel{
    _recentChatModel = recentChatModel;
    
    if (recentChatModel.nickname.length == 0 || recentChatModel.nickname == nil) {
        // 通过cusid 从通讯录取 , 并且插入到recentChat表中, 不用每次发消息收消息都更新recent的这两个字段
        if (recentChatModel.chatType == DWDChatTypeFace) {
            recentChatModel.nickname = [[DWDContactsDatabaseTool sharedContactsClient] fetchNicknameWithFriendId:recentChatModel.custId];
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateNicknameWithCusId:recentChatModel.custId nickname:recentChatModel.nickname success:^{
                
            } failure:^{
                
            }];
            
        }else if (recentChatModel.chatType == DWDChatTypeClass){
            
            recentChatModel.nickname = [[DWDClassDataBaseTool sharedClassDataBase] fetchNicknameWithFriendId:recentChatModel.custId];
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateNicknameWithCusId:recentChatModel.custId nickname:recentChatModel.nickname ? recentChatModel.nickname : @"班级" success:^{
                
            } failure:^{
                
            }];
            
        }else if (recentChatModel.chatType == DWDChatTypeGroup){
            
            NSString *name = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchNicknameWithFriendId:recentChatModel.custId];
            
            recentChatModel.nickname = name == nil ? @"群组" : name;
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateNicknameWithCusId:recentChatModel.custId nickname:recentChatModel.nickname success:^{
                
            } failure:^{
                
            }];
            
        }
    }
    
    if (recentChatModel.photoKey.length == 0 || recentChatModel.photoKey == nil) {
        // 通过cusid 从通讯录取 , 并且插入到recentChat表中, 不用每次发消息收消息都更新recent的这两个字段
        if (recentChatModel.chatType == DWDChatTypeFace) {
            
            recentChatModel.photoKey = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchPhotoKeyWithFriendId:recentChatModel.custId];
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:recentChatModel.custId photokey:recentChatModel.photoKey success:^{
                
            } failure:^{
                
            }];
            
        }else if (recentChatModel.chatType == DWDChatTypeClass){
            
            recentChatModel.photoKey = [[DWDClassDataBaseTool sharedClassDataBase] fetchPhotoKeyWithFriendId:recentChatModel.custId];
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:recentChatModel.custId photokey:recentChatModel.photoKey success:^{
                
            } failure:^{
                
            }];
            
        }else if (recentChatModel.chatType == DWDChatTypeGroup){
            
            recentChatModel.photoKey = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchPhotoKeyWithFriendId:recentChatModel.custId];
            
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:recentChatModel.custId photokey:recentChatModel.photoKey success:^{
                
            } failure:^{
                
            }];
            
        }
    }
    
    NSString *name = [[DWDPersonDataBiz sharedPersonDataBiz] checkoutExistRemarkName:recentChatModel.remarkName nickname:recentChatModel.nickname];
    _nameLabel.text = name;
    
    _digestLabel.text = recentChatModel.lastContent;
    
    NSString *timeStr = [NSString judgeTimeStringWithString:recentChatModel.lastCreatTime];
    
    _timeLabel.text = timeStr;
    
    if (recentChatModel.chatType == DWDChatTypeClass) {
        [_avatarImgView sd_setImageWithURL:[NSURL URLWithString:recentChatModel.photoKey] placeholderImage:DWDDefault_GradeImage];
    }else if (recentChatModel.chatType == DWDChatTypeGroup){
        [_avatarImgView sd_setImageWithURL:[NSURL URLWithString:recentChatModel.photoKey] placeholderImage:DWDDefault_GroupImage];
    }else{
        [_avatarImgView sd_setImageWithURL:[NSURL URLWithString:recentChatModel.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    }
    
    NSString *visualCountString = [recentChatModel.badgeCount integerValue] >= 99 ? @"99+" : [NSString stringWithFormat:@"%zd",[recentChatModel.badgeCount integerValue]];
    
    _unreadBadgeLabel.text = visualCountString;
    
    if ([recentChatModel.badgeCount integerValue] == 0) {
        self.unreadBadgeLabel.hidden = YES;
    }else{
        self.unreadBadgeLabel.hidden = NO;
    }
}



@end
