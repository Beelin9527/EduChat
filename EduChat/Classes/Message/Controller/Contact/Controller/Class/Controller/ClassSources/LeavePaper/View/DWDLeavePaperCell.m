//
//  DWDLeavePaperCell.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLeavePaperCell.h"

#import "DWDAuthorEntity.h"
#import "DWDNoteEntity.h"
@interface DWDLeavePaperCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *labType;
@end
@implementation DWDLeavePaperCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)setAuthorEntity:(DWDAuthorEntity *)authorEntity
{
    _authorEntity = authorEntity;
    
    _name.text = authorEntity.name;
    
}

/*
 请假类型 type
 值域:
 1-事假
 2-病假
 3-其他
 
 state
 审批状态
 值域:
 0-未审批
 1-同意
 2-不同意
 */
- (void)setNoteEntity:(DWDNoteEntity *)noteEntity
{
    _noteEntity = noteEntity;
    
    _createTime.text = noteEntity.creatTime;
    
    if (self.type == DWDLeavePaperCellTypeApprove) {
        switch ([noteEntity.state integerValue]) {
            case 0:
                _labType.text = @"未审批";
                break;
            case 1:
                _labType.text = @"同意";
                break;
            case 2:
                _labType.text = @"不同意";
                break;
                
            default:
                break;
        }
    }
    
    if (self.type == DWDLeavePaperCellTypeNotApprove) {
        switch ([noteEntity.type integerValue]) {
            case 1:
                _labType.text = @"事假";
                break;
            case 2:
                _labType.text = @"病假";
                break;
            case 3:
                _labType.text = @"其他";
                break;
                
            default:
                break;
        }
    }

    
   // _type.text = noteEntity.type;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
