//
//  DWDPickUpCenterChildNoLiveCell.m
//  EduChat
//
//  Created by KKK on 16/3/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterChildNoLiveCell.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import "NSString+extend.h"

#import <UIImageView+WebCache.h>

@interface DWDPickUpCenterChildNoLiveCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation DWDPickUpCenterChildNoLiveCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _contentLabel.font = DWDFontContent;
    _contentLabel.preferredMaxLayoutWidth = DWDScreenW - 40;
    _contentLabel.numberOfLines = 0;
    
    _dateTimeLabel.font = DWDFontMin;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataModel:(DWDPickUpCenterDataBaseModel *)dataModel {
    _dataModel = dataModel;
    
    
    _dateTimeLabel.text = [NSString stringWithFormat:@"%@ %@", dataModel.date, dataModel.time];
    
    [_faceImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photokey] placeholderImage:[[UIImage imageNamed:@"ME_User_HP_Boy"] clipCircleWithBorderWidth:pxToW(6) borderColor:[UIColor whiteColor]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            if (!error) {
                [_faceImageView setImage:[image clipCircleWithBorderWidth:pxToW(6)
                                                              borderColor:[UIColor whiteColor]]];
            }
        }
    }];

    NSString *state = dataModel.contextual;
    NSString *parent = [NSString parentRelationStringWithRelation:dataModel.relation];
    
    if ([state isEqualToString:@"Getoutschool"]) {
        //小花老师已确认家长接小明放学。
        
        _contentLabel.text = [NSString stringWithFormat:@"%@老师已确认家长接%@放学。", dataModel.teacher.name, dataModel.name];
    }
    else if ([state isEqualToString:@"OffAfterschoolBus"]) {
        //小花老师已确认小明爸爸接小明放学。
        _contentLabel.text = [NSString stringWithFormat:@"%@老师已确认%@%@接%@放学。", dataModel.teacher.name, dataModel.name, parent , dataModel.name];
    }

}

@end
