//
//  DWDLeavePaperApplyStudentCell.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLeavePaperApplyStudentCell.h"
@interface DWDLeavePaperApplyStudentCell()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *arrLines;

@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *excuse;
@end
@implementation DWDLeavePaperApplyStudentCell
-(void)drawRect:(CGRect)rect
{
    
    for (UIView *line in self.arrLines) {
        if (line.frame.size.height == DWDLineH) {
            return;
        }
        [line setH:DWDLineH];
    }
}

- (void)setNoteDetailEntity:(DWDNoteDetailEntity *)noteDetailEntity
{
    _noteDetailEntity = noteDetailEntity;
    
    _startTime.text = noteDetailEntity.startTime;
    _endTime.text = noteDetailEntity.endTime;
    _excuse.text = noteDetailEntity.excuse;
}

- (void)setAuthorEntity:(DWDAuthorEntity *)authorEntity
{
    _authorEntity = authorEntity;
    
    _author.text = authorEntity.name;
   
}

- (void)setNoteEntity:(DWDNoteEntity *)noteEntity
{
    _noteEntity = noteEntity;
    
    
    if ([noteEntity.type isEqualToNumber:@1]) {
        _type.text = @"事假";
    }else if ([noteEntity.type isEqualToNumber:@2]){
        _type.text = @"病假";
    }else{
        _type.text = @"其他";
    }
   
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
