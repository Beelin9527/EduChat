//
//  DWDButton.m
//  EduChat
//
//  Created by apple on 12/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDButton.h"

@implementation DWDButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = //do not use btn.titleLabel.frame.size, if you use, first time you will get a wrong size
    [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    //when text length big enough, up line titleSize will not correct
    [self.titleLabel sizeToFit];
    titleSize = [self.titleLabel size];
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + 4);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
}

@end
