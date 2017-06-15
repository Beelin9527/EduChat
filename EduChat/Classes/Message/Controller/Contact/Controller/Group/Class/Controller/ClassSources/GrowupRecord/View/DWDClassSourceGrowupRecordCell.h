//
//  DWDClassSourceGrowupRecordCell.h
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassMember;
@interface DWDClassSourceGrowupRecordCell : UICollectionViewCell
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , strong) DWDClassMember *member;

@end
