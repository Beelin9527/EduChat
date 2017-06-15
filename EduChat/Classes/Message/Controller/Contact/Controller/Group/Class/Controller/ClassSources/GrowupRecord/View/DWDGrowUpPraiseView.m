//
//  DWDGrowUpPraiseView.m
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpPraiseView.h"

#import "TTTAttributedLabel.h"
#import <YYText.h>
#import <Masonry.h>

@interface DWDGrowUpPraiseView ()

@property (nonatomic, weak) YYLabel *praiseLabel;

@end

@implementation DWDGrowUpPraiseView

- (void)setPraiseLabelConstraints {
    UIImage *image = [UIImage imageNamed:@"bg_comment_content_growth_record"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)
                                  resizingMode:UIImageResizingModeStretch];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:image];
    [self insertSubview:bgImageView atIndex:0];
    
    //花图
    UIImageView *flowerImageView = [UIImageView new];
    [self addSubview:flowerImageView];
    self.flowerImageView = flowerImageView;
    
    //点赞人label
    YYLabel *praiseLabel = [YYLabel new];
    praiseLabel.font = DWDFontContent;
    praiseLabel.numberOfLines = 0;
    praiseLabel.preferredMaxLayoutWidth = DWDScreenW - pxToW(80);
    [self addSubview:praiseLabel];
    self.praiseLabel = praiseLabel;
    
    [bgImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [flowerImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pxToW(44));
        make.height.mas_equalTo(pxToW(44));
        make.top.equalTo(self).offset(pxToW(20));
        make.left.equalTo(self).offset(pxToW(11));
    }];
    
    [praiseLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(flowerImageView.right).offset(pxToW(11));
        make.top.equalTo(flowerImageView);//.offset(pxToW(11));
        make.right.equalTo(self);
        make.bottom.equalTo(self);
//        make.height.mas_equalTo(@500);
    }];
    
}

- (void)setPraiseArray:(NSArray *)praiseArray {
    _praiseArray = praiseArray;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setPraiseLabelConstraints];
    
    
    self.flowerImageView.image = [UIImage imageNamed:@"ic_good_red"];
    
    for (int i = 0; i < praiseArray.count; i ++) {
        NSString *name = praiseArray[i][@"nickname"];
        if (i == 0) {
            self.praiseLabel.text = [NSString stringWithFormat:@"%@", name];
        } else {
            self.praiseLabel.text = [self.praiseLabel.text stringByAppendingString:[NSString stringWithFormat:@",%@", name]];
        }
    }
//    NSMutableAttributedString *pariseAttrStr = [[NSMutableAttributedString alloc] initWithString:self.praiseLabel.text];
//    pariseAttrStr.yy_font = DWDFontContent;
//    [self.praiseLabel updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo([TTTAttributedLabel sizeThatFitsAttributedString:pariseAttrStr withConstraints:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57) - pxToW(66), MAXFLOAT) limitedToNumberOfLines:100].height + 2);
//    }];
//    [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:dict context:nil].size;
    NSDictionary *dict = @{NSFontAttributeName : DWDFontContent};
    [self.praiseLabel updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.praiseLabel.text boundingRectWithSize:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57) - pxToW(66), MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:dict context:nil].size.height);
    }];
    [super updateConstraints];
}

@end
