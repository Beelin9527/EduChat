//
//  DWDClassStudentsListCell.h
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDTeacherGoSchoolStudentDetailModel;
@interface DWDClassStudentsListCell : UITableViewCell

- (void)setCellData:(DWDTeacherGoSchoolStudentDetailModel *)model;

@end
