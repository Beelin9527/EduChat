//
//  DWDContactHeaderCell.m
//  EduChat
//
//  Created by apple on 12/8/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDContactHeaderCell.h"

#define DWDContactHeaderBtnEdgeLength 80
#define DWDContactHeaderLeftRightPadding 20
#define DWDContactHeaderHeight 80

@interface DWDContactHeaderCell () {
    CGRect friendsFrame, groupsFrame, classesFrame , badgeLabelFrame;
}

@property (strong, nonatomic) UIButton *friendsBtn;
@property (strong, nonatomic) UIButton *groupsBtn;
@property (strong, nonatomic) UIButton *classesBtn;

@end

@implementation DWDContactHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _friendsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength)];
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.hidden = YES;
        _groupsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength)];
        _classesBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength)];
        
        self.friendsBtn.titleLabel.font = DWDFontMin;
        _badgeLabel.font = DWDFontMin;
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.layer.cornerRadius = 7.5;
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.clipsToBounds = YES;
        
        self.groupsBtn.titleLabel.font = DWDFontMin;
        self.classesBtn.titleLabel.font = DWDFontMin;
        
        [self.friendsBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [self.groupsBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [self.classesBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        
        [self.friendsBtn setTitle:NSLocalizedString(@"NewFriends", nil) forState:UIControlStateNormal];
        [self.groupsBtn setTitle:NSLocalizedString(@"Groups", nil) forState:UIControlStateNormal];
        [self.classesBtn setTitle:NSLocalizedString(@"Classes", nil) forState:UIControlStateNormal];
        
        [self.friendsBtn setImage:[UIImage imageNamed:@"ic_new_friend_contact_normal"] forState:UIControlStateNormal];
        [self.groupsBtn setImage:[UIImage imageNamed:@"ic_groups_contact_normal"] forState:UIControlStateNormal];
        [self.classesBtn setImage:[UIImage imageNamed:@"ic_class_contact_normal"] forState:UIControlStateNormal];
        
        [self.friendsBtn setImage:[UIImage imageNamed:@"ic_new_friend_contact_press"] forState:UIControlStateHighlighted];
        [self.groupsBtn setImage:[UIImage imageNamed:@"ic_groups_contact_press"] forState:UIControlStateHighlighted];
        [self.classesBtn setImage:[UIImage imageNamed:@"ic_class_contact_press"] forState:UIControlStateHighlighted];
        
        
        [self.friendsBtn addTarget:self action:@selector(showFriends:) forControlEvents:UIControlEventTouchUpInside];
        [self.groupsBtn addTarget:self action:@selector(showGroups:) forControlEvents:UIControlEventTouchUpInside];
        [self.classesBtn addTarget:self action:@selector(showClasses:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.friendsBtn];
        [self addSubview:self.groupsBtn];
        [self addSubview:self.classesBtn];
        [self.friendsBtn addSubview:self.badgeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self buildFrames];
}

- (void)centerImageAndTitle:(float)spacing button:(UIButton *)btn

{
    // get the size of the elements here for readability
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = //do not use btn.titleLabel.frame.size, if you use, first time you will get a wrong size
    [btn.titleLabel.text boundingRectWithSize:CGSizeMake(DWDContactHeaderBtnEdgeLength, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font} context:nil].size;
    //when text length big enough, up line titleSize will not correct
    [btn.titleLabel sizeToFit];
    titleSize = [btn.titleLabel size];
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    btn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
}


- (void)showFriends:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactHeaderCellDidShowNewFriendsWithTitle:)]) {
        [self.actionDelegate contactHeaderCellDidShowNewFriendsWithTitle:sender.titleLabel.text];
    }
}

- (void)showGroups:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactHeaderCellDidShowGroupsWithTitle:)]) {
        [self.actionDelegate contactHeaderCellDidShowGroupsWithTitle:sender.titleLabel.text];
    }
}

- (void)showClasses:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactHeaderCellDidShowClassesWithTitle:)]) {
        [self.actionDelegate contactHeaderCellDidShowClassesWithTitle:sender.titleLabel.text];
    }
}


- (void)buildFrames {
    
    friendsFrame = CGRectMake(DWDContactHeaderLeftRightPadding, 0, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength);
    
    groupsFrame = CGRectMake(0, 0, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength);
    classesFrame = CGRectMake(DWDScreenW - DWDContactHeaderBtnEdgeLength - DWDContactHeaderLeftRightPadding, DWDContactHeaderLeftRightPadding, DWDContactHeaderBtnEdgeLength, DWDContactHeaderBtnEdgeLength);
    
    self.friendsBtn.frame = friendsFrame;
    
    
    
    self.friendsBtn.center = CGPointMake(self.friendsBtn.center.x, DWDContactHeaderHeight / 2);
    self.groupsBtn.frame = groupsFrame;
    self.groupsBtn.center = CGPointMake(DWDScreenW / 2, DWDContactHeaderHeight / 2);
    self.classesBtn.frame = classesFrame;
    self.classesBtn.center = CGPointMake(self.classesBtn.center.x, DWDContactHeaderHeight / 2);
    
    badgeLabelFrame = CGRectMake(_friendsBtn.size.width/2 - 20, 10 , 15, 15);
    self.badgeLabel.frame = badgeLabelFrame;
    
    [self centerImageAndTitle:5 button:self.friendsBtn];
    [self centerImageAndTitle:5 button:self.groupsBtn];
    [self centerImageAndTitle:5 button:self.classesBtn];
}

@end
