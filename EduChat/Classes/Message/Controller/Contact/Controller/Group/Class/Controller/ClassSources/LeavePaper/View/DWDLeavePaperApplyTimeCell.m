//
//  DWDLeavePaperApplyTimeCell.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLeavePaperApplyTimeCell.h"

@interface DWDLeavePaperApplyTimeCell()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *arrLines;

@end
@implementation DWDLeavePaperApplyTimeCell

-(void)drawRect:(CGRect)rect
{
    
    for (UIView *line in self.arrLines) {
        if (line.frame.size.height == DWDLineH) {
            return;
        }
        [line setH:DWDLineH];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
