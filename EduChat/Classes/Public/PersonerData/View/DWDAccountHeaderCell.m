//
//  DWDAccountHeaderCell.m
//  EduChat
//
//  Created by apple on 12/10/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountHeaderCell.h"

#import "DWDPersonerDataEntity.h"
#import "DWDCustomUserInfoEntity.h"
#import <UIImageView+WebCache.h>

@interface DWDAccountHeaderCell ()

@property (strong, nonatomic) IBOutlet UILabel *regionTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *signatureTitleLabel;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separatorHeights;

@end

@implementation DWDAccountHeaderCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.nicknameLabel.text = nil;
    self.regionTitleLabel.text = NSLocalizedString(@"Region", nil);
    self.regionLabel.text = nil;
    self.signatureTitleLabel.text = NSLocalizedString(@"Signatorue", nil);
    self.signatureLabel.text = nil;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTap:)];
    self.avatarView.userInteractionEnabled = YES;
    [self.avatarView addGestureRecognizer:tap];
    
    for (NSLayoutConstraint *separatorHeight in self.separatorHeights) {
        separatorHeight.constant = .5;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}




- (void)avatarViewTap:(UITapGestureRecognizer *)tap {
    !self.clickAvatarBlock ?: self.clickAvatarBlock(self.avatarView);
}

#pragma mark - Setter
- (void)setPersonerDataEntity:(DWDPersonerDataEntity *)personerDataEntity
{
    _personerDataEntity = personerDataEntity;
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:personerDataEntity.photoKey]  placeholderImage:DWDDefault_MeBoyImage];
    
    if([self.personerDataEntity.educhatAccount isEqualToString:@""] || !personerDataEntity.educhatAccount){
        self.eduAccountLab.text = @"多维度号: 未设置";
    }else{
        self.eduAccountLab.text = [NSString stringWithFormat:@"多维度号: %@",personerDataEntity.educhatAccount];
    }
    
    
    
    NSString *regionName = [personerDataEntity.regionName isEqualToString:@""] ? @"TA在地球的某一端" : personerDataEntity.regionName;
    self.regionLabel.text = regionName;
    self.regionLabel.textColor = DWDColorContent;
    
    NSString *signatureStr = [personerDataEntity.signature isEqualToString:@""] ? @"TA啥都没留下" : personerDataEntity.signature ;
    self.signatureLabel.text = signatureStr;
     self.signatureLabel.textColor = DWDColorContent;
    
    NSString *typeStr = [personerDataEntity.custType isEqualToNumber:@4] ? @"老师" : @"家长";
    [self.typeLab setText:typeStr];
    
    NSString *iconName;
    if([personerDataEntity.gender  isEqualToNumber: @0]){
        iconName = @"";
    }else if([personerDataEntity.gender isEqualToNumber: @1]){
        iconName = @"ic_boy_people_nearby_normal";
    }else{
        iconName = @"ic_gril_people_nearby_normal";
    }
    [self.genderImv setImage:[UIImage imageNamed:iconName]];

}

- (void)setCustomUserInfoEntity:(DWDCustomUserInfoEntity *)customUserInfoEntity
{
    _customUserInfoEntity = customUserInfoEntity;
    //判断是否有备注
    if(customUserInfoEntity.friendRemarkName && ![customUserInfoEntity.friendRemarkName isEqualToString:@""]){
        
        self.nicknameLabel.hidden = NO;
        self.remarkNameLabel.text = customUserInfoEntity.friendRemarkName;
        self.nicknameLabel.text = [NSString stringWithFormat:@"昵称: %@",self.personerDataEntity.nickname];
        
    }else{
        self.nicknameLabel.hidden = YES;
        self.remarkNameLabel.text = self.personerDataEntity.nickname;
    }

}

#pragma mark - Event Response
- (IBAction)clickAvatarAction:(UITapGestureRecognizer *)sender {
    
}
@end
