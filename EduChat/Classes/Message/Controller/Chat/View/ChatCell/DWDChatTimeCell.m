//
//  DWDChatTimeCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDChatTimeCell.h"

#define DWDTimeCellPadding 4

@interface DWDChatTimeCell () {
    CGRect backgroundFrame, contentFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation DWDChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundImageView.image = [UIImage imageWithColor:DWDRGBColor(204, 204, 204)];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.font = DWDFontMin;
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
    
    contentFrame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    backgroundFrame = CGRectMake(0, 0, contentSize.width + 2 * DWDTimeCellPadding, contentSize.height + 2 * DWDTimeCellPadding);
    
    self.contentLabel.frame = contentFrame;
    self.backgroundImageView.frame = backgroundFrame;
    
    self.contentLabel.center = self.contentView.center;
    self.backgroundImageView.center = self.contentView.center;
}

- (CGFloat)getHeight {
    return [self getContentSize].height + 2 * DWDTimeCellPadding + 5;
}

- (CGSize)getContentSize {
    return [self.contentLabel.text
            boundingRectWithSize:CGSizeMake(0, 0)
            options:NSStringDrawingUsesLineFragmentOrigin
            attributes:@{NSFontAttributeName:self.contentLabel.font}
            context:nil].size;

}

@end
