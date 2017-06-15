//
//  DWDMyChildsListCell.m
//  EduChat
//
//  Created by Gatlin on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyChildsListCell.h"
#import "DWDMyChildListEntity.h"
@interface DWDMyChildsListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImv;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *childEduAcct;

@end
@implementation DWDMyChildsListCell

- (void)setEntity:(DWDMyChildListEntity *)entity
{
    _entity = entity;
    [_avatarImv sd_setImageWithURL:[NSURL URLWithString:entity.childPhotoKey] placeholderImage:[entity.gender isEqualToNumber:@2] ? DWDDefault_MeGrilImage : DWDDefault_MeBoyImage];
    _nameLab.text = entity.childName;
    _childEduAcct.text = [NSString stringWithFormat:@"多维度号: %@",entity.childEduAcct];

}

@end

