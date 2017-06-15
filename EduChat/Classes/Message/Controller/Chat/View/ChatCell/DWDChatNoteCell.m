//
//  DWDChatNoteCell.m
//  EduChat
//
//  Created by Superman on 16/3/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatNoteCell.h"
#define DWDNoteCellPadding 4

@interface DWDChatNoteCell(){
    CGRect backgroundFrame, contentFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation DWDChatNoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundImageView.image = [UIImage imageWithColor:DWDRGBColor(204, 204, 204)];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.font = DWDFontMin;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.backgroundImageView];
        [self.contentView addSubview:self.contentLabel];
        
        self.contentView.backgroundColor = DWDColorBackgroud;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize contentSize = [self getContentSize];
    
    contentFrame = CGRectMake(DWDScreenW * 0.5 - contentSize.width * 0.5, 0, contentSize.width, contentSize.height);
    backgroundFrame = CGRectMake(DWDScreenW * 0.5 - (contentSize.width + 2 * DWDNoteCellPadding)* 0.5, 0, contentSize.width + 2 * DWDNoteCellPadding, contentSize.height + 2 * DWDNoteCellPadding);
    
    self.contentLabel.frame = contentFrame;
    self.backgroundImageView.frame = backgroundFrame;
    
    self.contentLabel.center = self.contentView.center;
    self.backgroundImageView.center = self.contentView.center;
}

- (CGFloat)getHeight {
    return [self getContentSize].height + 4 * DWDNoteCellPadding;
}

// 获取真实尺寸
- (CGSize)getContentSize {
    
    return [self.contentLabel.text boundingRectWithSize:CGSizeMake(DWDScreenW * 0.8, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : DWDFontMin} context:nil].size;
    
}

@end
