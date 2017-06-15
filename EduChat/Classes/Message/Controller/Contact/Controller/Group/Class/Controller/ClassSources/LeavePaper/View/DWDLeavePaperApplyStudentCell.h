//
//  DWDLeavePaperApplyStudentCell.h
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//  假条申请人cell

#import <UIKit/UIKit.h>
#import "DWDAuthorEntity.h"
#import "DWDNoteDetailEntity.h"
#import "DWDNoteEntity.h"
@interface DWDLeavePaperApplyStudentCell : UITableViewCell

@property (strong, nonatomic) DWDAuthorEntity *authorEntity;
@property (strong, nonatomic) DWDNoteDetailEntity *noteDetailEntity;
@property (strong, nonatomic) DWDNoteEntity *noteEntity;
@end
