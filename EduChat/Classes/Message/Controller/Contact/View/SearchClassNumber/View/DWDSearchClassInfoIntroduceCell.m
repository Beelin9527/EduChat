//
//  DWDSearchClassInfoIntroduceCell.m
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSearchClassInfoIntroduceCell.h"
#import <Masonry.h>
@interface DWDSearchClassInfoIntroduceCell()

@property (nonatomic , weak) UILabel *rightLabel;

@end

@implementation DWDSearchClassInfoIntroduceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        NSString *str = @"班级介绍";
        CGSize realsize = [str realSizeWithfont:DWDFontBody];
        UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(pxToW(20), pxToH(30), realsize.width, realsize.height)];
        left.font = DWDFontBody;
        left.text = str;
        left.textColor = DWDRGBColor(184, 184, 184);
        _leftLabel = left;
        [self.contentView addSubview:left];
        
        UILabel *right = [[UILabel alloc] init];
        right.font = DWDFontContent;
        _rightLabel = right;
        [self.contentView addSubview:right];
        
    }
    return self;
}

- (void)setIntroduce:(NSString *)introduce{
    _introduce = introduce;
    _rightLabel.text = introduce;
    
    
}

@end
