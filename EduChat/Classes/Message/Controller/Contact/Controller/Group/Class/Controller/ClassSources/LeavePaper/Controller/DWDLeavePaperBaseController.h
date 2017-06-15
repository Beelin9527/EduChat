//
//  DWDLeavePaperBaseController.h
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//  假条父类ViewController

#import <UIKit/UIKit.h>

#import "DWDLeavePaperApplyStudentCell.h"

#import "DWDRequestServerLeavePaper.h"
#import "DWDAuthorEntity.h"
#import "DWDNoteEntity.h"
#import "DWDNoteDetailEntity.h"

typedef enum {
    agreeType,disagreeType
}LeavePaperType;
@interface DWDLeavePaperBaseController : UITableViewController

@property (assign, nonatomic) LeavePaperType leavePaperType;
@property (strong, nonatomic) DWDNoteDetailEntity *noteDetailEntity;
@property (strong, nonatomic) DWDAuthorEntity *authorEntity;
@property (strong, nonatomic) DWDNoteEntity *noteEntity;
@property (strong, nonatomic) NSNumber *classId;  //班级Id
@end
