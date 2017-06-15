//
//  DWDNewFriendsListCell.m
//  EduChat
//
//  Created by Gatlin on 16/3/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDNewFriendsListCell.h"

#import "DWDFriendApplyEntity.h"
@interface DWDNewFriendsListCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImv;
@property (weak, nonatomic) IBOutlet UILabel *friendNicknameLab;
@property (weak, nonatomic) IBOutlet UILabel *verifyLab;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@end

@implementation DWDNewFriendsListCell


#pragma mark - Setter
- (void)setEntity:(DWDFriendApplyEntity *)entity
{
    _entity = entity;
    
    [_avatarImv sd_setImageWithURL:[NSURL URLWithString:entity.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    _friendNicknameLab.text = entity.friendNickname;
    _verifyLab.text = entity.verifyInfo;
    
    //判断状态，显示不同样式
    if([entity.status isEqualToNumber:@0]){
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = 3;
         _btn.backgroundColor = DWDColorMain;
        _btn.userInteractionEnabled = YES;
    }else{
        [_btn setTitle:@"已添加" forState:UIControlStateNormal];
        [_btn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        _btn.backgroundColor = [UIColor whiteColor];
        _btn.userInteractionEnabled = NO;
    }

}


- (IBAction)didSelectAcceptAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(newfriendsListCell:didSelectAcceptButtonOfFriendEntity:)]) {
        [self.delegate newfriendsListCell:self didSelectAcceptButtonOfFriendEntity:self.entity];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
