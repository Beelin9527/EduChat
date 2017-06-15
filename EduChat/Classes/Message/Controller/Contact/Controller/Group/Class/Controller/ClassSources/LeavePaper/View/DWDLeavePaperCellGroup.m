//
//  DWDLeavePaperCellGroup.m
//  EduChat
//
//  Created by KKK on 16/5/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kStateAgree @1
#define kStateRefuse @2
#define kStateNotSure @0

#import "DWDLeavePaperCellGroup.h"

#import "DWDLeavePaperDetailModel.h"
#import "NSString+extend.h"

#import <UIImageView+WebCache.h>

@implementation DWDLeavePaperCellGroup

@end

@interface DWDLeavePaperHeadCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *childNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *vacateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@end
@implementation DWDLeavePaperHeadCell
- (void)setModel:(DWDLeavePaperDetailModel *)model {
    _model = model;
    
    [_headImgView sd_setImageWithURL:[NSURL URLWithString:model.photoKey] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _childNameLabel.text = model.noteManName;
    _vacateTimeLabel.text = model.createTime;
    _parentLabel.text = [model.noteManName stringByAppendingString:[NSString parentRelationStringWithRelation:model.relationType]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *startDate = [dateFormatter dateFromString:model.startTime];
    NSDate *endDate = [dateFormatter dateFromString:model.endTime];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    _startTimeLabel.text = [dateFormatter stringFromDate:startDate];
    _endTimeLabel.text = [dateFormatter stringFromDate:endDate];
}
@end

@interface DWDLeavePaperVacateCell ()
@property (weak, nonatomic) IBOutlet UILabel *vacateTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *vacateReasonLabel;
@end
@implementation DWDLeavePaperVacateCell
- (void)setModel:(DWDLeavePaperDetailModel *)model {
    _model = model;
    NSString *typeStr;
    if ([model.noteType isEqualToNumber:@1]) {
        typeStr = @"事假";
    } else if ([model.noteType isEqualToNumber:@2]) {
        typeStr = @"病假";
    } else {
        typeStr = @"其他";
    }
    _vacateTypeLabel.text = typeStr;
    _vacateReasonLabel.text = model.excuse;
}
@end

@interface DWDLeavePaperCheckCell ()
@property (weak, nonatomic) IBOutlet UILabel *checkPersonLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkStateLabel;
@end
@implementation DWDLeavePaperCheckCell
- (void)setModel:(DWDLeavePaperDetailModel *)model {
    _model = model;
    _checkPersonLabel.text = model.aprdName;
    _checkTimeLabel.text = model.aprdTime;
    NSString *checkTypeStr;
    if ([model.state isEqualToNumber:kStateAgree]) {
        checkTypeStr = @"同意";
        _checkStateLabel.textColor = DWDRGBColor(79, 209, 175);
    } else if ([model.state isEqualToNumber:kStateRefuse]) {
        checkTypeStr = @"不同意";
        _checkStateLabel.textColor = DWDRGBColor(249, 98, 105);
    } else {
        checkTypeStr = @"未审核";
        _checkStateLabel.textColor = DWDRGBColor(51, 51, 51);
    }
    _checkStateLabel.text = checkTypeStr;
}
@end

@interface DWDLeavePaperRefuseCell ()
@property (weak, nonatomic) IBOutlet UILabel *refuseReasonLabel;
@end
@implementation DWDLeavePaperRefuseCell
- (void)setModel:(DWDLeavePaperDetailModel *)model {
    _model = model;
    _refuseReasonLabel.text = model.opinion;
}
@end

@interface DWDLeavePaperNotCheckCell ()
@property (weak, nonatomic) IBOutlet UILabel *checkStateLabel;
@end
@implementation DWDLeavePaperNotCheckCell
- (void)setModel:(DWDLeavePaperDetailModel *)model {
    NSString *checkTypeStr;
    if ([model.state isEqualToNumber:kStateAgree]) {
        checkTypeStr = @"同意";
        _checkStateLabel.textColor = DWDRGBColor(79, 209, 175);
    } else if ([model.state isEqualToNumber:kStateRefuse]) {
        checkTypeStr = @"不同意";
        _checkStateLabel.textColor = DWDRGBColor(249, 98, 105);
    } else {
        checkTypeStr = @"未审核";
        _checkStateLabel.textColor = DWDRGBColor(51, 51, 51);
    }
    _checkStateLabel.text = checkTypeStr;
}
@end


@interface DWDLeavePaperAproveCell ()
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;


@end
@implementation DWDLeavePaperAproveCell
- (void)awakeFromNib {
    [super awakeFromNib];
    _agreeButton.layer.cornerRadius = 22;
    _agreeButton.layer.borderWidth = 1;
    _agreeButton.layer.masksToBounds = YES;
    _agreeButton.layer.borderColor = DWDRGBColor(90, 136, 231).CGColor;
    [_agreeButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_agreeButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(90, 136, 231)] forState:UIControlStateSelected];
    
    _refuseButton.layer.cornerRadius = 22;
    _refuseButton.layer.borderWidth = 1;
    _refuseButton.layer.masksToBounds = YES;
    _refuseButton.layer.borderColor = DWDRGBColor(90, 136, 231).CGColor;
    [_refuseButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_refuseButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(90, 136, 231)] forState:UIControlStateSelected];
}
- (IBAction)agreeButtonClick:(id)sender {
    _agreeButton.selected = YES;
    _refuseButton.selected = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(aproveCellDidClickAgreeButton:)]) {
        [_delegate aproveCellDidClickAgreeButton:self];
    }
}
- (IBAction)refuseButtonClick:(id)sender {
    
    _agreeButton.selected = NO;
    _refuseButton.selected = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(aproveCellDidClickRefuseButton:)]) {
        [_delegate aproveCellDidClickRefuseButton:self];
    }
}
@end



@interface DWDLeavePaperTeacherRefuseCell () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *refuseTextView;
@end
@implementation DWDLeavePaperTeacherRefuseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _refuseTextView.delegate = self;
}

#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请填写不同意理由"]) {
        textView.textColor = DWDColorBody;
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] || textView.text.length == 0) {
        textView.textColor = DWDRGBColor(153, 153, 153);
        textView.text = @"请填写不同意理由";
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    if (_delegate && [_delegate respondsToSelector:@selector(teacherRefuseCell:didChangeText:)]) {
        [_delegate teacherRefuseCell:self didChangeText:text];
    }
}

@end
