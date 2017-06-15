//
//  DWDHomeWorkCompletenessCell.m
//  EduChat
//
//  Created by apple on 12/30/15.
//  Copyright © 2015 dwd. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import "DWDHomeWorkCompletenessCell.h"
#import "TTTAttributedLabel.h"
#define DWDHomeWorkCompletenessPaddingH 20
#define DWDHomeWorkCompletenessPaddingV 10
#define DWDHomeWorkCompletenessInnerPadding 5
#define DWDHomeWorkCompletenessPeopleAvatarEdgeLength 50

@interface DWDHomeWorkCompletenessCell () {
    CGRect titleFrame, countFrame, peopleContainerFrame;
}

@property (nonatomic) NSUInteger peopleColums;
@property (nonatomic) NSUInteger peoplePadding;

@property (strong, nonatomic) NSArray *peopleViews;

@property (strong, nonatomic) UIView *peopleContainerView;

@end

@implementation DWDHomeWorkCompletenessCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (DWDScreenW > 320) {
            self.peopleColums = 5;
        }
        
        else {
            self.peopleColums = 4;
        }
        
        self.peoplePadding = (DWDScreenW - 2 * DWDHomeWorkCompletenessPaddingH -
                              self.peopleColums * DWDHomeWorkCompletenessPeopleAvatarEdgeLength) /
        (self.peopleColums - 1);
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (void)buildSubviews {
    
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = DWDFontBody;
    self.titleLabel.textColor = DWDColorBody;
    
    _countLabel = [[UILabel alloc] init];
    self.countLabel.font = DWDFontContent;
    self.countLabel.textColor = DWDColorContent;
    
    _peopleContainerView = [[UIView alloc] init];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDHomeWorkCompletenessPaddingV)];
    topView.backgroundColor = DWDColorBackgroud;
    
    [self.contentView addSubview:topView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.peopleContainerView];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize titleSize = [self.titleLabel.text
                        boundingRectWithSize:CGSizeMake(DWDScreenW / 4, 9999)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:self.titleLabel.font}
                        context:nil].size;
    
    CGSize countSize = [self.countLabel.text
                        boundingRectWithSize:CGSizeMake(DWDScreenW / 4, 9999)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:self.countLabel.font}
                        context:nil].size;
    
    titleFrame = CGRectMake(DWDHomeWorkCompletenessPaddingH,
                            2 * DWDHomeWorkCompletenessPaddingV,
                            titleSize.width,
                            titleSize.height);
    
    countFrame = CGRectMake(DWDScreenW - DWDHomeWorkCompletenessPaddingH - countSize.width,
                            0,
                            countSize.width,
                            countSize.height);
   
    self.titleLabel.frame = titleFrame;
    self.countLabel.frame = countFrame;
    self.countLabel.center = CGPointMake(self.countLabel.center.x, self.titleLabel.center.y);
    
    NSUInteger count = self.peoples.count;
    if (count > 0) {
        
    
        NSUInteger rows = count / self.peopleColums;
        if (count % self.peopleColums > 0) rows++;
        
        for (int i = 0; i < count; i++) {
            
            //********  innerContainer  ********
            UIView *innerContainer = [[UIView alloc] init];
            
            UIImageView *avatar = [[UIImageView alloc] init];
            [avatar sd_setImageWithURL:[NSURL URLWithString:self.peoples[i][@"photoKey"]]];
            avatar.backgroundColor = DWDColorBackgroud;
            
            TTTAttributedLabel *nicknameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
            nicknameLabel.textAlignment = NSTextAlignmentCenter;
            nicknameLabel.font = DWDFontContent;
            nicknameLabel.textColor = DWDColorContent;
            nicknameLabel.text = self.peoples[i][@"name"];
            [innerContainer addSubview:avatar];
            [innerContainer addSubview:nicknameLabel];
            
            avatar.frame = CGRectMake(0, 0, DWDHomeWorkCompletenessPeopleAvatarEdgeLength, DWDHomeWorkCompletenessPeopleAvatarEdgeLength);
            
            CGSize nicknameSize = [TTTAttributedLabel
                                   sizeThatFitsAttributedString:nicknameLabel.attributedText
                                   withConstraints:CGSizeMake(DWDHomeWorkCompletenessPeopleAvatarEdgeLength, 9999)
                                   limitedToNumberOfLines:1];
            
            nicknameLabel.frame = CGRectMake(0, avatar.frame.origin.y +
                                             avatar.frame.size.height +
                                             DWDHomeWorkCompletenessInnerPadding,
                                             DWDHomeWorkCompletenessPeopleAvatarEdgeLength, nicknameSize.height);
            
            nicknameLabel.center = CGPointMake(avatar.center.x, nicknameLabel.center.y);
            
            
            //********  innerContainer  ********
            
            CGFloat innerContainerHeight = DWDHomeWorkCompletenessPeopleAvatarEdgeLength +
                                            nicknameSize.height +
                                                DWDHomeWorkCompletenessInnerPadding;
            
            peopleContainerFrame = CGRectMake(DWDHomeWorkCompletenessPaddingH,
                                              titleFrame.origin.y + titleFrame.size.height + DWDHomeWorkCompletenessPaddingV,
                                              DWDScreenW - 2 * DWDHomeWorkCompletenessPaddingH,
                                              rows * (innerContainerHeight) + (rows - 1) * self.peoplePadding);
            
            innerContainer.frame = CGRectMake(i % self.peopleColums *
                                              (self.peoplePadding + DWDHomeWorkCompletenessPeopleAvatarEdgeLength),
                                              i / self.peopleColums *
                                              (self.peoplePadding + innerContainerHeight),
                                              DWDHomeWorkCompletenessPeopleAvatarEdgeLength, innerContainerHeight);
            
            [self.peopleContainerView addSubview:innerContainer];
            self.peopleContainerView.frame = peopleContainerFrame;
        }
    }
    
    else {
        self.peopleContainerView.frame = CGRectZero;
    }
    
}

- (CGFloat)getHeight {
    CGFloat result;
    
    result = 4 * DWDHomeWorkCompletenessPaddingV + titleFrame.size.height + peopleContainerFrame.size.height;
    
    if (peopleContainerFrame.size.height == 0) {
        result -= DWDHomeWorkCompletenessPaddingV;
    }
    return result;
}

@end
