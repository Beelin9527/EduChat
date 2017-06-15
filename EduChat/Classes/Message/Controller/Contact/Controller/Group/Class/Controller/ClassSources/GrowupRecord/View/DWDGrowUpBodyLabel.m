//
//  DWDGrowUpBodyLabel.m
//  EduChat
//
//  Created by apple on 2/24/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpBodyLabel.h"

@implementation DWDGrowUpBodyLabel

/*
 UILabel *bodyLabel = [[UILabel alloc] init];
 bodyLabel.font = DWDFontContent;
 bodyLabel.preferredMaxLayoutWidth = DWDScreenW - pxToW(78);
 bodyLabel.numberOfLines = 0;
 _bodyLabel = bodyLabel;
 [self.contentView addSubview:bodyLabel];
 */
- (instancetype)init {
    DWDGrowUpBodyLabel *label = [super init];
    //超过3行自动省略
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 3;
    //label最大宽度
//    label.preferredMaxLayoutWidth = DWDScreenW - pxToW(78);

    label.font = DWDFontContent;
    
    self = label;
    return self;
}

- (void)expandLabel {
    self.numberOfLines = 0;
}

- (void)contractLabel {
    self.numberOfLines = 3;
}

- (void)setExpandState:(BOOL)expandState {
    _expandState = expandState;
    DWDMarkLog(@"state:%d", expandState);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
