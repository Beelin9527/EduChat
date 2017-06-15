//
//  DWDHomeWorkReadCell.m
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDHomeWorkReadCell.h"
#import "TTTAttributedLabel.h"

//#define DWDHomeWorkCompletenessPaddingH 20
//#define DWDHomeWorkCompletenessPaddingV 15
//#define DWDHomeWorkCompletenessInnerPadding 10
//#define DWDHomeWorkCompletenessPeopleAvatarEdgeLength 50
#define DWDReadLeftPadding 20.0
#define DWDReadMarginX 21.0
#define DWDReadMarginY 15.0

@interface DWDHomeWorkReadCell ()

{
    CGRect titleFrame, countFrame, peopleContainerFrame;
}

@property (nonatomic) NSUInteger peopleColums;
//@property (nonatomic) NSUInteger peoplePadding;
@property (nonatomic) NSUInteger peopleWidth;

@property (strong, nonatomic) NSArray *peopleViews;

@property (strong, nonatomic) UIView *peopleContainerView;

@end

@implementation DWDHomeWorkReadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.peopleColums = 5;
        self.peopleWidth = (DWDScreenW - 2 * DWDReadLeftPadding - 4 * DWDReadMarginX)/self.peopleColums;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (UIView *)peopleContainerView
{
    if (!_peopleContainerView) {
        _peopleContainerView = [[UIView alloc] init];
        [self.contentView addSubview:_peopleContainerView];
    }
    return _peopleContainerView;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (void)setPeoples:(NSArray *)peoples
{
    _peoples = peoples;
    
    [_peopleContainerView removeFromSuperview];
    _peopleContainerView = nil;
    
    NSUInteger count = self.peoples.count;
    
    if (count > 0) {
        
        NSUInteger rows = count / self.peopleColums;
        if (count % self.peopleColums > 0) rows++;
        
        for (int i = 0; i < count; i++) {
            
            //********  innerContainer  ********
            UIView *innerContainer = [[UIView alloc] init];
            innerContainer.tag = 10000 + i;
            
            UIImageView *avatar = [[UIImageView alloc] init];
            avatar.layer.cornerRadius = self.peopleWidth * 0.5;
            avatar.layer.masksToBounds = YES;
            [avatar sd_setImageWithURL:[NSURL URLWithString:self.peoples[i][@"photoKey"]] placeholderImage:DWDDefault_MeBoyImage];
            
            TTTAttributedLabel *nicknameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
            nicknameLabel.textAlignment = NSTextAlignmentCenter;
            nicknameLabel.font = DWDFontMin;
            nicknameLabel.textColor = DWDColorContent;
            nicknameLabel.text = self.peoples[i][@"name"];
            [innerContainer addSubview:avatar];
            [innerContainer addSubview:nicknameLabel];
            
            avatar.frame = CGRectMake(0, 0, self.peopleWidth, self.peopleWidth);
            
            CGSize nicknameSize = [TTTAttributedLabel
                                   sizeThatFitsAttributedString:nicknameLabel.attributedText
                                   withConstraints:CGSizeMake(self.peopleWidth, 9999)
                                   limitedToNumberOfLines:1];
            
            nicknameLabel.frame = CGRectMake(0, avatar.frame.origin.y +
                                             avatar.frame.size.height +
                                             10.0f,
                                             self.peopleWidth, nicknameSize.height);
            
            nicknameLabel.center = CGPointMake(avatar.center.x, nicknameLabel.center.y);
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [innerContainer addGestureRecognizer:tap];
            //********  innerContainer  ********
            
            CGFloat innerContainerHeight = self.peopleWidth +
            nicknameSize.height +
            10.0f;
            
            peopleContainerFrame = CGRectMake(DWDReadLeftPadding,
                                              DWDReadMarginX,
                                              DWDScreenW - 2 * DWDReadLeftPadding,
                                              rows * (innerContainerHeight + DWDReadMarginY));
            
            innerContainer.frame = CGRectMake(i % self.peopleColums *
                                              (DWDReadMarginX + self.peopleWidth),
                                              i / self.peopleColums *
                                              (DWDReadMarginY + innerContainerHeight),
                                              self.peopleWidth, innerContainerHeight);
            
            [self.peopleContainerView addSubview:innerContainer];
            self.peopleContainerView.frame = peopleContainerFrame;
           
        }
    }

}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    NSInteger index = tap.view.tag - 10000;
    self.HomeWorkReadCellBlock ? self.HomeWorkReadCellBlock(self.peoples[index][@"custId"]) : nil;
}

- (CGFloat)getHeight {
    CGFloat result;
    
    result = 2 * DWDReadLeftPadding + peopleContainerFrame.size.height;
    return result;
}



@end
